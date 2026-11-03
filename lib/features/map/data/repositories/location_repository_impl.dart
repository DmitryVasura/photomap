import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  static const _timeout = Duration(seconds: 10);
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: _timeout,
  );

  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      if (!await _ensurePermission()) return null;
      return await _currentOrLastKnown();
    } catch (e) {
      debugPrint('[location] failed: $e');
      return null;
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<LatLng?> _currentOrLastKnown() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[location] current failed, using last known: $e');
      final last = await Geolocator.getLastKnownPosition();
      return last == null ? null : LatLng(last.latitude, last.longitude);
    }
  }
}
