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
  TextEditingController titleController = TextEditingController();
  bool isExpanded = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      final f = widget.file.state.file;
      if(f != null && f.name != titleController.text) {
        widget.file.add(SPFileBlocSetModifiedName(titleController.text));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    titleController.text = widget.file.state.file?.name ?? "";
  }

  Widget _getCardContents(BuildContext context, SPFileBlocState state) {
    if(state.file == null) {
      return const Icon(Icons.mood_bad);
    }

    if(state.isBusy) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        SPFileBaseFragment(
          file: state.file!,
          showDates: !isExpanded,
          isEditing: isEditing,
          titleEditController: titleController,
        ),
        SPFileExtendedFragment(
          file: widget.file,
          onDelete: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: const Text("Delete file"),
                content: Text("Are you sure you want to delete ${state.file!.name}?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")
                  ),
                  TextButton(
                    onPressed: () {
                      widget.file.add(SPFileBlocDelete());
                      Navigator.of(context).pop();
                    },
                    child: const Text("Delete")
                  )
                ],
              );
            });
          },
          onEdit: () {
            if(isEditing) {
              // Revert name controller to default name
              // If it ends up being updated, the BlocConsumer will catch it
              titleController.text = state.file?.name ?? "";
            }
            setState(() => isEditing = !isEditing);
          },
          onDownload: () => widget.file.add(SPFileBlocDownload()),
          isExpanded: isExpanded,
          isEditing: isEditing,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
          if(isEditing) return;
          isExpanded = !isExpanded;
        }),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: BlocConsumer<SPFileBloc, SPFileBlocState>(
            bloc: widget.file,
            listenWhen: (previous, current) {
              if(previous.file?.name != current.file?.name) {
                titleController.text = current.file?.name ?? "";
              }
              return false;
            },
            listener: (_, __) {},
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