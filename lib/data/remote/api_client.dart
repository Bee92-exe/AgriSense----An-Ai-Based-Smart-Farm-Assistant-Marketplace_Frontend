import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../repositories/auth_repository.dart';
import 'token_store.dart';

/// Thin HTTP client for the Express API.
///
/// API_SPEC uses snake_case fields and lowercase enum values, and the backend
/// serializers follow it; this layer only carries bytes and tokens.
class ApiClient {
  ApiClient({
    http.Client? client,
    TokenStore? tokens,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        tokens = tokens ?? TokenStore(),
        baseUrl = (baseUrl ?? _configuredBaseUrl).replaceAll(RegExp(r'/+$'), '');

  /// Override for a physical device or a deployed server:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000/api`.
  static const _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// With no override the app talks to this repository's own Express server on
  /// the development machine. An Android emulator cannot reach the host as
  /// `127.0.0.1` — that is the emulated phone itself — so it uses the standard
  /// host alias. This is why a device build looked like it was calling some
  /// other, older server: the request never left the phone.
  static String get _configuredBaseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  final http.Client _client;
  final TokenStore tokens;
  final String baseUrl;

  Future<bool>? _refreshing;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) =>
      _send('GET', path, query: query, auth: auth);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    bool auth = true,
  }) =>
      _send('POST', path, body: body, auth: auth);

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    bool auth = true,
  }) =>
      _send('PATCH', path, body: body, auth: auth);

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    bool auth = true,
  }) =>
      _send('PUT', path, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) =>
      _send('DELETE', path, auth: auth);

  Future<Map<String, dynamic>> multipartPost(
    String path, {
    required List<int> fileBytes,
    required String filename,
    required String fieldName,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';

    if (auth) {
      final access = await tokens.readAccess();
      if (access != null && access.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $access';
      }
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = http.MultipartFile.fromBytes(
      fieldName,
      fileBytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ApiException(
        code: 'network_error',
        messageKey: 'stateErrorBody',
      );
    }

    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> decoded = const {};
    if (response.body.isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map<String, dynamic>) decoded = value;
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final messageBn = decoded['message_bn'] as String?;
    final messageEn = decoded['message'] as String?;
    throw ApiException(
      code: decoded['code'] as String? ?? 'server_error',
      serverMessageBn: messageBn,
      serverMessageEn: messageEn,
      statusCode: response.statusCode,
      details: _details(decoded),
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final target = query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (auth) {
      final access = await tokens.readAccess();
      if (access != null && access.isNotEmpty) {
        headers['Authorization'] = 'Bearer $access';
      }
    }

    http.Response response;
    try {
      response = switch (method) {
        'GET' => await _client.get(target, headers: headers).timeout(const Duration(seconds: 25)),
        'POST' => await _client.post(
            target,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ).timeout(const Duration(seconds: 25)),
        'PATCH' => await _client.patch(
            target,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ).timeout(const Duration(seconds: 25)),
        'PUT' => await _client.put(
            target,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ).timeout(const Duration(seconds: 25)),
        'DELETE' => await _client.delete(target, headers: headers)
            .timeout(const Duration(seconds: 25)),
        _ => throw UnsupportedError('Unsupported method $method'),
      };
    } catch (_) {
      throw const ApiException(
        code: 'network_error',
        messageKey: 'stateErrorBody',
      );
    }

    if (response.statusCode == 401 && auth && retry) {
      final refreshed = await _refresh();
      if (refreshed) {
        return _send(
          method,
          path,
          body: body,
          query: query,
          auth: auth,
          retry: false,
        );
      }
    }

    if (response.statusCode == 204) return const {};

    Map<String, dynamic> decoded = const {};
    if (response.body.isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map<String, dynamic>) decoded = value;
      } catch (_) {
        // A proxy or a crash page did not return JSON; the status still tells
        // the caller what happened.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final messageBn = decoded['message_bn'] as String?;
    final messageEn = decoded['message'] as String?;
    throw ApiException(
      code: decoded['code'] as String? ??
          (response.statusCode == 401 ? 'unauthorized' : 'server_error'),
      serverMessageBn: messageBn,
      serverMessageEn: messageEn,
      statusCode: response.statusCode,
      details: _details(decoded),
    );
  }

  static List<Map<String, dynamic>> _details(Map<String, dynamic> decoded) {
    final raw = decoded['details'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<bool> _refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;

    final completer = Completer<bool>();
    _refreshing = completer.future;

    () async {
      try {
        completer.complete(await _performRefresh());
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }

  Future<bool> _performRefresh() async {
    final refresh = await tokens.readRefresh();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 401) {
        await tokens.clear();
        return false;
      }
      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final access = decoded['access'] as String?;
      final nextRefresh = decoded['refresh'] as String?;
      if (access == null || nextRefresh == null) return false;

      await tokens.save(access: access, refresh: nextRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}
