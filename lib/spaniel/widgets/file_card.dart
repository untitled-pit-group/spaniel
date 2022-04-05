import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/spaniel/bloc/file.dart';
import 'package:spaniel/spaniel/widgets/file_base_fragment.dart';
import 'package:spaniel/spaniel/widgets/file_extended_fragment.dart';

class SPFileCard extends StatefulWidget {
  final SPFileBloc file;

  const SPFileCard(this.file, {Key? key}) : super(key: key);

  @override
  State<SPFileCard> createState() => _SPFileCardState();
}

class _SPFileCardState extends State<SPFileCard> {
  bool isExpanded = false;

  Widget _getCardContents(BuildContext context, SPFileBlocState state) {
    if(state.file == null) {
      return const Icon(Icons.mood_bad);
    }
    return Column(
      children: [
        SPFileBaseFragment(file: state.file!, showDates: !isExpanded),
        if(isExpanded) SPFileExtendedFragment(
          file: state.file!,
          onDelete: () => print("Delete"),
          onEdit: () => print("Edit"),
          onDownload: () => print("Download")
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: BlocBuilder<SPFileBloc, SPFileBlocState>(
            bloc: widget.file,
            builder: (context, state) {
              return AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubicEmphasized,
                child: _getCardContents(context, state)
              );
            },
          ),
        ),
      ),
    );
  }
}