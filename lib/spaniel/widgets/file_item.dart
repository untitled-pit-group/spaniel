import "package:flutter/material.dart";
import "package:spaniel/pifs/data/file.dart";

class SPFileItem extends StatelessWidget {
  final PifsFile file;

  const SPFileItem({
    required this.file,
    Key? key
  }) : super(key: key);

  Widget _getTagDisplay(BuildContext context) {
    // TODO: Do.
    return const SizedBox.shrink();
  }

  Widget _getFileIcon(BuildContext context) {
    IconData? iconData;

    switch(file.type) {
      case PifsFileType.unknown:
        iconData = Icons.question_mark;
        break;
      case PifsFileType.document:
        iconData = Icons.description;
        break;
      case PifsFileType.plain:
        iconData = Icons.subject;
        break;
      case PifsFileType.media:
        iconData = Icons.perm_media;
        break;
    }

    return Icon(
      iconData,
      size: 48,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(file.name,
                  style: Theme.of(context).textTheme.titleLarge
                ),
                Text(file.uploadTimestamp.toString(),
                    style: Theme.of(context).textTheme.bodySmall
                ),
              ],
            )),
            _getFileIcon(context)
          ],
        ),
      ),
    );
  }
}