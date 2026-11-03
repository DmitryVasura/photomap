import 'package:flutter_test/flutter_test.dart';
import 'package:photomap/features/map/data/datasources/pin_storage_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PinStorageDataSource storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = PinStorageDataSource();
  });

  group('StoredPin', () {
    test('сериализуется туда и обратно', () {
      final stored = StoredPin.fromPin(fakePin('a', lat: 1.5, lng: 2.5));
      final restored = StoredPin.fromJson(stored.toJson());

      expect(restored.id, 'a');
      expect(restored.latitude, 1.5);
      expect(restored.longitude, 2.5);
      expect(restored.takenAt, DateTime(2026, 1, 1, 12));
    });

    test('дата съёмки может отсутствовать', () {
      const stored = StoredPin(id: 'a', latitude: 1, longitude: 2);
      final restored = StoredPin.fromJson(stored.toJson());

      expect(restored.takenAt, isNull);
    });
  });

  group('PinStorageDataSource', () {
    test('пустое хранилище возвращает пустой список', () async {
      expect(await storage.load(), isEmpty);
    });

    test('сохраняет и загружает пины', () async {
      await storage.upsert([
        StoredPin.fromPin(fakePin('a')),
        StoredPin.fromPin(fakePin('b')),
      ]);

      final loaded = await storage.load();
      expect(loaded.map((p) => p.id), unorderedEquals(['a', 'b']));
    });

    test('upsert добавляет, а не перезаписывает всё хранилище', () async {
      await storage.upsert([StoredPin.fromPin(fakePin('a'))]);
      await storage.upsert([StoredPin.fromPin(fakePin('b'))]);

      final loaded = await storage.load();
      expect(loaded.map((p) => p.id), unorderedEquals(['a', 'b']));
    });

    test('upsert обновляет запись с тем же id', () async {
      await storage.upsert([StoredPin.fromPin(fakePin('a', lat: 1))]);
      await storage.upsert([StoredPin.fromPin(fakePin('a', lat: 50))]);

      final loaded = await storage.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.latitude, 50);
    });

    test('повреждённые данные игнорируются', () async {
      SharedPreferences.setMockInitialValues({'saved_pins_v1': 'not json'});

      expect(await PinStorageDataSource().load(), isEmpty);
    });
  });
}
