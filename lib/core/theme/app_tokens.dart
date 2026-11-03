import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

abstract final class AppRadius {
  static const double md = 12;
  static const double lg = 16;
  static const double sheet = 24;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const camera = Duration(milliseconds: 600);
}

abstract final class AppCurves {
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const camera = Curves.easeInOutCubic;
  static const pop = Curves.easeOutBack;
}

abstract final class AppElevation {
  static const double fab = 6;
  static const double sheet = 12;
}
