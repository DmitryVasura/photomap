import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photomap/features/map/domain/entities/photo_pin.dart';
import 'package:photomap/features/map/domain/repositories/location_repository.dart';
import 'package:photomap/features/map/domain/repositories/photo_pin_repository.dart';
import 'package:photomap/features/map/presentation/bloc/map_bloc.dart';

import '../../../../helpers/test_data.dart';

class MockPhotoPinRepository extends Mock implements PhotoPinRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockPhotoPinRepository photos;
  late MockLocationRepository location;

  final a = fakePin('a');
  final b = fakePin('b', lat: 46);
  const milan = LatLng(45.4642, 9.19);

  setUpAll(() {
    registerFallbackValue(<PhotoPin>[]);
  });

  setUp(() {
    photos = MockPhotoPinRepository();
    location = MockLocationRepository();
  });

  MapBloc build() => MapBloc(photos, location);

  group('MapStarted', () {
    blocTest<MapBloc, MapState>(
      'кладёт геолокацию в состояние',
      setUp: () =>
          when(() => location.getCurrentLocation())
              .thenAnswer((_) async => milan),
      build: build,
      act: (b) => b.add(const MapStarted()),
      expect: () => [const MapState(userLocation: milan)],
    );

    blocTest<MapBloc, MapState>(
      'ничего не эмитит, если геолокации нет',
      setUp: () =>
          when(() => location.getCurrentLocation())
              .thenAnswer((_) async => null),
      build: build,
      act: (b) => b.add(const MapStarted()),
      expect: () => <MapState>[],
    );
  });

  group('PinsRestoreRequested', () {
    blocTest<MapBloc, MapState>(
      'добавляет сохранённые пины',
      setUp: () => when(() => photos.loadSaved()).thenAnswer((_) async => [a]),
      build: build,
      act: (b) => b.add(const PinsRestoreRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.pins, 'pins', [a]),
      ],
    );

    blocTest<MapBloc, MapState>(
      'не дублирует уже показанные пины и ставит восстановленные первыми',
      setUp: () =>
          when(() => photos.loadSaved()).thenAnswer((_) async => [a, b]),
      build: build,
      seed: () => MapState(pins: [b]),
      act: (bloc) => bloc.add(const PinsRestoreRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.pins, 'pins', [a, b]),
      ],
    );

    blocTest<MapBloc, MapState>(
      'ничего не эмитит, если новых пинов нет',
      setUp: () => when(() => photos.loadSaved()).thenAnswer((_) async => [a]),
      build: build,
      seed: () => MapState(pins: [a]),
      act: (bloc) => bloc.add(const PinsRestoreRequested()),
      expect: () => <MapState>[],
    );

    blocTest<MapBloc, MapState>(
      'ошибка загрузки не ломает блок',
      setUp: () => when(() => photos.loadSaved()).thenThrow(Exception('boom')),
      build: build,
      act: (b) => b.add(const PinsRestoreRequested()),
      expect: () => <MapState>[],
    );
  });

  group('PhotosPickRequested', () {
    blocTest<MapBloc, MapState>(
      'добавляет пины и сохраняет только новые',
      setUp: () {
        when(
          () => photos.pickPhotos(),
        ).thenAnswer((_) async => PickPhotosResult(pins: [a, b], skipped: 0));
        when(() => photos.savePins(any())).thenAnswer((_) async {});
      },
      build: build,
      seed: () => MapState(pins: [a]),
      act: (bloc) => bloc.add(const PhotosPickRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>().having((s) => s.isLoading, 'isLoading', false).having(
          (s) => s.pins,
          'pins',
          [a, b],
        ),
      ],
      verify: (_) => verify(() => photos.savePins([b])).called(1),
    );

    blocTest<MapBloc, MapState>(
      'показывает уведомление о фото без GPS и ничего не сохраняет',
      setUp: () => when(
        () => photos.pickPhotos(),
      ).thenAnswer((_) async => const PickPhotosResult(pins: [], skipped: 2)),
      build: build,
      act: (b) => b.add(const PhotosPickRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.notice?.message,
              'notice',
              'Без GPS в метаданных: 2',
            ),
      ],
      verify: (_) => verifyNever(() => photos.savePins(any())),
    );

    blocTest<MapBloc, MapState>(
      'ошибка выбора даёт уведомление и снимает загрузку',
      setUp: () => when(() => photos.pickPhotos()).thenThrow(Exception('boom')),
      build: build,
      act: (b) => b.add(const PhotosPickRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.notice?.message,
              'notice',
              'Не удалось загрузить фото',
            ),
      ],
      verify: (_) => verifyNever(() => photos.savePins(any())),
    );

    blocTest<MapBloc, MapState>(
      'ошибка сохранения не убирает пины с карты',
      setUp: () {
        when(() => photos.pickPhotos())
            .thenAnswer((_) async => PickPhotosResult(pins: [a], skipped: 0));
        when(() => photos.savePins(any())).thenThrow(Exception('disk full'));
      },
      build: build,
      act: (b) => b.add(const PhotosPickRequested()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>().having((s) => s.isLoading, 'isLoading', false).having(
          (s) => s.pins,
          'pins',
          [a],
        ),
      ],
    );
  });

  group('выбор пина', () {
    blocTest<MapBloc, MapState>(
      'PinSelected сохраняет выбранный пин',
      build: build,
      seed: () => MapState(pins: [a, b]),
      act: (bloc) => bloc.add(PinSelected(b)),
      expect: () => [
        MapState(pins: [a, b], selected: b),
      ],
    );

    blocTest<MapBloc, MapState>(
      'PinDeselected сбрасывает выбор и оставляет пины',
      build: build,
      seed: () => MapState(pins: [a], selected: a),
      act: (bloc) => bloc.add(const PinDeselected()),
      expect: () => [
        MapState(pins: [a]),
      ],
    );
  });
}
