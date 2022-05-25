import 'package:flutter/material.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/data/search_result.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';
import 'package:spaniel/spaniel/bloc/file.dart';

class SPSearchPlainFragment extends StatelessWidget {
  final PifsSearchResult result;
  final SPFileBloc? file;

  const SPSearchPlainFragment({
    Key? key,
    required this.result,
    required this.file,
  }) : super(key: key);

  Widget _getTitle(BuildContext context) {
    if(file?.state.file == null) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: 20,
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 3))),
      );
    }
    return Text(file!.state.file!.name,
        style: Theme.of(context).textTheme.titleLarge
    );
  }

  Widget _getResult(BuildContext context) {
    return Text(result.fragment);
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
                    _getResult(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}