import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/photo_pin.dart';
import '../bloc/map_bloc.dart';

/// Плашка снизу: выезжает, когда в блоке выбран пин.
class SelectedPhotoSheet extends StatelessWidget {
  const SelectedPhotoSheet({super.key});

  static const _offscreen = Offset(0, 1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (p, c) => p.selected != c.selected,
      builder: (context, state) {
        final pin = state.selected;

        return AnimatedSwitcher(
          duration: AppDurations.normal,
          switchInCurve: AppCurves.enter,
          switchOutCurve: AppCurves.exit,
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween(begin: _offscreen, end: Offset.zero).animate(anim),
            child: child,
          ),
          child: pin == null
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : _PhotoPreviewCard(
                  key: ValueKey(pin.id),
                  pin: pin,
                  onClose: () =>
                      context.read<MapBloc>().add(const PinDeselected()),
                ),
        );
      },
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  const _PhotoPreviewCard({
    super.key,
    required this.pin,
    required this.onClose,
  });

  static const double _imageHeight = 220;
  static const int _imageCacheWidth = 1080;

  final PhotoPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = pin.position;

    return Material(
      color: theme.colorScheme.surface,
      elevation: AppElevation.sheet,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _Handle(color: theme.colorScheme.outlineVariant)),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Image(
                  image: ResizeImage(
                    FileImage(File(pin.path)),
                    width: _imageCacheWidth,
                  ),
                  height: _imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.latitude.toStringAsFixed(5)}, '
                          '${p.longitude.toStringAsFixed(5)}',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (pin.takenAt != null)
                          Text(
                            _format(pin.takenAt!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  '
        '${two(d.hour)}:${two(d.minute)}';
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.color});

  static const double _width = 40;
  static const double _height = 4;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_height / 2),
      ),
    );
  }
}
