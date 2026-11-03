import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart' hide LatLng;

import '../../../../core/navigation/root_navigator.dart';
import '../../../../core/theme/app_picker_style.dart';

class PickedPhoto {
  const PickedPhoto({
    required this.id,
    required this.path,
    this.position,
    this.takenAt,
  });

  final String id;
  final String path;
  final LatLng? position;
  final DateTime? takenAt;
}

class GalleryDataSource {
  Future<List<PickedPhoto>> pick() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return const [];

    final scheme = Theme.of(context).colorScheme;

    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: AppPickerStyle.maxAssets,
        gridCount: AppPickerStyle.gridColumns,
        pageSize: AppPickerStyle.pageSize,
        pickerTheme: AppPickerStyle.theme(scheme),
        textDelegate: const RussianAssetPickerTextDelegate(),
      ),
    );
    if (assets == null || assets.isEmpty) return const [];

    final result = <PickedPhoto>[];
    for (final asset in assets) {
      try {
        final file = await asset.originFile ?? await asset.file;
        if (file == null) continue;

        LatLng? position;
        try {
          final ll = await asset.latlngAsync();
          final lat = ll?.latitude;
          final lng = ll?.longitude;
          if (lat != null && lng != null && !(lat == 0 && lng == 0)) {
            position = LatLng(lat, lng);
          }
        } catch (e) {
          debugPrint('[pick] latlng failed for ${asset.id}: $e');
        }

        result.add(
          PickedPhoto(
            id: asset.id,
            path: file.path,
            position: position,
            takenAt: asset.createDateTime,
          ),
        );
      } catch (e) {
        debugPrint('[pick] asset ${asset.id} failed: $e');
      }
    }
    return result;
  }

  Future<String?> resolvePath(String id) async {
    try {
      final asset = await AssetEntity.fromId(id);
      if (asset == null) return null;
      final file = await asset.originFile ?? await asset.file;
      return file?.path;
    } catch (e) {
      debugPrint('[gallery] resolve $id failed: $e');
      return null;
    }
  }
}
