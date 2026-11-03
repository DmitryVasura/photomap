import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photomap/features/map/data/datasources/gallery_data_source.dart';
import 'package:photomap/features/map/data/datasources/pin_storage_data_source.dart';
import 'package:photomap/features/map/data/repositories/photo_pin_repository_impl.dart';

import '../../../../helpers/test_data.dart';

class MockGallery extends Mock implements GalleryDataSource {}

class MockStorage extends Mock implements PinStorageDataSource {}

void main() {
  late MockGallery gallery;
  late MockStorage storage;
  late PhotoPinRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<StoredPin>[]);
  });

  setUp(() {
    gallery = MockGallery();
    storage = MockStorage();
    repository = PhotoPinRepositoryImpl(gallery: gallery, storage: storage);
  });

  group('pickPhotos', () {
    test('разделяет фото с GPS и без', () async {
      when(() => gallery.pick()).thenAnswer(
        (_) async => const [
          PickedPhoto(id: 'a', path: '/a.jpg', position: LatLng(1, 2)),
          PickedPhoto(id: 'b', path: '/b.jpg'),
          PickedPhoto(id: 'c', path: '/c.jpg'),
        ],
      );

      final result = await repository.pickPhotos();

      expect(result.pins.map((p) => p.id), ['a']);
      expect(result.pins.single.position, const LatLng(1, 2));
      expect(result.skipped, 2);
    });

    test('пустой выбор даёт пустой результат', () async {
      when(() => gallery.pick()).thenAnswer((_) async => const []);

      final result = await repository.pickPhotos();

      expect(result.pins, isEmpty);
      expect(result.skipped, 0);
    });
  });

  group('loadSaved', () {
    test('подставляет актуальный путь и пропускает недоступные фото', () async {
      when(() => storage.load()).thenAnswer(
        (_) async => const [
          StoredPin(id: 'a', latitude: 1, longitude: 2),
          StoredPin(id: 'b', latitude: 3, longitude: 4),
        ],
      );
      when(() => gallery.resolvePath('a'))
          .thenAnswer((_) async => '/fresh/a.jpg');
      when(() => gallery.resolvePath('b')).thenAnswer((_) async => null);

      final pins = await repository.loadSaved();

      expect(pins, hasLength(1));
      expect(pins.single.id, 'a');
      expect(pins.single.path, '/fresh/a.jpg');
      expect(pins.single.position, const LatLng(1, 2));
    });
  });

  group('savePins', () {
    test('передаёт в хранилище id и координаты, без путей', () async {
      when(() => storage.upsert(any())).thenAnswer((_) async {});

      await repository.savePins([fakePin('a', lat: 7, lng: 8)]);

      final captured =
          verify(() => storage.upsert(captureAny())).captured.single
              as List<StoredPin>;
      expect(captured.single.id, 'a');
      expect(captured.single.latitude, 7);
      expect(captured.single.longitude, 8);
    });
  });
}
