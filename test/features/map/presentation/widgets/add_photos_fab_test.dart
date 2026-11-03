import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photomap/features/map/presentation/bloc/map_bloc.dart';
import 'package:photomap/features/map/presentation/widgets/add_photos_fab.dart';

import '../../../../helpers/test_data.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  late MockMapBloc bloc;

  setUpAll(() {
    registerFallbackValue(const MapStarted());
    registerFallbackValue(const MapState());
  });

  setUp(() => bloc = MockMapBloc());

  Future<void> pumpFab(WidgetTester tester, MapState state) async {
    whenListen(bloc, const Stream<MapState>.empty(), initialState: state);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MapBloc>.value(
          value: bloc,
          child: const Scaffold(floatingActionButton: AddPhotosFab()),
        ),
      ),
    );
  }

  FloatingActionButton fab(WidgetTester tester) =>
      tester.widget(find.byType(FloatingActionButton));

  testWidgets('тап отправляет PhotosPickRequested', (tester) async {
    await pumpFab(tester, const MapState());

    await tester.tap(find.text('Добавить фото'));

    verify(() => bloc.add(any(that: isA<PhotosPickRequested>()))).called(1);
  });

  testWidgets('во время загрузки кнопка отключена и видна крутилка', (
    tester,
  ) async {
    await pumpFab(tester, const MapState(isLoading: true));

    expect(fab(tester).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('когда пин выбран, кнопка скрыта (scale = 0)', (tester) async {
    await pumpFab(
      tester,
      MapState(pins: [fakePin('a')], selected: fakePin('a')),
    );

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 0);
  });
}
