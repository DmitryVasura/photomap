import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/photo_pin_repository.dart';
import '../bloc/map_bloc.dart';
import '../map_config.dart';
import '../widgets/add_photos_fab.dart';
import '../widgets/photo_map_view.dart';
import '../widgets/selected_photo_sheet.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          MapBloc(
              ctx.read<PhotoPinRepository>(),
              ctx.read<LocationRepository>(),
            )
            ..add(const MapStarted())
            ..add(const PinsRestoreRequested()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> with TickerProviderStateMixin {
  late final AnimatedMapController _map = AnimatedMapController(
    vsync: this,
    duration: AppDurations.camera,
    curve: AppCurves.camera,
  );

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  // ---- камера ----

  void _fitAll(List<LatLng> points) {
    if (points.isEmpty) return;
    _map.animatedFitCamera(
      cameraFit: CameraFit.coordinates(
        coordinates: points,
        padding: MapConfig.fitPadding,
        maxZoom: MapConfig.fitMaxZoom,
      ),
    );
  }

  void _zoomTo(LatLng point) {
    final current = _map.mapController.camera.zoom;
    _map.animateTo(
      dest: point,
      zoom: math.max(current, MapConfig.selectedMinZoom),
    );
  }

  void _centerOnUser(MapState state) {
    // если пины уже есть, камеру не трогаем
    if (state.pins.isEmpty) {
      _map.animateTo(dest: state.userLocation!, zoom: MapConfig.userZoom);
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listenWhen: (p, c) => p.pins.length != c.pins.length,
          listener: (_, s) => _fitAll(s.pins.map((e) => e.position).toList()),
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (p, c) => c.selected != null && p.selected != c.selected,
          listener: (_, s) => _zoomTo(s.selected!.position),
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (p, c) =>
              c.userLocation != null && p.userLocation != c.userLocation,
          listener: (_, s) => _centerOnUser(s),
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (p, c) => c.notice != null && p.notice != c.notice,
          listener: (ctx, s) => ScaffoldMessenger.of(ctx)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(s.notice!.message))),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            PhotoMapView(controller: _map.mapController),
            const Align(
              alignment: Alignment.bottomCenter,
              child: SelectedPhotoSheet(),
            ),
          ],
        ),
        floatingActionButton: const AddPhotosFab(),
      ),
    );
  }
}
