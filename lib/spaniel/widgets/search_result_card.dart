import 'package:flutter/material.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/data/search_result.dart';
import 'package:spaniel/pifs/parameters/src/files_get.dart';
import 'package:spaniel/spaniel/bloc/file.dart';
import 'package:spaniel/spaniel/widgets/file_extended_fragment.dart';
import 'package:spaniel/spaniel/widgets/search_plain_fragment.dart';

class SPSearchResultCard extends StatefulWidget {
  final PifsSearchResult result;
  final PifsClient client;

  const SPSearchResultCard({
    Key? key,
    required this.result,
    required this.client
  }) : super(key: key);

  @override
  State<SPSearchResultCard> createState() => _SPSearchResultCardState();
}

class _SPSearchResultCardState extends State<SPSearchResultCard> {
  bool isExpanded = false;
  SPFileBloc? file;

  @override
  void initState() {
    super.initState();
    _refreshFile();
  }

  Widget _getExpandedContents(BuildContext context) {
    if(file == null) return const SizedBox.shrink();
    return SPFileExtendedFragment(
      file: file!,
      onDownload: () => file!.add(SPFileBlocDownload()),
      onEdit: null,
      onDelete: null,
      isExpanded: true
    );
  }

  void _refreshFile() async {
    final result = await widget.client.filesGet(PifsFilesGetParameters(widget.result.fileId));
    if(!mounted) {
      return;
    }
    result.fold(
      (f) {
          setState(() {
            file = SPFileBloc(SPFileBlocState.initial(f), client: widget.client);
          });
        },
      (e) => print("big bad $e")
    );
  }

  Widget _getCardContents(BuildContext context) {
    if(widget.result is PifsPlainSearchResult) {
      return SPSearchPlainFragment(result: widget.result, file: file);
    }
    if(widget.result is PifsDocumentSearchResult) {
      return SPSearchPlainFragment(result: widget.result, file: file);
    }
    if(widget.result is PifsMediaSearchResult) {
      return SPSearchPlainFragment(result: widget.result, file: file);
    }
    return SPSearchPlainFragment(result: widget.result, file: file);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _getCardContents(context),
                if (isExpanded) const Divider(),
                if (isExpanded) _getExpandedContents(context)
              ],
            )
          )
        ),
      ),
    );
  }
}