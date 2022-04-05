import "package:flutter/material.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/spaniel/bloc/file.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:spaniel/spaniel/visual/datetime_formatter.dart";
import "package:spaniel/spaniel/visual/file_type_visual.dart";

/// A screen for displaying details about a specific file. Note that Flutter widgets don't really care
/// about the context in which they are displayed, and if this stops making sense as a screen,
/// we can think about embedding in in some shape or form.
/// Expects the state to be provided
class SPFile extends StatelessWidget {
  const SPFile({Key? key,}) : super(key: key);

  Widget _getBody(BuildContext context, SPFileBlocState state) {
    final typeVisual = fileTypeVisuals[state.file?.type]!;
    final dateFormatter = SPReadableDateTimeFormatter();

    return Column(
      children: [
        Row(
          children: [
            Icon(typeVisual.icon, size: 48),
            Column(
              children: [
                Text("file.details_title", style: Theme.of(context).textTheme.titleLarge),
                Text(typeVisual.name, style: Theme.of(context).textTheme.labelMedium),
                Wrap(
                  children: [...?state.file?.tags.map((e) => Chip(label: Text(e)))],
                )
              ]
            ),
          ],
        ),
        Column(
            children: [
              Text("file.date_uploaded", style: Theme.of(context).textTheme.titleSmall),
              Text(dateFormatter.format(state.file?.uploadTimestamp ?? DateTime.now()), style: Theme.of(context).textTheme.labelMedium),
            ]
        ),
        Column(
            children: [
              Text("file.date_relevant", style: Theme.of(context).textTheme.titleSmall),
              Text(dateFormatter.format(state.file?.relevanceTimestamp ?? DateTime.now()), style: Theme.of(context).textTheme.labelMedium),
            ]
        ),
      ],
    );
  }

  // TODO: Display data about:
  // TODO: file name
  // TODO: file type
  // TODO: upload date
  // TODO: relevance date
  // TODO: current tags
  // TODO: download button
  // TODO: delete button
  // TODO: allow to save changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(BlocProvider.of<SPFileBloc>(context).state.file?.name ?? "file.no_file")
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<SPFileBloc, SPFileBlocState>(
          builder: (context, state) {
            return _getBody(context, state);
          }
        ),
      ),
    );
  }
}