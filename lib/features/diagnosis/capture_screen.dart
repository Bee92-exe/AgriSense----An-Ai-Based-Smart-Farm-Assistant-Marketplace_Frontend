import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/diagnosis_repository.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_providers.dart';

/// Step 1 and 2 of the diagnosis flow: frame the leaf, confirm the photo.
///
/// The tap budget is a requirement, not a nicety: Home → Check crop is one tap,
/// opening the camera is two, using the photo is three, and the result arrives
/// on its own. That is why there is no separate crop-selection screen — the crop
/// chips sit under the shutter where they cost nothing.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _picker = ImagePicker();

  Uint8List? _bytes;
  String? _filename;
  CropType? _crop;
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _filename = file.name;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppL10n.of(context).stateErrorBody);
    }
  }

  /// Uploads the photo.
  ///
  /// The idempotency key is generated once per photo, not once per attempt: a
  /// retry after a timeout must reuse it so the server can recognise the
  /// duplicate (FR-27). The same key is what makes the offline queue safe — the
  /// queued attempt is the *same* upload, not a second one.
  Future<void> _submit() async {
    final bytes = _bytes;
    if (bytes == null) return;

    final clientUuid = const Uuid().v4();
    final photo = PhotoUpload(bytes: bytes, filename: _filename ?? 'leaf.jpg');
    final l = AppL10n.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final diagnosis = await ref.read(diagnosisRepositoryProvider).submit(
            photo,
            clientUuid: clientUuid,
            crop: _crop,
          );
      ref.invalidate(diagnosisHistoryProvider);
      if (!mounted) return;
      context.pushReplacement('${Routes.result}?id=${diagnosis.id}');
    } on ApiException catch (error) {
      // No signal in a field is the expected case, not an error screen: keep the
      // photo and send it when the app next has a connection.
      if (error.code == 'network_error') {
        await ref.read(diagnosisQueueProvider).enqueue(
              photo: photo,
              clientUuid: clientUuid,
              crop: _crop,
            );
        ref.invalidate(diagnosisHistoryProvider);
        if (!mounted) return;
        setState(() {
          _busy = false;
          _bytes = null;
          _filename = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.diagnosisQueuedTitle}\n${l.diagnosisQueuedBody}'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.serverMessageBn ?? l.stateErrorBody;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l.stateErrorBody;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final hasPhoto = _bytes != null;

    return AppScreen(
      title: hasPhoto ? l.diagnosisPreviewTitle : l.diagnosisCaptureTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasPhoto ? l.diagnosisPreviewBody : l.diagnosisCaptureSubtitle,
            style: context.texts.bodyMedium?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.md),
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: p.surfaceSunken,
                borderRadius: Radii.tileAll,
                border: Border.all(color: p.outline, width: p.borderWidth),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasPhoto
                  ? Image.memory(_bytes!, fit: BoxFit.cover)
                  : _FramingGuide(l: l),
            ),
          ),
          const SizedBox(height: Space.md),

          // Crop is optional. Guessing wrong here narrows the model's search
          // space, so "not sure" is a first-class choice rather than a fallback.
          Text(l.diagnosisSelectCrop, style: context.texts.titleSmall),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final crop in const [
                CropType.rice,
                CropType.potato,
                CropType.tomato,
              ])
                ChoiceChip(
                  label: Text(crop.label(l)),
                  selected: _crop == crop,
                  onSelected: (v) => setState(() => _crop = v ? crop : null),
                ),
              ChoiceChip(
                label: Text(l.diagnosisCropUnknown),
                selected: _crop == null,
                onSelected: (_) => setState(() => _crop = null),
              ),
            ],
          ),

          if (!hasPhoto) ...[
            const SizedBox(height: Space.lg),
            AppCard(
              tint: p.surfaceSunken,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tip in [
                    l.diagnosisTipLight,
                    l.diagnosisTipCenter,
                    l.diagnosisTipFocus,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: p.primary,
                          ),
                          const SizedBox(width: Space.xs),
                          Expanded(
                            child: Text(tip, style: context.texts.bodySmall),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: Space.sm),
            Text(
              _error!,
              style: context.texts.bodySmall?.copyWith(color: p.error),
            ),
          ],

          const SizedBox(height: Space.lg),
          if (!hasPhoto) ...[
            AppButton(
              label: l.diagnosisOpenCamera,
              icon: Icons.photo_camera_rounded,
              onPressed: () => _pick(ImageSource.camera),
            ),
            const SizedBox(height: Space.xs),
            AppButton(
              label: l.diagnosisFromGallery,
              tone: AppButtonTone.secondary,
              icon: Icons.photo_library_rounded,
              onPressed: () => _pick(ImageSource.gallery),
            ),
          ] else ...[
            AppButton(
              label: l.diagnosisUsePhoto,
              icon: Icons.cloud_upload_rounded,
              isLoading: _busy,
              onPressed: _submit,
            ),
            const SizedBox(height: Space.xs),
            AppButton(
              label: l.diagnosisRetake,
              tone: AppButtonTone.secondary,
              icon: Icons.refresh_rounded,
              isEnabled: !_busy,
              onPressed: () => setState(() {
                _bytes = null;
                _filename = null;
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Framing guide drawn on an empty viewfinder: a leaf outline plus the tips.
/// Deliberately drawn, not a photo, so it does not imply the app has already
/// seen anything.
class _FramingGuide extends StatelessWidget {
  const _FramingGuide({required this.l});

  final AppL10n l;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, size: 88, color: p.primary),
          const SizedBox(height: Space.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            child: Text(
              l.diagnosisCaptureSubtitle,
              textAlign: TextAlign.center,
              style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
