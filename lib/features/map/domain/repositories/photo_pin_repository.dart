import '../entities/photo_pin.dart';

class PickPhotosResult {
  const PickPhotosResult({required this.pins, required this.skipped});

  final List<PhotoPin> pins;
  final int skipped;
}

abstract interface class PhotoPinRepository {
  Future<PickPhotosResult> pickPhotos();

  Future<List<PhotoPin>> loadSaved();

  Future<void> savePins(List<PhotoPin> pins);
}
