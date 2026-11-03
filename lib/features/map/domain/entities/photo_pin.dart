import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class PhotoPin extends Equatable {
  const PhotoPin({
    required this.id,
    required this.path,
    required this.position,
    this.takenAt,
  });

  final String id;
  final String path;
  final LatLng position;
  final DateTime? takenAt;

  @override
  List<Object?> get props => [id, path, position, takenAt];
}
