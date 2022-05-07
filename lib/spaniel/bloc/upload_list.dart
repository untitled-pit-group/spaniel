import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/upload/uploader.dart';
import 'package:spaniel/spaniel/bloc/upload.dart';

abstract class SPUploadListEvent {}

class SPUploadListAdd implements SPUploadListEvent {
  SPUploadBloc upload;
  SPUploadListAdd(this.upload);
}

class SPUploadListRemove implements SPUploadListEvent {
  SPUploadBloc upload;
  SPUploadListRemove(this.upload);
}

class SPUploadListReload implements SPUploadListEvent {}

class SPUploadListState with EquatableMixin {
  final bool isBusy;
  final List<SPUploadBloc> uploads;

  // We're doing a bit of a hack here by mutating the files list directly
  // This saves us a bit of overhead when the list grows larger, but since Bloc
  // depends on object equality to change to determine whether to emit a new state
  // we must provide this workaround.
  final int stateIdx;

  SPUploadListState._internal({
    required this.isBusy,
    required this.uploads,
    required this.stateIdx
  });

  factory SPUploadListState.initial() {
    return SPUploadListState._internal(
        isBusy: false,
        uploads: [],
        stateIdx: 0
    );
  }

  SPUploadListState withBusy(bool isBusy) {
    return SPUploadListState._internal(
        isBusy: isBusy,
        uploads: uploads,
        stateIdx: stateIdx
    );
  }

  SPUploadListState withUploads(List<SPUploadBloc> uploads) {
    return SPUploadListState._internal(
        isBusy: isBusy,
        uploads: uploads,
        stateIdx: stateIdx
    );
  }

  SPUploadListState withAddedUpload(SPUploadBloc upload) {
    return SPUploadListState._internal(
        isBusy: isBusy,
        uploads: uploads..add(upload),
        stateIdx: stateIdx + 1
    );
  }

  SPUploadListState withRemovedUpload(SPUploadBloc upload) {
    return SPUploadListState._internal(
        isBusy: isBusy,
        uploads: uploads..remove(upload),
        stateIdx: stateIdx + 1
    );
  }

  @override List<Object?> get props => [isBusy, stateIdx, uploads];
}

class SPUploadManager extends Bloc<SPUploadListEvent, SPUploadListState> {
  final PifsClient client;
  final PifsUploader uploader;

  SPUploadManager({
    required this.client,
    required this.uploader
  }) : super(SPUploadListState.initial()) {
    on<SPUploadListReload>(_onReloadUploads);
    on<SPUploadListAdd>(_onAddUpload);
    on<SPUploadListRemove>(_onRemoveUpload);
  }

  Future<void> _onReloadUploads(SPUploadListReload event, Emitter emit) async {
    emit(state.withBusy(true));
    // We only call this on app launch for now, therefore we don't have to be
    // careful with accidentally removing stuff that hasn't synced with FX
    final response = await client.uploadsList();
    response.fold(
      (uploads) => emit(state
          .withBusy(false)
          .withUploads(uploads.map((e) => SPUploadBloc(this, upload: e)).toList())
      ),
      (error) => emit(state.withBusy(false))
    );
  }

  Future<void> _onAddUpload(SPUploadListAdd event, Emitter emit) async {
    emit(state.withAddedUpload(event.upload));
  }

  Future<void> _onRemoveUpload(SPUploadListRemove event, Emitter emit) async {
    emit(state.withRemovedUpload(event.upload));
  }
}