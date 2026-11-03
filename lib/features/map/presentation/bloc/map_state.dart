part of 'map_bloc.dart';

class MapNotice {
  const MapNotice(this.message);
  final String message;
}

final class MapState extends Equatable {
  const MapState({
    this.pins = const [],
    this.selected,
    this.isLoading = false,
    this.notice,
    this.userLocation,
  });

  final List<PhotoPin> pins;
  final PhotoPin? selected;
  final bool isLoading;
  final MapNotice? notice;
  final LatLng? userLocation;

  MapState copyWith({
    List<PhotoPin>? pins,
    PhotoPin? selected,
    bool clearSelected = false,
    bool? isLoading,
    MapNotice? notice,
    LatLng? userLocation,
  }) {
    return MapState(
      pins: pins ?? this.pins,
      selected: clearSelected ? null : (selected ?? this.selected),
      isLoading: isLoading ?? this.isLoading,
      notice: notice,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [pins, selected, isLoading, notice, userLocation];
}
