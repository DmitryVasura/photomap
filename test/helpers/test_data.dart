import 'package:latlong2/latlong.dart';
import 'package:photomap/features/map/domain/entities/photo_pin.dart';

PhotoPin fakePin(String id, {double lat = 45.0, double lng = 9.0}) {
  return PhotoPin(
    id: id,
    path: '/tmp/$id.jpg',
    position: LatLng(lat, lng),
    takenAt: DateTime(2026, 1, 1, 12),
  );
}
