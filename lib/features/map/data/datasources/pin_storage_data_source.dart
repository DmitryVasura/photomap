import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/photo_pin.dart';

class StoredPin {
  const StoredPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.takenAt,
  });

  factory StoredPin.fromPin(PhotoPin pin) => StoredPin(
    id: pin.id,
    latitude: pin.position.latitude,
    longitude: pin.position.longitude,
    takenAt: pin.takenAt,
  );

  factory StoredPin.fromJson(Map<String, dynamic> json) => StoredPin(
    id: json['id'] as String,
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lng'] as num).toDouble(),
    takenAt: json['takenAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['takenAt'] as int),
  );

  final String id;
  final double latitude;
  final double longitude;
  final DateTime? takenAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': latitude,
    'lng': longitude,
    'takenAt': takenAt?.millisecondsSinceEpoch,
  };
}

class PinStorageDataSource {
  static const _key = 'saved_pins_v1';

  Future<List<StoredPin>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StoredPin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[storage] corrupted data, ignoring: $e');
      return const [];
    }
  }

  Future<void> upsert(List<StoredPin> pins) async {
    final byId = {for (final p in await load()) p.id: p};
    for (final p in pins) {
      byId[p.id] = p;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(byId.values.map((p) => p.toJson()).toList()),
    );
  }
}
