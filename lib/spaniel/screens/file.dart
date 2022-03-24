import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:spaniel/spaniel/bloc/file.dart";
import "package:flutter_bloc/flutter_bloc.dart";

/// A screen for displaying details about a specific file. Note that Flutter widgets don't really care
/// about the context in which they are displayed, and if this stops making sense as a screen,
/// we can think about embedding in in some shape or form.
/// Expects the state to be provided
class SPFile extends StatelessWidget {
  const SPFile({Key? key,}) : super(key: key);

  Widget _getBody(BuildContext context) {
    return Column(
        children: [
          Text("file.details_title".tr, style: Get.theme.textTheme.titleLarge),

        ]
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
          title: Text(BlocProvider.of<SPFileBloc>(context).state.file?.name ?? "file.no_file".tr)
      ),
      body: BlocBuilder<SPFileBloc, SPFileBlocState>(
        builder: (context, state) {
          return _getBody(context);
        }
      ),
    );
  }
}