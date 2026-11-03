import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/photo_pin.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/photo_pin_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._photos, this._location) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<PinsRestoreRequested>(_onRestore);
    on<PhotosPickRequested>(_onPickRequested);
    on<PinSelected>((e, emit) => emit(state.copyWith(selected: e.pin)));
    on<PinDeselected>((e, emit) => emit(state.copyWith(clearSelected: true)));
  }

  final PhotoPinRepository _photos;
  final LocationRepository _location;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    final loc = await _location.getCurrentLocation();
    if (loc != null) emit(state.copyWith(userLocation: loc));
  }

  Future<void> _onRestore(
    PinsRestoreRequested event,
    Emitter<MapState> emit,
  ) async {
    try {
      final saved = await _photos.loadSaved();
      final known = state.pins.map((p) => p.id).toSet();
      final fresh = saved.where((p) => !known.contains(p.id)).toList();
      if (fresh.isEmpty) return;

      emit(state.copyWith(pins: [...fresh, ...state.pins]));
    } catch (e, st) {
      debugPrint('[restore] failed: $e\n$st');
    }
  }

  Future<void> _onPickRequested(
    PhotosPickRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _photos.pickPhotos();

      final known = state.pins.map((p) => p.id).toSet();
      final fresh = result.pins.where((p) => !known.contains(p.id)).toList();

      emit(
        state.copyWith(
          pins: [...state.pins, ...fresh],
          isLoading: false,
          notice: result.skipped > 0
              ? MapNotice('Без GPS в метаданных: ${result.skipped}')
              : null,
        ),
      );

      if (fresh.isNotEmpty) await _save(fresh);
    } catch (e, st) {
      debugPrint('[pick] failed: $e\n$st');
      emit(
        state.copyWith(
          isLoading: false,
          notice: const MapNotice('Не удалось загрузить фото'),
        ),
      );
    }
  }

  Future<void> _save(List<PhotoPin> pins) async {
    try {
      await _photos.savePins(pins);
    } catch (e, st) {
      debugPrint('[save] failed: $e\n$st');
    }
  }
}
