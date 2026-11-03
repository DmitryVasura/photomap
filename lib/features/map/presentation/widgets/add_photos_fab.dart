import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_tokens.dart';
import '../bloc/map_bloc.dart';

class AddPhotosFab extends StatelessWidget {
  const AddPhotosFab({super.key});

  static const double _spinnerSize = 20;
  static const double _spinnerStroke = 2;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (p, c) =>
          p.isLoading != c.isLoading || p.selected != c.selected,
      builder: (context, state) {
        return AnimatedScale(
          scale: state.selected == null ? 1 : 0,
          duration: AppDurations.fast,
          child: FloatingActionButton.extended(
            onPressed: state.isLoading
                ? null
                : () =>
                      context.read<MapBloc>().add(const PhotosPickRequested()),
            icon: state.isLoading
                ? const SizedBox.square(
                    dimension: _spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: _spinnerStroke,
                    ),
                  )
                : const Icon(Icons.add_photo_alternate),
            label: const Text('Добавить фото'),
          ),
        );
      },
    );
  }
}
