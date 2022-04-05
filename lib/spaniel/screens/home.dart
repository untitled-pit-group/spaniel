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
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("my_files", style: Theme.of(context).textTheme.headlineLarge),
              ...state.files.map((e) => SPFileCard(e))
            ]
        );
      }
    );
  }

  Widget _getContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _getFileList(context)
      ],
    );
  }

  Widget _getBody(BuildContext context) {
    return SingleChildScrollView(
      child: _getContents(context)
    );
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