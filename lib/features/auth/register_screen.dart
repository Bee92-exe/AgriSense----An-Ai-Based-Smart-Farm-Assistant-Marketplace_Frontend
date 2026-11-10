import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/labels.dart';
import '../../data/reference/locations.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';

/// Registration. The role chosen here decides which extra fields appear and
/// whether the account lands in the waiting room (decision A7: all roles,
/// including farmers, need admin approval).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// Identifies which input field carries an active validation error.
enum _ErrorField {
  name,
  mobile,
  district,
  password,
  shopName,
  license,
  specialization,
  certification,
  none,
}

/// Common passwords that must be rejected to prevent trivial brute-forcing.
const _commonPasswords = {
  '12345678',
  '123456789',
  '1234567890',
  'password',
  'password1',
  'password123',
  'passw0rd',
  'qwerty123',
  'letmein',
  'iloveyou',
  'welcome1',
  'admin123',
  'abc12345',
  '11111111',
  '00000000',
  'bangladesh',
  'agrisense',
  'farmer123',
  'vendor123',
  'expert123',
};

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _shopName = TextEditingController();
  final _license = TextEditingController();
  final _specialization = TextEditingController();
  final _certification = TextEditingController();

  Role _role = Role.farmer;
  String? _district;
  bool _obscure = true;
  String? _localError;
  _ErrorField _errorField = _ErrorField.none;

  @override
  void dispose() {
    for (final c in [
      _name,
      _mobile,
      _password,
      _shopName,
      _license,
      _specialization,
      _certification,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setFieldError(_ErrorField field, String message) {
    setState(() {
      _localError = message;
      _errorField = field;
    });
  }

  void _clearError() {
    if (_localError != null || _errorField != _ErrorField.none) {
      setState(() {
        _localError = null;
        _errorField = _ErrorField.none;
      });
    }
  }

  Future<void> _submit() async {
    final l = AppL10n.of(context);
    _clearError();

    // 1. Name validation
    final nameTrimmed = _name.text.trim();
    if (nameTrimmed.isEmpty) {
      _setFieldError(_ErrorField.name, l.registerNameRequired);
      return;
    }
    if (nameTrimmed.length < 2) {
      _setFieldError(_ErrorField.name, 'নাম কমপক্ষে ২ অক্ষরের হতে হবে।');
      return;
    }

    // 2. Mobile validation
    final mobileTrimmed = _mobile.text.trim();
    if (mobileTrimmed.length != 11 || !mobileTrimmed.startsWith('01')) {
      _setFieldError(_ErrorField.mobile, l.registerMobileRequired);
      return;
    }

    // 3. District validation
    if (_district == null) {
      _setFieldError(_ErrorField.district, l.registerDistrictRequired);
      return;
    }

    // 4. Password validations (Strong password rules)
    final pass = _password.text;
    if (pass.length < 8) {
      _setFieldError(_ErrorField.password, l.registerPasswordRule);
      return;
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(pass)) {
      _setFieldError(_ErrorField.password, 'পাসওয়ার্ডে অন্তত একটি অক্ষর দিন।');
      return;
    }
    if (!RegExp(r'\d').hasMatch(pass)) {
      _setFieldError(_ErrorField.password, 'পাসওয়ার্ডে অন্তত একটি সংখ্যা দিন।');
      return;
    }
    if (RegExp(r'^\d+$').hasMatch(pass)) {
      _setFieldError(_ErrorField.password, l.registerPasswordWeak);
      return;
    }
    if (_commonPasswords.contains(pass.toLowerCase())) {
      _setFieldError(_ErrorField.password, l.registerPasswordCommon);
      return;
    }
    final national = mobileTrimmed.length >= 10
        ? mobileTrimmed.substring(mobileTrimmed.length - 10)
        : mobileTrimmed;
    if (pass.contains(mobileTrimmed) ||
        (national.isNotEmpty && pass.contains(national))) {
      _setFieldError(_ErrorField.password, l.registerPasswordHasMobile);
      return;
    }
    final nameLower = nameTrimmed.toLowerCase();
    if (nameLower.length >= 3 && pass.toLowerCase().contains(nameLower)) {
      _setFieldError(
          _ErrorField.password, 'পাসওয়ার্ডে নিজের নাম ব্যবহার করা যাবে না।');
      return;
    }

    // 5. Role-specific validations
    if (_role == Role.vendor && _shopName.text.trim().isEmpty) {
      _setFieldError(_ErrorField.shopName, 'দোকানের নাম লিখুন।');
      return;
    }
    if (_role == Role.vendor && _license.text.trim().isEmpty) {
      _setFieldError(_ErrorField.license, 'ট্রেড লাইসেন্স নম্বর লিখুন।');
      return;
    }
    if (_role == Role.expert && _specialization.text.trim().isEmpty) {
      _setFieldError(_ErrorField.specialization, 'কোন বিষয়ে বিশেষজ্ঞ তা লিখুন।');
      return;
    }
    if (_role == Role.expert && _certification.text.trim().isEmpty) {
      _setFieldError(_ErrorField.certification, 'সনদ বা যোগ্যতার তথ্য লিখুন।');
      return;
    }

    final user = await ref.read(sessionProvider.notifier).register(
          RegisterRequest(
            name: nameTrimmed,
            mobile: mobileTrimmed,
            password: pass,
            role: _role,
            district: _district!,
            shopName: _role == Role.vendor ? _shopName.text.trim() : null,
            licenseNo: _role == Role.vendor ? _license.text.trim() : null,
            specialization:
                _role == Role.expert ? _specialization.text.trim() : null,
            certification:
                _role == Role.expert ? _certification.text.trim() : null,
          ),
        );

    if (!mounted) return;
    if (user != null && user.needsApproval) {
      context.go(Routes.pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final serverError = session.hasError ? session.error : null;

    final isMobileConflict = serverError is ApiException &&
        (serverError.code == 'conflict' || serverError.code == 'mobile_taken');

    String? serverField(String field) => serverError is ApiException
        ? serverError.fieldMessage(
            field,
            Localizations.localeOf(context).languageCode,
          )
        : null;

    // Resolve field-level error texts (local validation takes priority, then server)
    final nameError =
        _errorField == _ErrorField.name ? _localError : serverField('name');
    final mobileError = _errorField == _ErrorField.mobile
        ? _localError
        : (isMobileConflict ? l.phoneRegistered : serverField('mobile'));
    final districtError =
        _errorField == _ErrorField.district ? _localError : serverField('district');
    final passwordError =
        _errorField == _ErrorField.password ? _localError : serverField('password');
    final shopNameError =
        _errorField == _ErrorField.shopName ? _localError : serverField('shop_name');
    final licenseError =
        _errorField == _ErrorField.license ? _localError : serverField('license_no');
    final specializationError =
        _errorField == _ErrorField.specialization
            ? _localError
            : serverField('specialization');
    final certificationError =
        _errorField == _ErrorField.certification
            ? _localError
            : serverField('certification');

    // General error note at bottom: shown for server-level or unmapped errors
    String? generalError;
    if (_localError != null && _errorField == _ErrorField.none) {
      generalError = _localError;
    } else if (serverError != null &&
        !isMobileConflict &&
        !(serverError is ApiException && serverError.details.isNotEmpty)) {
      if (serverError is ApiException) {
        generalError = serverError.serverMessageBn ??
            (serverError.code == 'validation_error'
                ? 'তথ্যগুলো আবার দেখুন — কিছু ঘরে সমস্যা আছে।'
                : serverError.message(
                    Localizations.localeOf(context).languageCode,
                  ));
      } else {
        generalError = l.stateErrorBody;
      }
    }

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text(l.registerTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(Space.md),
          children: [
            Text(
              l.registerAs(_role.label(l)),
              style: context.texts.labelLarge?.copyWith(color: p.primary),
            ),
            const SizedBox(height: Space.md),
            _RolePicker(
              selected: _role,
              onChanged: (r) => setState(() {
                _role = r;
                _clearError();
              }),
            ),
            const SizedBox(height: Space.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: p.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.registerApprovalNote,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.lg),

            // 1. Name Field
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearError(),
              decoration: InputDecoration(
                labelText: l.registerNameLabel,
                hintText: l.registerNameHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                errorText: nameError,
              ),
            ),
            const SizedBox(height: Space.md),

            // 2. Mobile Field
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

            // 3. District Field
            DropdownButtonFormField<String>(
              initialValue: _district,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.registerDistrictLabel,
                prefixIcon: const Icon(Icons.place_outlined),
                errorText: districtError,
              ),
              hint: Text(l.registerDistrictHint),
              items: [
                for (final d in kDistricts)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() {
                _district = v;
                _clearError();
              }),
            ),
            const SizedBox(height: Space.md),

            // 4. Password Field
            TextField(
              controller: _password,
              obscureText: _obscure,
              onChanged: (_) => setState(() {
                _localError = null;
                _errorField = _ErrorField.none;
              }),
              decoration: InputDecoration(
                labelText: l.registerPasswordLabel,
                hintText: l.registerPasswordHint,
                helperText: l.registerPasswordRule,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                errorText: passwordError,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
            ),
            if (_password.text.isNotEmpty) ...[
              const SizedBox(height: Space.xxs),
              _PasswordStrength(strength: _passwordStrength(_password.text)),
            ],

            // Vendor-specific fields
            if (_role == Role.vendor) ...[
              const SizedBox(height: Space.md),
              TextField(
                controller: _shopName,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: l.registerShopNameLabel,
                  prefixIcon: const Icon(Icons.storefront_rounded),
                  errorText: shopNameError,
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _license,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: l.registerLicenseLabel,
                  prefixIcon: const Icon(Icons.description_outlined),
                  errorText: licenseError,
                ),
              ),
            ],

            // Expert-specific fields
            if (_role == Role.expert) ...[
              const SizedBox(height: Space.md),
              TextField(
                controller: _specialization,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: l.registerSpecializationLabel,
                  prefixIcon: const Icon(Icons.workspace_premium_outlined),
                  errorText: specializationError,
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _certification,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: l.registerCertificationLabel,
                  prefixIcon: const Icon(Icons.verified_outlined),
                  errorText: certificationError,
                ),
              ),
            ],

            const SizedBox(height: Space.lg),

            // General error banner (if not attached to a single input field)
            if (generalError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: _ErrorNote(text: generalError),
              ),

            AppButton(
              label: l.registerSubmit,
              isLoading: session.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: Space.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l.registerAlreadyHave,
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.login),
                  child: Text(l.obLogin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.selected, required this.onChanged});

  final Role selected;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    // Admin is deliberately absent: admin accounts come from a seed, never from
    // public registration (decision A7).
    const roles = [Role.farmer, Role.vendor, Role.expert];
    final icons = {
      Role.farmer: Icons.agriculture_rounded,
      Role.vendor: Icons.storefront_rounded,
      Role.expert: Icons.school_rounded,
    };
    final hints = {
      Role.farmer: l.roleFarmerHint,
      Role.vendor: l.roleVendorHint,
      Role.expert: l.roleExpertHint,
    };

    return Column(
      children: [
        for (final role in roles)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Semantics(
              selected: selected == role,
              button: true,
              label: role.label(l),
              child: Material(
                color: selected == role ? p.primaryContainer : p.surface,
                borderRadius: Radii.cardAll,
                child: InkWell(
                  borderRadius: Radii.cardAll,
                  onTap: () => onChanged(role),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 72),
                    padding: const EdgeInsets.all(Space.sm),
                    decoration: BoxDecoration(
                      borderRadius: Radii.cardAll,
                      border: Border.all(
                        color: selected == role ? p.primary : p.outline,
                        width: selected == role
                            ? p.borderWidth + 1
                            : p.borderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icons[role],
                          size: 28,
                          color: selected == role
                              ? p.onPrimaryContainer
                              : p.onSurfaceMuted,
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                role.label(l),
                                style: context.texts.titleSmall?.copyWith(
                                  color: selected == role
                                      ? p.onPrimaryContainer
                                      : p.onSurface,
                                ),
                              ),
                              Text(
                                hints[role]!,
                                style: context.texts.bodySmall?.copyWith(
                                  color: selected == role
                                      ? p.onPrimaryContainer
                                      : p.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected == role
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected == role
                              ? p.primary
                              : p.onSurfaceMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

int _passwordStrength(String value) {
  if (value.isEmpty) return 0;
  var score = 0;
  if (value.length >= 8) score++;
  if (RegExp(r'[A-Za-z]').hasMatch(value) && RegExp(r'\d').hasMatch(value)) {
    score++;
  }
  if (value.length >= 12 || RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
  return score.clamp(0, 3);
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final label = switch (strength) {
      >= 3 => english ? 'Strong password' : 'শক্তিশালী পাসওয়ার্ড',
      2 => english ? 'Medium password' : 'মাঝারি পাসওয়ার্ড',
      _ => english ? 'Weak password' : 'দুর্বল পাসওয়ার্ড',
    };
    final color = strength >= 3
        ? p.success
        : strength == 2
            ? p.primary
            : p.error;

    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? color : p.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 4),
        ],
        const SizedBox(width: Space.xs),
        Text(
          label,
          style: context.texts.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: p.errorContainer,
        borderRadius: Radii.fieldAll,
        border: Border.all(color: p.error, width: p.borderWidth),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: p.error),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(
              text,
              style:
                  context.texts.bodySmall?.copyWith(color: p.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
