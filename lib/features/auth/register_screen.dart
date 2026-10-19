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
import '../../data/mock/mock_seed.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';

/// Registration. The role chosen here decides which extra fields appear and
/// whether the account lands in the waiting room (decision A7: vendor and expert
/// need admin approval).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

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

  Future<void> _submit() async {
    final l = AppL10n.of(context);
    setState(() => _localError = null);

    if (_name.text.trim().isEmpty) {
      setState(() => _localError = l.registerNameLabel);
      return;
    }
    if (_mobile.text.trim().length != 11) {
      setState(() => _localError = l.loginMobileHint);
      return;
    }
    if (_password.text.length < 8) {
      setState(() => _localError = l.registerPasswordRule);
      return;
    }
    if (_district == null) {
      setState(() => _localError = l.registerDistrictHint);
      return;
    }

    final user = await ref.read(sessionProvider.notifier).register(
          RegisterRequest(
            name: _name.text.trim(),
            mobile: _mobile.text.trim(),
            password: _password.text,
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
    final error = session.hasError ? session.error : null;

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
              onChanged: (r) => setState(() => _role = r),
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
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l.registerNameLabel,
                hintText: l.registerNameHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                labelText: l.loginMobileLabel,
                hintText: l.loginMobileHint,
                prefixIcon: const Icon(Icons.phone_android_rounded),
              ),
            ),
            const SizedBox(height: Space.md),
            DropdownButtonFormField<String>(
              initialValue: _district,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.registerDistrictLabel,
                prefixIcon: const Icon(Icons.place_outlined),
              ),
              hint: Text(l.registerDistrictHint),
              items: [
                for (final d in kDistricts)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => _district = v),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l.registerPasswordLabel,
                hintText: l.registerPasswordHint,
                helperText: l.registerPasswordRule,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
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
            if (_role == Role.vendor) ...[
              const SizedBox(height: Space.md),
              TextField(
                controller: _shopName,
                decoration: InputDecoration(
                  labelText: l.registerShopNameLabel,
                  prefixIcon: const Icon(Icons.storefront_rounded),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _license,
                decoration: InputDecoration(
                  labelText: l.registerLicenseLabel,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
            ],
            if (_role == Role.expert) ...[
              const SizedBox(height: Space.md),
              TextField(
                controller: _specialization,
                decoration: InputDecoration(
                  labelText: l.registerSpecializationLabel,
                  prefixIcon: const Icon(Icons.workspace_premium_outlined),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _certification,
                decoration: InputDecoration(
                  labelText: l.registerCertificationLabel,
                  prefixIcon: const Icon(Icons.verified_outlined),
                ),
              ),
            ],
            const SizedBox(height: Space.lg),
            if (_localError != null || error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: _ErrorNote(
                  text: _localError ??
                      (error is ApiException
                          ? (error.code == 'conflict'
                              ? l.loginFailed
                              : l.stateErrorBody)
                          : l.stateErrorBody),
                ),
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
