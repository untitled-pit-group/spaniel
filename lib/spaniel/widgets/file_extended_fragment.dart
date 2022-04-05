import 'package:flutter/material.dart';
import 'package:spaniel/pifs/data/file.dart';
import 'package:spaniel/spaniel/visual/bytes_formatter.dart';
import 'package:spaniel/spaniel/visual/datetime_formatter.dart';

class SPFileExtendedFragment extends StatelessWidget {
  final PifsFile file;
  final Function() onDownload;
  final Function() onEdit;
  final Function() onDelete;

  const SPFileExtendedFragment({
    required this.file,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dateFormatter = SPReadableDateTimeFormatter();
    const bytesFormatter = SPBytesFormatter();

    return Column(
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
}