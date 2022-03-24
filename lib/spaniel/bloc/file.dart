import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/src/file_staged_metadata.dart";

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
  /// The new name to set for the file
  final DateTime? relevanceTimestamp;
  SPFileBlocSetModifiedRelevanceDate(this.relevanceTimestamp);
}

class SPFileBlocSaveChanges implements SPFileBlocEvent {}

class SPFileBlocState extends Equatable {
  /// If [null], file is assumed to be deleted, or no file is selected.
  final PifsFile? file;

  /// The staged metadata to apply to [file] on [SPFileBlocSaveChanges]
  final PifsFileStagedMetadata stagedMetadata;

  const SPFileBlocState._internal({
    required this.file,
    required this.stagedMetadata
  });

  factory SPFileBlocState.initial(PifsFile? file) {
    return SPFileBlocState._internal(
      file: file,
      stagedMetadata: PifsFileStagedMetadata.initial(file)
    );
  }

  SPFileBlocState withFile(PifsFile? file) {
    return SPFileBlocState.initial(file);
  }

  SPFileBlocState withStagedMetadata(PifsFileStagedMetadata stagedMetadata) {
    return SPFileBlocState._internal(
      file: file,
      stagedMetadata: stagedMetadata
    );
  }

  @override List<Object?> get props => [file];
}

/// The File Bloc provides a interface through which UI logic interacts with a file
/// The Bloc state will respond to actions to ensure a consistent state in UI
class SPFileBloc extends Bloc<SPFileBlocEvent, SPFileBlocState> {
  final PifsClient client;

  SPFileBloc(SPFileBlocState initialState, {
    required this.client
  }) : super(initialState) {
    on<SPFileBlocDownload>(_onDownload);
    on<SPFileBlocDelete>(_onDelete);
    on<SPFileBlocSaveChanges>(_onSaveChanges);
    on<SPFileBlocSetModifiedName>(_onSetModifiedName);
    on<SPFileBlocSetModifiedTags>(_onSetModifiedTags);
    on<SPFileBlocSetModifiedRelevanceDate>(_onSetModifiedRelevanceDate);
  }

  Future<void> _onDownload(SPFileBlocDownload event, Emitter emit) async {
    /// TODO: Don't touch this until we know how the download from will work
    throw UnimplementedError();
  }

  Future<void> _onDelete(SPFileBlocDelete event, Emitter emit) async {
    /// TODO: Don't touch this until we can provide interface for delete
    throw UnimplementedError();
  }

  Future<void> _onSaveChanges(SPFileBlocSaveChanges event, Emitter emit) async {
    throw UnimplementedError();
  }

  void _onSetModifiedName(SPFileBlocSetModifiedName event, Emitter emit) async {
    throw UnimplementedError();
  }

  void _onSetModifiedTags(SPFileBlocSetModifiedTags event, Emitter emit) async {
    throw UnimplementedError();
  }

  void _onSetModifiedRelevanceDate(SPFileBlocSetModifiedRelevanceDate event, Emitter emit) async {
    throw UnimplementedError();
  }
}