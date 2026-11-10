import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';

/// Password reset while SMS delivery is deferred.
///
/// The API issues a one-time code in development and prints it to the server
/// log; production refuses the request until a paid SMS provider is configured.
/// The screen never pretends an SMS was sent.
enum _Step { request, verify, done }

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _mobile = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();

  _Step _step = _Step.request;
  bool _busy = false;
  bool _failed = false;
  String? _requestError;

  @override
  void dispose() {
    _mobile.dispose();
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final l = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _failed = false;
      _requestError = null;
    });

    try {
      await ref
          .read(sessionProvider.notifier)
          .requestPasswordReset(_mobile.text.trim());
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = _Step.verify;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _requestError = error.message(locale);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _requestError = l.resetRequestFailed;
      });
    }
  }

  Future<void> _submitReset() async {
    setState(() {
      _busy = true;
      _failed = false;
    });

    final ok = await ref.read(sessionProvider.notifier).resetPassword(
          token: _token.text.trim(),
          newPassword: _password.text,
        );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = !ok;
      _step = ok ? _Step.done : _Step.verify;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(title: Text(l.loginForgot)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(Space.md),
          children: [
            switch (_step) {
              _Step.request => _mobileStep(l),
              _Step.verify => _verifyStep(l),
              _Step.done => _doneStep(l),
            },
          ],
        ),
      ),
    );
  }

  Widget _mobileStep(AppL10n l) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.resetRequestBody,
            style: context.texts.bodyMedium
                ?.copyWith(color: context.palette.onSurfaceMuted),
          ),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: InputDecoration(
              labelText: l.loginMobileLabel,
              hintText: l.loginMobileHint,
              prefixIcon: const Icon(Icons.phone_android_rounded),
              errorText: _requestError,
            ),
          ),
          const SizedBox(height: Space.lg),
          AppButton(
            label: l.resetRequestAction,
            isLoading: _busy,
            onPressed: _mobile.text.trim().length == 11 ? _requestReset : null,
          ),
          const SizedBox(height: Space.xs),
          if (kDebugMode)
            Text(
              l.resetDevNote,
              textAlign: TextAlign.center,
              style: context.texts.bodySmall
                  ?.copyWith(color: context.palette.onSurfaceMuted),
            ),
        ],
      );

  Widget _verifyStep(AppL10n l) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.resetCodeSent(_mobile.text.trim()),
            style: context.texts.bodyMedium
                ?.copyWith(color: context.palette.onSurfaceMuted),
          ),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _token,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
              LengthLimitingTextInputFormatter(200),
            ],
            decoration: InputDecoration(
              labelText: l.resetCodeLabel,
              hintText: l.resetCodeHint,
              prefixIcon: const Icon(Icons.password_rounded),
            ),
          ),
          const SizedBox(height: Space.md),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l.registerPasswordLabel,
              helperText: l.registerPasswordRule,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              errorText: _failed ? l.resetInvalid : null,
            ),
          ),
          const SizedBox(height: Space.lg),
          AppButton(
            label: l.resetSubmit,
            isLoading: _busy,
            onPressed: _submitReset,
          ),
          TextButton(
            onPressed: _requestReset,
            child: Text(l.resetRequestAction),
          ),
        ],
      );

  Widget _doneStep(AppL10n l) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.lg),
          Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: context.palette.primary,
          ),
          const SizedBox(height: Space.md),
          Text(
            l.resetDoneTitle,
            textAlign: TextAlign.center,
            style: context.texts.titleLarge,
          ),
          const SizedBox(height: Space.xs),
          Text(
            l.resetDoneBody,
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium
                ?.copyWith(color: context.palette.onSurfaceMuted),
          ),
          const SizedBox(height: Space.lg),
          AppButton(
            label: l.loginSubmit,
            onPressed: () => context.go(Routes.login),
          ),
        ],
      );
}
