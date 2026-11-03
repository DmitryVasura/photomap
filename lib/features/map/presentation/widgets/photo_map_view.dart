import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import '../bloc/map_bloc.dart';
import '../map_config.dart';
import 'photo_marker.dart';
class PhotoMapView extends StatelessWidget {
  const PhotoMapView({super.key, required this.controller});

  static const double _userDotSize = 22;

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MapBloc>();

    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (p, c) =>
          p.pins != c.pins ||
          p.selected != c.selected ||
          p.userLocation != c.userLocation,
      builder: (context, state) {
        // выбранный маркер рисуем последним, чтобы он был сверху
        final ordered = [
          ...state.pins.where((p) => p != state.selected),
          if (state.selected != null) state.selected!,
        ];

        return FlutterMap(
          mapController: controller,
          options: MapOptions(
            crs: const BoundedEpsg3857(),
            initialCenter: MapConfig.initialCenter,
            initialZoom: MapConfig.initialZoom,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
            cameraConstraint:
                CameraConstraint.contain(bounds: MapConfig.worldBounds),
            onTap: (_, _) => bloc.add(const PinDeselected()),
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.tileUrl,
              userAgentPackageName: MapConfig.userAgentPackage,
              maxNativeZoom: MapConfig.maxZoom.toInt(),
              tileBounds: MapConfig.worldBounds,
            ),
            if (state.userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.userLocation!,
                    width: _userDotSize,
                    height: _userDotSize,
                    child: const _UserLocationDot(),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final pin in ordered)
                  Marker(
                    key: ValueKey(pin.id),
                    point: pin.position,
                    width: PhotoMarker.hitBox,
                    height: PhotoMarker.hitBox,
                    child: Center(
                      child: SizedBox.square(
                        dimension: PhotoMarker.size,
                        child: PhotoMarker(
                          pin: pin,
                          selected: pin == state.selected,
                          onTap: () => bloc.add(PinSelected(pin)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  static const double _ring = 4;
  static const double _glowBlur = 10;
  static const double _glowOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.onSurface,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.secondary, width: _ring),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: _glowOpacity),
            blurRadius: _glowBlur,
          ),
        ],
      ),
    );
  }
}