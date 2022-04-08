import "package:flutter/material.dart";
import "package:spaniel/pifs/data/file.dart";
import 'package:spaniel/spaniel/visual/datetime_formatter.dart';
import 'package:spaniel/spaniel/visual/file_type_visual.dart';

class SPFileBaseFragment extends StatelessWidget {
  final PifsFile file;
  final bool showDates;
  final bool isEditing;
  final TextEditingController titleEditController;

  const SPFileBaseFragment({
    required this.file,
    required this.titleEditController,
    this.showDates = true,
    this.isEditing = false,
    Key? key
  }) : super(key: key);

  Widget _getFileIcon(BuildContext context) {
    IconData iconData = fileTypeVisuals[file.type]!.icon;
    return Icon(
      iconData,
      size: 40,
    );
  }

  Widget _getTitle(BuildContext context) {
    if(isEditing) {
      return TextField(
        decoration: const InputDecoration(
          isDense: true
        ),
        controller: titleEditController,
      );
    }

    return Text(file.name,
        style: Theme.of(context).textTheme.titleLarge
    );
  }

  Widget _getSubtitle(BuildContext context) {
    const dateFormatter = SPReadableDateTimeFormatter();

    Widget? leading;
    String text = "";

    if(file.indexingState != PifsIndexingState.indexed) {
      if (file.indexingState == PifsIndexingState.error) {
        leading = Icon(Icons.error, size: 12, color: Theme.of(context).colorScheme.primary,);
        text = "Error during indexing";
      } else {
        leading = const SizedBox(width: 10,
            height: 10,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        switch (file.indexingState) {
          case PifsIndexingState.waitingForProcessing:
            text = "Waiting for processing...";
            break;
          case PifsIndexingState.parsing:
            text = "Parsing...";
            break;
          case PifsIndexingState.pendingTranscription:
            text = "Pending transcription...";
            break;
          case PifsIndexingState.pendingIndexing:
            text = "Pending indexing...";
            break;
          case PifsIndexingState.indexed:
          case PifsIndexingState.error:
            break;
        }
      }
    } else {
      if(showDates == false) {
        return const SizedBox.shrink();
      }

      if(file.relevanceTimestamp != null) {
        text = "Relevant on ${dateFormatter.format(file.relevanceTimestamp)}";
      } else {
        text = "Uploaded on ${dateFormatter.format(file.uploadTimestamp)}";
      }
    }

    return Row(
      children: [
        if (leading != null) Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: leading,
        ),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubicEmphasized,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _getTitle(context),
                  if (!isEditing) _getSubtitle(context)
                ],
              ),
              ),
            ),
            _getFileIcon(context)
          ],
        ),
      ],
    );
  }
}