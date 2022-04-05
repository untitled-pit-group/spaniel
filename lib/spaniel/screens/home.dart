import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/spaniel/bloc/file_list.dart';
import 'package:spaniel/spaniel/widgets/file_base_fragment.dart';
import 'package:spaniel/spaniel/widgets/file_card.dart';

class SPHome extends StatelessWidget {
  const SPHome({Key? key}) : super(key: key);

  Widget _getFileList(BuildContext context) {
    return BlocBuilder<SPFileList, SPFileListState>(
      builder: (context, state) {
        if(state.isBusy) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
            children: [
              Text("my_files", style: Theme.of(context).textTheme.headlineLarge),
              // Key is required for Flutter to not do weirdness and give
              // the state of the current widget to a different one
              ...state.files.map((e) => SPFileCard(e, key: e.state.file?.id != null ? Key(e.state.file!.id) : null))
            ]
        );
      }
    );
  }

  Widget _getContents(BuildContext context) {
    return _getFileList(context);
  }

  Widget _getBody(BuildContext context) {
    return _getContents(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home_title")
      ),
      body: _getBody(context),
    );
  }
}