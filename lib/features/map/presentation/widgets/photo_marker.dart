import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/photo_pin.dart';

class PhotoMarker extends StatelessWidget {
  const PhotoMarker({
    super.key,
    required this.pin,
    required this.selected,
    required this.onTap,
  });

  static const double size = 60;
  static const double hitBox = size * 1.3;

  static const double _ring = 3;
  static const double _selectedScale = 1.25;
  static const int _cacheWidth = 160;

  static const double _blurRest = 8;
  static const double _blurSelected = 16;
  static const double _shadowOpacity = 0.54;
  static const double _glowOpacity = 0.7;
  static const _shadowOffset = Offset(0, 3);

  final PhotoPin pin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? _selectedScale : 1,
        duration: AppDurations.fast,
        curve: AppCurves.pop,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.all(_ring),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? scheme.secondary : scheme.onSurface,
            boxShadow: [
              BoxShadow(
                color: selected
                    ? scheme.primary.withValues(alpha: _glowOpacity)
                    : scheme.shadow.withValues(alpha: _shadowOpacity),
                blurRadius: selected ? _blurSelected : _blurRest,
                offset: _shadowOffset,
              ),
            ],
          ),
          child: ClipOval(
            child: Image(
              image: ResizeImage(FileImage(File(pin.path)), width: _cacheWidth),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
