import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart' hide LatLng;

abstract final class AppPickerStyle {
  static const int gridColumns = 4;
  static const int pageSize = 80; // кратно gridColumns
  static const int maxAssets = 50;

  static ThemeData theme(ColorScheme scheme) {
    final base = AssetPicker.themeData(scheme.secondary);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      colorScheme: base.colorScheme.copyWith(
        primary: scheme.primary,
        secondary: scheme.secondary,
        surface: scheme.surface,
        onSurface: scheme.onSurface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
