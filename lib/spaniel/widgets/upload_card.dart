import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/pifs/upload/uploader.dart';
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

    final buttons = _getButtons(context, state);
    final progressBar = _getProgressBar(context, state);

    return Column(
      children: [
        if(progressBar != null) progressBar,
        Text(u.name),
        Text(u.hash),
        if(buttons != null) buttons,
      ],
    );
  }

  Widget? _getProgressBar(BuildContext context, SPUploadBlocState state) {
    if(state.task == null) return null;
    return StreamBuilder<PifsUploadCheckpoint>(
      stream: state.task!.progress,
      builder: (context, snap) {
        if(snap.hasData == false) {
          return const LinearProgressIndicator();
        } else {
          return LinearProgressIndicator(value: snap.requireData.progress);
        }
      }
    );
  }

  Widget? _getButtons(BuildContext context, SPUploadBlocState state) {
    if(state.isBusy) return null;
    if(state.upload == null) return null;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => upload.add(SPUploadBlocCancel()),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Icon(Icons.close), Text("Cancel")]
          )
        )
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