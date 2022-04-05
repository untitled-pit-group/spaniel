import 'package:flutter/material.dart';
import 'package:spaniel/pifs/data/file.dart';
import 'package:spaniel/spaniel/visual/bytes_formatter.dart';
import 'package:spaniel/spaniel/visual/datetime_formatter.dart';


class SPFileExtendedFragment extends StatelessWidget {
  final PifsFile file;
  final Function() onDownload;
  final Function() onEdit;
  final Function() onDelete;
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

  Widget _getTagDisplay(BuildContext context) {
    return Wrap(
      children: [...file.tags.map((e) => Chip(label: Text(e)))],
    );
  }

  Widget _getDisplayModeContent(BuildContext context) {
    const dateFormatter = SPReadableDateTimeFormatter();
    const bytesFormatter = SPBytesFormatter();

    if(!isExpanded) {
      return Row(
        children: [
          Expanded(child: _getTagDisplay(context)),
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
                dateFormatter.format(file.uploadTimestamp),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        if (file.relevanceTimestamp != null) Row(
          children: [
            Text("Relevant on", style: Theme.of(context).textTheme.bodyMedium),
            Expanded(child: Text(
                dateFormatter.format(file.relevanceTimestamp),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        Row(
          children: [
            Text("File size", style: Theme.of(context).textTheme.bodyMedium),
            Expanded(child: Text(
                bytesFormatter.format(file.length, 2),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge))
          ],
        ),
        _getTagDisplay(context),
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
            Expanded(
                child: TextButton(
                    onPressed: onEdit,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.edit), Text("Edit")]
                    ))),
            Expanded(
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

  Widget _getEditModeContent(BuildContext context) {
    const dateFormatter = SPReadableDateTimeFormatter();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Row(
          children: [
            Expanded(child: Text("Relevance date", style: Theme.of(context).textTheme.titleMedium)),
            Text(dateFormatter.format(file.relevanceTimestamp),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelLarge
            ),
            OutlinedButton(
              onPressed: () => showDatePicker(
                  context: context,
                  initialDate: file.relevanceTimestamp ?? DateTime.now(),
                  firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime.utc(2032)
              ),
              child: Text("Choose")
            )
          ],
        ),
        const Divider(),
        Text("Tags", style: Theme.of(context).textTheme.titleMedium),
        _getTagDisplay(context),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: TextButton(
                    onPressed: onEdit,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.done), Text("Done")]
                    ))),
            Expanded(
                child: TextButton(
                    onPressed: onEdit,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.close), Text("Cancel")]
                    ))),
          ],
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    if(isEditing) {
      return _getEditModeContent(context);
    } else {
      return _getDisplayModeContent(context);
    }
  }
}