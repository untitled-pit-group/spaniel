import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/src/file_staged_metadata.dart";
import 'package:spaniel/pifs/parameters/files_edit.dart';
import 'package:spaniel/pifs/util/dartz.dart';

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
class SPFileBlocSetModifiedTags implements SPFileBlocEvent {
  /// The new name to set for the file
  final List<String> tags;
  SPFileBlocSetModifiedTags(this.tags);
}

/// Modify events stage changes for modification, but the changes are commited
/// with a [SPFileBlocSaveChanges] event.
class SPFileBlocSetModifiedRelevanceDate implements SPFileBlocEvent {
  /// The new relevance timestamp. If [null], the timestamp will be cleared.
  final DateTime? relevanceTimestamp;
  SPFileBlocSetModifiedRelevanceDate(this.relevanceTimestamp);
}

/// Remove pending modifications to the relevance date.
class SPFileBlocClearModifiedRelevanceDate implements SPFileBlocEvent {}

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
      stagedMetadata: PifsFileStagedMetadata.blank(),
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

  final Function(SPFileBloc, Error?)? onDelete;

  SPFileBloc(SPFileBlocState initialState, {
    required this.client,
    this.onDelete,
  }) : super(initialState) {
    on<SPFileBlocDownload>(_onDownload);
    on<SPFileBlocDelete>(_onDelete);
    on<SPFileBlocSaveChanges>(_onSaveChanges);
    on<SPFileBlocSetModifiedName>(_onSetModifiedName);
    on<SPFileBlocSetModifiedTags>(_onSetModifiedTags);
    on<SPFileBlocSetModifiedRelevanceDate>(_onSetModifiedRelevanceDate);
    on<SPFileBlocClearModifiedRelevanceDate>(_onClearModifiedRelevanceDate);
  }

  PifsFile? get rawFile => state.file;
  String get currentName =>
    state.stagedMetadata.name.optional ?? state.file?.name ?? "<BUG>";
  List<String> get currentTags =>
    state.stagedMetadata.tags.optional ?? state.file?.tags ?? [];
  DateTime? get currentRelevanceTimestamp =>
    state.stagedMetadata.relevanceTimestamp.optional ?? state.file?.relevanceTimestamp;

  Future<void> _onDownload(SPFileBlocDownload event, Emitter emit) async {
    /// TODO: Don't touch this until we know how the download from will work
    throw UnimplementedError();
  }

  Future<void> _onDelete(SPFileBlocDelete event, Emitter emit) async {
    /// TODO: Don't touch this until we can provide interface for delete
    emit(state.withBusy(true));
    await Future.delayed(const Duration(milliseconds: 500));
    final error = StateError("whoops");
    onDelete?.call(this, error);
    emit(state.withBusy(false));
    // emit(state.withFile(null));
  }

  Future<void> _onSaveChanges(SPFileBlocSaveChanges event, Emitter emit) async {
    emit(state.withBusy(true));

    var editParams = PifsFilesEditParameters.blank(state.file!.id);
    state.stagedMetadata.name.fold(() {}, (name) => editParams.setName(name));
    state.stagedMetadata.tags.fold(() {}, (tags) => editParams.setTags(tags));
    state.stagedMetadata.relevanceTimestamp
      .fold(() {}, (timestamp) => editParams.setRelevanceTimestamp(timestamp));
    
    final editResult = await client.filesEdit(editParams);
    editResult.fold((newFile) {
      emit(state
        .withBusy(false)
        .withFile(newFile)
        .withStagedMetadata(PifsFileStagedMetadata.blank()));
      print("edit succeeded");
    }, (error) {
      // TODO: Throw this back into edit mode
      print("edit failed: $error");
      emit(state.withBusy(false));
      throw error;
    });
  }

  void _onSetModifiedName(SPFileBlocSetModifiedName event, Emitter emit) async {
    emit(state.withStagedMetadata(state.stagedMetadata.withName(event.name)));
  }

  void _onSetModifiedTags(SPFileBlocSetModifiedTags event, Emitter emit) async {
    emit(state.withStagedMetadata(state.stagedMetadata.withTags(event.tags)));
  }

  void _onSetModifiedRelevanceDate(SPFileBlocSetModifiedRelevanceDate event, Emitter emit) async {
    PifsFileStagedMetadata md;
    if (event.relevanceTimestamp == null) {
      md = state.stagedMetadata.withRelevanceTimestamp(event.relevanceTimestamp!);
    } else {
      md = state.stagedMetadata.withWipedRelevanceTimestamp();
    }
    emit(state.withStagedMetadata(md));
  }

  void _onClearModifiedRelevanceDate(SPFileBlocClearModifiedRelevanceDate event, Emitter emit) async {
    var md = state.stagedMetadata.withoutRelevanceTimestamp();
    emit(state.withStagedMetadata(md));
  }
}