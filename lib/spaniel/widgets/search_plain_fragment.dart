import 'package:dartz/dartz.dart' show Tuple2;
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
    final f = result.fragment;
    final ranges = result.ranges;

    final strs = List<Tuple2<String, bool>>.empty(growable: true);

    for (int i = 0; i < ranges.length; i++) {
      int baseStart = 0;
      int baseEnd = 0;
      int hlStart = ranges[i].start;
      int hlEnd = ranges[i].end+1;

      if(i == 0) {
        baseEnd = ranges[0].start;
      } else {
        baseStart = ranges[i-1].end+1;
        baseEnd = ranges[i].start;
      }

      strs.add(Tuple2(f.substring(baseStart, baseEnd), false));
      strs.add(Tuple2(f.substring(hlStart, hlEnd), true));
    }

    strs.add(Tuple2(f.substring(ranges.last.end+1), false));

    return Text.rich(TextSpan(
      style: const TextStyle(fontSize: 16),
      children: <TextSpan>[
        for (var s in strs) TextSpan(text: s.value1, style: s.value2
          ? TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)
          : const TextStyle(color: Colors.white70)
        )
      ]
    ));
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