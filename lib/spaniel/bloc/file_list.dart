import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/spaniel/bloc/file.dart';

abstract class SPFileListEvent {}

class SPFileListReload implements SPFileListEvent {}

class SPFileListState with EquatableMixin {
  final bool isBusy;
  final List<SPFileBloc> files;

  // We're doing a bit of a hack here by mutating the files list directly
  // This saves us a bit of overhead when the list grows larger, but since Bloc
  // depends on object equality to change to determine whether to emit a new state
  // we must provide this workaround.
  final int stateIdx;

  SPFileListState._internal({
    required this.isBusy,
    required this.files,
    required this.stateIdx
  });

  factory SPFileListState.initial() {
    return SPFileListState._internal(
      isBusy: false,
      files: [],
      stateIdx: 0
    );
  }

  SPFileListState withBusy(bool isBusy) {
    return SPFileListState._internal(
      isBusy: isBusy,
      files: files,
      stateIdx: stateIdx
    );
  }

  SPFileListState withFiles(List<SPFileBloc> files) {
    return SPFileListState._internal(
      isBusy: isBusy,
      files: files,
      stateIdx: stateIdx
    );
  }

  @override List<Object?> get props => [isBusy, stateIdx, files];
}

class SPFileList extends Bloc<SPFileListEvent, SPFileListState> {
  final PifsClient client;

  SPFileList({
    required this.client
  }) : super(SPFileListState.initial()) {
    on<SPFileListReload>(_onReloadFiles);
  }

  Future<void> _onReloadFiles(SPFileListReload event, Emitter emit) async {
    emit(state.withBusy(true));
    final files = await client.filesList();
    emit(state.withFiles(files.fold(
      (result) => result.map((f) => SPFileBloc(SPFileBlocState.initial(f), client: client)).toList(),
      (error) => [],
    )).withBusy(false));
  }
}