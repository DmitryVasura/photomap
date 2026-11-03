import 'package:latlong2/latlong.dart';

abstract interface class LocationRepository {
  Future<LatLng?> getCurrentLocation();
}
