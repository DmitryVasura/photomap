part of 'map_bloc.dart';

sealed class MapEvent {
  const MapEvent();
}

final class PhotosPickRequested extends MapEvent {
  const PhotosPickRequested();
}

final class PinSelected extends MapEvent {
  const PinSelected(this.pin);
  final PhotoPin pin;
}

final class PinDeselected extends MapEvent {
  const PinDeselected();
}

final class MapStarted extends MapEvent {
  const MapStarted();
}

final class PinsRestoreRequested extends MapEvent {
  const PinsRestoreRequested();
}
