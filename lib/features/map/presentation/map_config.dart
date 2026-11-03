import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract final class MapConfig {
  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgentPackage = 'com.example.photomap';

  static const initialCenter = LatLng(45.4642, 9.19);
  static const double initialZoom = 5;

  static const double minZoom = 3;
  static const double maxZoom = 19;

  static final worldBounds = LatLngBounds(
    const LatLng(-85.05, -180),
    const LatLng(85.05, 180),
  );

  static const double userZoom = 13;
  static const double selectedMinZoom = 16;
  static const double fitMaxZoom = 15;
  static const fitPadding = EdgeInsets.fromLTRB(80, 120, 80, 120);
}

class BoundedEpsg3857 extends Epsg3857 {
  const BoundedEpsg3857();

  @override
  bool get replicatesWorldLongitude => false;
}
