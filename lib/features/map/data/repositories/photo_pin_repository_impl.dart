import 'package:latlong2/latlong.dart';

import '../../domain/entities/photo_pin.dart';
import '../../domain/repositories/photo_pin_repository.dart';
import '../datasources/gallery_data_source.dart';
import '../datasources/pin_storage_data_source.dart';

class PhotoPinRepositoryImpl implements PhotoPinRepository {
  PhotoPinRepositoryImpl({required this.gallery, required this.storage});

  final GalleryDataSource gallery;
  final PinStorageDataSource storage;

  @override
  Future<PickPhotosResult> pickPhotos() async {
    final photos = await gallery.pick();
    final pins = <PhotoPin>[];
    var skipped = 0;

    for (final p in photos) {
      final pos = p.position;
      if (pos == null) {
        skipped++;
        continue;
      }
      pins.add(
        PhotoPin(id: p.id, path: p.path, position: pos, takenAt: p.takenAt),
      );
    }
    return PickPhotosResult(pins: pins, skipped: skipped);
  }

  @override
  Future<List<PhotoPin>> loadSaved() async {
    final stored = await storage.load();

    final resolved = await Future.wait(
      stored.map((s) async {
        final path = await gallery.resolvePath(s.id);
        if (path == null) return null;
        return PhotoPin(
          id: s.id,
          path: path,
          position: LatLng(s.latitude, s.longitude),
          takenAt: s.takenAt,
        );
      }),
    );

    return resolved.whereType<PhotoPin>().toList();
  }

  @override
  Future<void> savePins(List<PhotoPin> pins) =>
      storage.upsert(pins.map(StoredPin.fromPin).toList());
}
