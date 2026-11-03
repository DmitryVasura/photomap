import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/root_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/map/data/datasources/gallery_data_source.dart';
import 'features/map/data/datasources/pin_storage_data_source.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/data/repositories/photo_pin_repository_impl.dart';
import 'features/map/domain/repositories/location_repository.dart';
import 'features/map/domain/repositories/photo_pin_repository.dart';
import 'features/map/presentation/pages/map_page.dart';

class PhotoMapApp extends StatelessWidget {
  const PhotoMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PhotoPinRepository>(
          create: (_) => PhotoPinRepositoryImpl(
            gallery: GalleryDataSource(),
            storage: PinStorageDataSource(),
          ),
        ),
        RepositoryProvider<LocationRepository>(
          create: (_) => LocationRepositoryImpl(),
        ),
      ],
      child: MaterialApp(
        title: 'PhotoMap',
        debugShowCheckedModeBanner: false,
        navigatorKey: rootNavigatorKey,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const MapPage(),
      ),
    );
  }
}
