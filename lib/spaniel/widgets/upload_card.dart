import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/spaniel/bloc/upload.dart';

class SPUploadCard extends StatelessWidget {
  final SPUploadBloc upload;

  const SPUploadCard({
    Key? key,
    required this.upload
  }) : super(key: key);

  Widget _getCardContents(BuildContext context, SPUploadBlocState state) {
    if(state.isBusy) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final u = state.upload;
    if(u == null) {
      return const Icon(Icons.mood_bad);
    }

    return Column(
      children: [
        Text(u.name),
        Text(u.hash),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SPUploadBloc, SPUploadBlocState>(
          bloc: upload,
          builder: (context, state) {
            return AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubicEmphasized,
                child: _getCardContents(context, state)
            );
          },
        )
      ),
    );
  }
}