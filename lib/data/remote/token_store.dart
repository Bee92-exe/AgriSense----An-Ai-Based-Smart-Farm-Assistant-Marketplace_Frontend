import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access and refresh tokens.
///
/// Mobile uses the platform keystore/keychain. Web is a development harness
/// only: browser storage cannot protect a token from XSS, so the shipped target
/// is the native app, not the web build.
class TokenStore {
  static const _accessKey = 'auth.access';
  static const _refreshKey = 'auth.refresh';
  static const _secure = FlutterSecureStorage();

  Future<String?> readAccess() => _read(_accessKey);

  Future<String?> readRefresh() => _read(_refreshKey);

  Future<void> save({required String access, required String refresh}) async {
    await _write(_accessKey, access);
    await _write(_refreshKey, refresh);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessKey);
      await prefs.remove(_refreshKey);
      return;
    }
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secure.read(key: key);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _secure.write(key: key, value: value);
  }
}
