import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/src/file_staged_metadata.dart";
import 'package:spaniel/pifs/parameters/parameters.dart';

abstract class SPFileBlocEvent {}

/// Triggers app logic to start a file download in whichever way is
/// appropriate for the platform.
class SPFileBlocDownload implements SPFileBlocEvent {}

/// Prompts the backend to delete the file.
class SPFileBlocDelete implements SPFileBlocEvent {}

/// Modify events stage changes for modification, but the changes are commited
/// with a [SPFileBlocSaveChanges] event.
class SPFileBlocSetModifiedName implements SPFileBlocEvent {
  /// The new name to set for the file
  final String name;
  SPFileBlocSetModifiedName(this.name);
}

/// Modify events stage changes for modification, but the changes are commited
/// with a [SPFileBlocSaveChanges] event.
class SPFileBlocAddStagedTag implements SPFileBlocEvent {
  /// The new name to set for the file
  final String tag;
  SPFileBlocAddStagedTag(this.tag);
}

/// Modify events stage changes for modification, but the changes are commited
/// with a [SPFileBlocSaveChanges] event.
class SPFileBlocRemoveStagedTag implements SPFileBlocEvent {
  /// The new name to set for the file
  final String tag;
  SPFileBlocRemoveStagedTag(this.tag);
}

/// Modify events stage changes for modification, but the changes are commited
/// with a [SPFileBlocSaveChanges] event.
class SPFileBlocSetModifiedRelevanceDate implements SPFileBlocEvent {
  /// The new name to set for the file
  final DateTime? relevanceTimestamp;
  SPFileBlocSetModifiedRelevanceDate(this.relevanceTimestamp);
}

class SPFileBlocRevertChanges implements SPFileBlocEvent {}

class SPFileBlocSaveChanges implements SPFileBlocEvent {}

class SPFileBlocState extends Equatable {
  /// If [true], the file is busy and new events should not be added
  final bool isBusy;

  /// If [null], file is assumed to be deleted, or no file is selected.
  final PifsFile? file;

  /// The staged metadata to apply to [file] on [SPFileBlocSaveChanges]
  final PifsFileStagedMetadata stagedMetadata;

  const SPFileBlocState._internal({
    required this.isBusy,
    required this.file,
    required this.stagedMetadata
  });

  factory SPFileBlocState.initial(PifsFile? file) {
    return SPFileBlocState._internal(
      isBusy: false,
      file: file,
      stagedMetadata: const PifsFileStagedMetadata.blank(),
    );
  }

  SPFileBlocState withFile(PifsFile? file) {
    return SPFileBlocState.initial(file);
  }

  SPFileBlocState withStagedMetadata(PifsFileStagedMetadata stagedMetadata) {
    return SPFileBlocState._internal(
      isBusy: isBusy,
      file: file,
      stagedMetadata: stagedMetadata
    );
  }

  SPFileBlocState withBusy(bool isBusy) {
    return SPFileBlocState._internal(
        isBusy: isBusy,
        file: file,
        stagedMetadata: stagedMetadata
    );
  }

  @override List<Object?> get props => [file, isBusy, stagedMetadata];
}

/// The File Bloc provides a interface through which UI logic interacts with a file
/// The Bloc state will respond to actions to ensure a consistent state in UI
class SPFileBloc extends Bloc<SPFileBlocEvent, SPFileBlocState> {
  final PifsClient client;

  final Function(SPFileBloc)? onDelete;

  SPFileBloc(SPFileBlocState initialState, {
    required this.client,
    this.onDelete,
  }) : super(initialState) {
    on<SPFileBlocDownload>(_onDownload);
    on<SPFileBlocDelete>(_onDelete);
    on<SPFileBlocSaveChanges>(_onSaveChanges);
    on<SPFileBlocRevertChanges>(_onRevertChanges);
    on<SPFileBlocSetModifiedName>(_onSetModifiedName);
    on<SPFileBlocAddStagedTag>(_onAddStagedTag);
    on<SPFileBlocRemoveStagedTag>(_onRemoveStagedTag);
    on<SPFileBlocSetModifiedRelevanceDate>(_onSetModifiedRelevanceDate);
  }

  Future<void> _onDownload(SPFileBlocDownload event, Emitter emit) async {
    /// TODO: Don't touch this until we know how the download from will work
    throw UnimplementedError();
  }

  Future<void> _onDelete(SPFileBlocDelete event, Emitter emit) async {
    /// TODO: Don't touch this until we can provide interface for delete
    emit(state.withBusy(true));
    await Future.delayed(const Duration(milliseconds: 200));
    onDelete?.call(this);
    emit(state.withFile(null));
  }

  Future<void> _onSaveChanges(SPFileBlocSaveChanges event, Emitter emit) async {
    final f = state.file;
    final c = state.stagedMetadata;
    if(f == null) {
      // This is a weird, uncomfortable error condition. Just do nothing.
      return;
    }

    emit(state.withBusy(true));
    final result = await client.filesEdit(PifsFilesEditParameters(
        fileId: f.id,
        name: c.name,
        tags: c.tags,
        relevanceTimestamp: c.relevanceTimestamp
    ));

    result.fold(
      // Server is expected to return the file object with any applied changes
      (file) => emit(SPFileBlocState.initial(file)),
      (error) {
        emit(state.withBusy(false));
        // TODO: Present error to user
        print("An error occurred when editing file: ${error.readableCode}, ${error.serverMessage}");
      }
    );
  }

  void _onRevertChanges(SPFileBlocRevertChanges event, Emitter emit) async {
    emit(state.withStagedMetadata(const PifsFileStagedMetadata.blank()));
  }


  void _onSetModifiedName(SPFileBlocSetModifiedName event, Emitter emit) async {
    emit(state.withStagedMetadata(state.stagedMetadata.withName(event.name)));
  }

  void _onAddStagedTag(SPFileBlocAddStagedTag event, Emitter emit) async {
    state.stagedMetadata.tags.fold(
      () => emit(state.withStagedMetadata(state.stagedMetadata.withTags(
        Set.from(state.file?.tags ?? {})..add(event.tag)
      ))),
      (tags) => emit(state.withStagedMetadata(state.stagedMetadata.withTags(
        Set.from(tags)..add(event.tag)
      )))
    );
  }

  void _onRemoveStagedTag(SPFileBlocRemoveStagedTag event, Emitter emit) async {
    state.stagedMetadata.tags.fold(
      () => emit(state.withStagedMetadata(state.stagedMetadata.withTags(
        Set.from(state.file?.tags ?? {})..remove(event.tag)
      ))),
      (tags) => emit(state.withStagedMetadata(state.stagedMetadata.withTags(
        Set.from(tags)..remove(event.tag)
      )))
    );
  }

  void _onSetModifiedRelevanceDate(SPFileBlocSetModifiedRelevanceDate event, Emitter emit) async {
    emit(state.withStagedMetadata(
      state.stagedMetadata.withRelevanceTimestamp(event.relevanceTimestamp)
    ));
  }
}