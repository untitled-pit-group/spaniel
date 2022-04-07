import 'package:flutter/material.dart';
import 'package:spaniel/pifs/data/search_result.dart';

class SPSearchPlainFragment extends StatelessWidget {
  final PifsSearchResult result;

  const SPSearchPlainFragment({
    Key? key,
    required this.result
  }) : super(key: key);

  Widget _getTitle(BuildContext context) {
    return Text(result.fileId,
        style: Theme.of(context).textTheme.titleLarge
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