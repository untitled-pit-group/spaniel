import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/pifs/data/file.dart';
import 'package:spaniel/spaniel/bloc/file.dart';
import 'package:spaniel/spaniel/visual/bytes_formatter.dart';
import 'package:spaniel/spaniel/visual/datetime_formatter.dart';

class SPFileExtendedFragment extends StatelessWidget {
  final SPFileBloc file;
  final Function() onDownload;
  final Function()? onEdit;
  final Function()? onDelete;
  final bool isExpanded;
  final bool isEditing;

  const SPFileExtendedFragment({
    required this.file,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
    required this.isExpanded,
    this.isEditing = false,
    Key? key
  }) : super(key: key);

  DateTime? get editRelevanceTimestamp => file.state.stagedMetadata.relevanceTimestamp.fold(
      () => file.state.file?.relevanceTimestamp,
      (a) => a
  );

  Set<String>? get editTags => file.state.stagedMetadata.tags.fold(
      () => file.state.file?.tags,
      (a) => a
  );

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

  Widget _getTag(BuildContext context, String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: isEditing ? const Icon(Icons.clear) : null,
      onDeleted: isEditing ? () {
        file.add(SPFileBlocRemoveStagedTag(tag));
      } : null,
    );
  }

  Widget _getNewTagChip(BuildContext context) {
    return Chip(
      label: Text("New tag"),
      deleteIcon: isEditing ? const Icon(Icons.add) : null,
      onDeleted: isEditing ? () async {
        final newTag = await _displayNewTagDialog(context);
        if(newTag != null) {
          file.add(SPFileBlocAddStagedTag(newTag));
        }
      } : null,
    );
  }

  Widget _getTagDisplay(BuildContext context, SPFileBlocState state) {
    return Wrap(
      spacing: 8,
      children: [
        if(isEditing) _getNewTagChip(context),
        ...?(isEditing ? editTags : state.file?.tags)?.map((e) => _getTag(context, e))
      ],
    );
  }

  Widget _getDisplayModeContent(BuildContext context, SPFileBlocState state) {
    const dateFormatter = SPReadableDateTimeFormatter();
    const bytesFormatter = SPBytesFormatter();
    final file = state.file;

    if(!isExpanded) {
      return Row(
        children: [
          Expanded(child: _getTagDisplay(context, state)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Uploaded on", style: Theme.of(context).textTheme.bodyMedium),
            Expanded(child: Text(
                dateFormatter.format(file?.uploadTimestamp),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        if (file?.relevanceTimestamp != null) Row(
          children: [
            Text("Relevant on", style: Theme.of(context).textTheme.bodyMedium),
            Expanded(child: Text(
                dateFormatter.format(file?.relevanceTimestamp),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        Row(
          children: [
            Text("File size", style: Theme.of(context).textTheme.bodyMedium),
            Expanded(child: Text(
                bytesFormatter.format(file?.length ?? 0, 2),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        _getTagDisplay(context, state),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: TextButton(
                    onPressed: onDownload,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.download), Text("Download")]
                    ))),
            if (onEdit != null) Expanded(
                child: TextButton(
                    onPressed: onEdit,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.edit), Text("Edit")]
                    ))),
            if (onDelete != null) Expanded(
                child: TextButton(
                    onPressed: onDelete,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.delete), Text("Delete")]
                    ))),
          ],
        )
      ],
    );
  }

  Widget _getEditModeContent(BuildContext context, SPFileBlocState state) {
    const dateFormatter = SPReadableDateTimeFormatter();
    final isSaveable = state.stagedMetadata.isChanged(state.file);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Row(
          children: [
            Expanded(child: Text("Relevance date", style: Theme.of(context).textTheme.titleMedium)),
            Text(dateFormatter.format(editRelevanceTimestamp),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelLarge
            ),
            if (editRelevanceTimestamp == null) const SizedBox(width: 8),
            if (editRelevanceTimestamp != null) IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => file.add(SPFileBlocSetModifiedRelevanceDate(null))
            ),
            OutlinedButton(
              onPressed: () => showDatePicker(
                context: context,
                initialDate: editRelevanceTimestamp ?? DateTime.now(),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.utc(2032),
              ).then((value) {
                if(value != null) {
                  file.add(SPFileBlocSetModifiedRelevanceDate(value));
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (isSaveable && onEdit != null) Expanded(
                child: TextButton(
                    onPressed: () {
                      file.add(SPFileBlocSaveChanges());
                      onEdit!();
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.done), Text("Save")]
                    ))),
            if (onEdit != null) Expanded(
                child: TextButton(
                    onPressed: () {
                      if(isSaveable) file.add(SPFileBlocRevertChanges());
                      onEdit!();
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.close), Text(isSaveable ? "Cancel" : "Close")]
                    ))),
          ],
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SPFileBloc, SPFileBlocState>(
      bloc: file,
      builder: (context, state) {
        if(isEditing) {
          return _getEditModeContent(context, state);
        } else {
          return _getDisplayModeContent(context, state);
        }
      }
    );

  }
}