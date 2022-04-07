import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spaniel/spaniel/bloc/file_list.dart';
import 'package:spaniel/spaniel/bloc/search.dart';
import 'package:spaniel/spaniel/widgets/file_card.dart';
import 'package:spaniel/spaniel/widgets/search_result_card.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

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
      return _getFileList(context);
    }
  }

  Widget _getBody(BuildContext context) {
    return _getContents(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: _getBody(context),
    );
  }
}