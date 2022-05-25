import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/pifs/upload/uploader.dart';
import 'package:spaniel/spaniel/bloc/upload.dart';
import 'package:spaniel/spaniel/visual/datetime_formatter.dart';

class SPUploadCard extends StatefulWidget {
  final SPUploadBloc upload;

  const SPUploadCard({
    Key? key,
    required this.upload
  }) : super(key: key);

  @override
  State<SPUploadCard> createState() => _SPUploadCardState();
}

class _SPUploadCardState extends State<SPUploadCard> {
  late TextEditingController titleEditController;

  @override
  void initState() {
    super.initState();
    titleEditController = TextEditingController()..addListener(() {
      final wu = widget.upload;
      final f = wu.state.metadata.name.toNullable();
      if(f != titleEditController.text) {
        wu.add(SPUploadBlocSetMetadata(wu.state.metadata.withName(titleEditController.text)));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleEditController.dispose();
  }

  bool isEditing(SPUploadBlocState state) {
    return state.metadataConfirmed == false && state.upload != null;
  }

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
        _getTitle(context, state),
        if(isEditing(state)) _getEditableMetadata(context, state),
        if(progressBar != null) progressBar,
        if(buttons != null) buttons,
      ],
    );
  }

  Widget _getTitle(BuildContext context, SPUploadBlocState state) {
    if(isEditing(state)) {
      return TextField(
        decoration: const InputDecoration(
            isDense: true
        ),
        controller: titleEditController,
      );
    }

    return Text(state.metadata.name.toNullable() ?? "???",
        style: Theme.of(context).textTheme.titleLarge
    );
  }

  Future<String?> _displayNewTagDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New tag'),
          content: TextField(
            controller: _textFieldController,
            maxLength: 40,
            decoration: InputDecoration(hintText: "Enter tag name (e.g. Exam)"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textFieldController,
                builder: (context, value, _) {
                  final t = value.text.trim();
                  return TextButton(
                    child: Text('ADD'),
                    onPressed: t.isEmpty ? null : () {
                      Navigator.pop(context, t);
                    },
                  );
                }
            ),
          ],
        );
      },
    );
  }

  Widget _getTag(BuildContext context, SPUploadBlocState state, String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.clear),
      onDeleted: () => widget.upload.add(SPUploadBlocSetMetadata(state.metadata.withTags(
        state.metadata.tags.fold(() => {}, (a) => Set.from(a)..remove(tag))
      ))),
    );
  }

  Widget _getNewTagChip(BuildContext context, SPUploadBlocState state) {
    return Chip(
      label: Text("New tag"),
      deleteIcon: const Icon(Icons.add),
      onDeleted: () async {
        final newTag = await _displayNewTagDialog(context);
        if(newTag != null) {
          widget.upload.add(SPUploadBlocSetMetadata(state.metadata.withTags(
              state.metadata.tags.fold(() => {newTag}, (a) => Set.from(a)..add(newTag))
          )));
        }
      },
    );
  }

  Widget _getTagDisplay(BuildContext context, SPUploadBlocState state) {
    return Wrap(
      spacing: 8,
      children: [
         _getNewTagChip(context, state),
        ...(state.metadata.tags.toNullable() ?? {}).map((e) => _getTag(context, state, e))
      ],
    );
  }

  Widget _getEditableMetadata(BuildContext context, SPUploadBlocState state) {
    const dateFormatter = SPReadableDateTimeFormatter();

    final currentMetadata = state.metadata;
    final relevanceTimestamp = currentMetadata.relevanceTimestamp.toNullable();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          Row(
            children: [
              Expanded(child: Text("Relevance date", style: Theme.of(context).textTheme.titleMedium)),
              Text(dateFormatter.format(relevanceTimestamp),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge
              ),
              if (relevanceTimestamp == null) const SizedBox(width: 8),
              if (relevanceTimestamp != null) IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => widget.upload.add(SPUploadBlocSetMetadata(
                      currentMetadata.withoutRelevanceTimestamp()
                  ))
              ),
              OutlinedButton(
                  onPressed: () => showDatePicker(
                    context: context,
                    initialDate: relevanceTimestamp ?? DateTime.now(),
                    firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                    lastDate: DateTime.utc(2032),
                  ).then((value) {
                    if(value != null) {
                      widget.upload.add(SPUploadBlocSetMetadata(
                          currentMetadata.withRelevanceTimestamp(value)
                      ));
                    }
                  }),
                  child: Text("Choose")
              )
            ],
          ),
          const Divider(),
          Text("Tags", style: Theme.of(context).textTheme.titleMedium),
          _getTagDisplay(context, state),
          const Divider(),
        ]
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
        Expanded(
          child: TextButton(
            onPressed: () => widget.upload.add(SPUploadBlocCancel()),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [Icon(Icons.close), Text("Cancel upload")]
            )
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              widget.upload.add(SPUploadSetMetadataConfirmed(isEditing(state)));
            },
            child: isEditing(state) ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.done), Text("Save")]
            ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.edit), Text("Edit")]
            )
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SPUploadBloc, SPUploadBlocState>(
          bloc: widget.upload,
          buildWhen: (previous, current) {
            if(previous.upload != current.upload) {
              // Upload has started, which also means that base metadata must be initialized
              titleEditController.text = current.metadata.name.fold(
                () => "Unknown",
                (a) => a
              );
            }
            return true;
          },
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