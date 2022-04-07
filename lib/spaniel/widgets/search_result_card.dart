import 'package:flutter/material.dart';
import 'package:spaniel/pifs/data/search_result.dart';
import 'package:spaniel/spaniel/widgets/search_plain_fragment.dart';

class SPSearchResultCard extends StatefulWidget {
  final PifsSearchResult result;

  const SPSearchResultCard({
    Key? key,
    required this.result
  }) : super(key: key);

  @override
  State<SPSearchResultCard> createState() => _SPSearchResultCardState();
}

class _SPSearchResultCardState extends State<SPSearchResultCard> {
  bool isExpanded = false;

  Widget _getCardContents(BuildContext context) {
    if(widget.result is PifsPlainSearchResult) {
      return SPSearchPlainFragment(result: widget.result);
    }
    if(widget.result is PifsDocumentSearchResult) {
      return SPSearchPlainFragment(result: widget.result);
    }
    if(widget.result is PifsMediaSearchResult) {
      return SPSearchPlainFragment(result: widget.result);
    }
    return SPSearchPlainFragment(result: widget.result);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
          isExpanded = !isExpanded;
        }),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubicEmphasized,
            child: _getCardContents(context)
          )
        ),
      ),
    );
  }
}