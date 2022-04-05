import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/spaniel/bloc/file.dart';
import 'package:spaniel/spaniel/widgets/file_base_fragment.dart';

class SPFileCard extends StatefulWidget {
  final SPFileBloc file;

  const SPFileCard(this.file, {Key? key}) : super(key: key);

  @override
  State<SPFileCard> createState() => _SPFileCardState();
}

class _SPFileCardState extends State<SPFileCard> {
  Widget _getCardContents(BuildContext context, SPFileBlocState state) {
    if(state.file == null) {
      return const Icon(Icons.mood_bad);
    }
    return SPFileBaseFragment(file: state.file!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SPFileBloc, SPFileBlocState>(
          bloc: widget.file,
          builder: (context, state) {
            return _getCardContents(context, state);
          },
        ),
      ),
    );
  }
}