import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';

/// Mobile number and password (decision A5 — OTP is for password reset, not for
/// daily sign-in).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginErrorField { mobile, password, none }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _localError;
  _LoginErrorField _errorField = _LoginErrorField.none;

  @override
  void dispose() {
    _mobile.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_localError != null || _errorField != _LoginErrorField.none) {
      setState(() {
        _localError = null;
        _errorField = _LoginErrorField.none;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l = AppL10n.of(context);
    _clearError();

    final mobile = _mobile.text.trim();
    if (mobile.length != 11 || !mobile.startsWith('01')) {
      setState(() {
        _localError = l.registerMobileRequired;
        _errorField = _LoginErrorField.mobile;
      });
      return;
    }

    if (_password.text.isEmpty) {
      setState(() {
        _localError = l.loginPasswordHint;
        _errorField = _LoginErrorField.password;
      });
      return;
    }

    await ref.read(sessionProvider.notifier).login(
          mobile: mobile,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final session = ref.watch(sessionProvider);

    // A failed login lands here as an AsyncError; the form shows the Bangla
    // message the repository produced.
    final error = session.hasError ? session.error : null;
    final serverErrorText = error is ApiException
        ? _messageFor(error, l)
        : error == null
            ? null
            : l.stateErrorBody;

    String? serverField(String field) => error is ApiException
        ? error.fieldMessage(
            field,
            Localizations.localeOf(context).languageCode,
          )
        : null;
    final mobileError = _errorField == _LoginErrorField.mobile
        ? _localError
        : serverField('mobile');
    final passwordError = _errorField == _LoginErrorField.password
        ? _localError
        : serverField('password');

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text(l.loginTitle)),
      body: AmbientBackdrop(
        mood: AmbienceMood.auth,
        child: SafeArea(
          top: false,
          child: PageReveal(
            child: ListView(
              padding: const EdgeInsets.all(Space.md),
              children: [
                Text(
                  l.loginSubtitle,
                  style:
                      context.texts.bodyMedium?.copyWith(color: p.onSurfaceMuted),
                ),
                const SizedBox(height: Space.lg),
                TextField(
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearError(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    labelText: l.loginMobileLabel,
                    hintText: l.loginMobileHint,
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                    errorText: mobileError,
                  ),
                ),
                const SizedBox(height: Space.md),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  onChanged: (_) => _clearError(),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l.loginPasswordLabel,
                    hintText: l.loginPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      tooltip: l.loginPasswordLabel,
                    ),
                    errorText: passwordError,
                  ),
                ),
                const SizedBox(height: Space.md),
                if (serverErrorText != null &&
                    serverField('mobile') == null &&
                    serverField('password') == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.sm),
                    child: Text(
                      serverErrorText,
                      style: context.texts.bodySmall?.copyWith(color: p.error),
                    ),
                  ),
                AppButton(
                  label: l.loginSubmit,
                  isLoading: session.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: Space.xs),
                TextButton(
                  onPressed: () => context.push(Routes.reset),
                  child: Text(l.loginForgot),
                ),
                const SizedBox(height: Space.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l.obAccountTitle,
                      style: context.texts.bodySmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                    TextButton(
                      onPressed: () => context.push(Routes.register),
                      child: Text(l.obRegister),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageFor(ApiException e, AppL10n l) {
    if (e.code == 'invalid_credentials' || e.code == 'unauthorized') {
      return l.loginFailed;
    }
    if (e.code == 'account_suspended') {
      return l.accountStatusSuspendedBody;
    }
    if (e.serverMessageBn != null && e.serverMessageBn!.isNotEmpty) {
      return e.serverMessageBn!;
    }
    return e.message(Localizations.localeOf(context).languageCode);
  }
}
