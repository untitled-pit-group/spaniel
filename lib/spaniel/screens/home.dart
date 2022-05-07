import 'dart:io';

import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/pifs/support/flutter.dart';
import 'package:spaniel/spaniel/bloc/file_list.dart';
import 'package:spaniel/spaniel/bloc/search.dart';
import 'package:spaniel/spaniel/bloc/upload.dart';
import 'package:spaniel/spaniel/bloc/upload_list.dart';
import 'package:spaniel/spaniel/widgets/file_card.dart';
import 'package:spaniel/spaniel/widgets/search_result_card.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:spaniel/spaniel/widgets/upload_card.dart';

class SPHome extends StatefulWidget {
  const SPHome({Key? key}) : super(key: key);

  @override
  State<SPHome> createState() => _SPHomeState();
}

class _SPHomeState extends State<SPHome> {
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text('home_title'),
        actions: [searchBar.getSearchAction(context)]
    );
  }

  late final SearchBar searchBar;
  final TextEditingController searchBoxController = TextEditingController();

  bool inSearch = false;

  @override
  void initState() {
    super.initState();

    searchBar = SearchBar(
        inBar: false,
        setState: setState,
        controller: searchBoxController,
        buildDefaultAppBar: buildAppBar
    );

    searchBoxController.addListener(() {
      setState(() {
        // TODO: Throttling (can also be done in bloc side with an event transformer)
        if(searchBoxController.text.isNotEmpty) {
          BlocProvider.of<SPSearchBloc>(context).add(SPSearchSearchEvent(searchBoxController.text));
        }
        inSearch = searchBoxController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchBoxController.dispose();
  }

  Widget _getMainList(BuildContext context) {
    return BlocBuilder<SPUploadManager, SPUploadListState>(
      builder: (context, uploadState) => BlocBuilder<SPFileList, SPFileListState>(
        builder: (context, fileState) {
          if(fileState.isBusy) {
            return const Center(child: CircularProgressIndicator());
          }

          Iterable<Widget> fileWidgets = [const CircularProgressIndicator()];
          if(!fileState.isBusy) {
            // Key is required for Flutter to not do weirdness and give
            // the state of the current widget to a different one
            fileWidgets = fileState.files.map((e) => SPFileCard(e,
                key: e.state.file?.id != null ? Key(e.state.file!.id) : null));
          }

          // Key is required for Flutter to not do weirdness and give
          // the state of the current widget to a different one
          Iterable<Widget> uploadWidgets = uploadState.uploads.map((e) => SPUploadCard(upload: e,
              key: e.state.upload?.id != null ? Key(e.state.upload!.id.raw) : null));

          return ListView(
              children: [
                if(uploadWidgets.isNotEmpty) Text("active_uploads", style: Theme.of(context).textTheme.headlineLarge),
                ...uploadWidgets,
                Text("my_files", style: Theme.of(context).textTheme.headlineLarge),
                ...fileWidgets
              ]
          );
        }
      ),
    );
  }

  Widget _getSearchResultList(BuildContext context) {
    return BlocBuilder<SPSearchBloc, SPSearchState>(
      builder: (context, state) {
        if(state.isBusy) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: [
            Text("search_results", style: Theme.of(context).textTheme.headlineLarge),
            // Key is required for Flutter to not do weirdness and give
            // the state of the current widget to a different one
            ...state.results.map((e) => SPSearchResultCard(result: e))
          ]
        );
      }
    );
  }

  Widget _getContents(BuildContext context) {
    if(inSearch) {
      return _getSearchResultList(context);
    } else {
      return _getMainList(context);
    }
  }

  Widget _getBody(BuildContext context) {
    return _getContents(context);
  }

  Future<void> _onUpload(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      final manager = BlocProvider.of<SPUploadManager>(context);
      final uploader = SPUploadBloc(manager);
      manager.add(SPUploadListAdd(uploader));
      uploader.add(SPUploadBlocBegin(file.path));
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: _getBody(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () => _onUpload(context),
      ),
    );
  }
}