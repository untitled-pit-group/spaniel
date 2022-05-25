import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:quiver/iterables.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/data/src/file_staged_metadata.dart';
import 'package:spaniel/pifs/data/upload.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';
import 'package:spaniel/pifs/upload/uploader.dart';
import 'package:spaniel/spaniel/bloc/upload_list.dart';

abstract class SPUploadBlocEvent {}

class SPUploadBlocBegin implements SPUploadBlocEvent {
  final String fileName;
  final int fileLength;
  final Either<String, Stream<List<int>>> pathOrStream;
  const SPUploadBlocBegin(
      {required this.fileName,
      required this.fileLength,
      required this.pathOrStream});
}

class _SPUploadBlocUpload implements SPUploadBlocEvent {}

class SPUploadBlocSetMetadata implements SPUploadBlocEvent {
  final PifsFileStagedMetadata metadata;
  SPUploadBlocSetMetadata(this.metadata);
}

class SPUploadBlocCancel implements SPUploadBlocEvent {}

class SPUploadSetMetadataConfirmed implements SPUploadBlocEvent {
  final bool confirmed;
  SPUploadSetMetadataConfirmed(this.confirmed);
}

class _SPUploadBlocFinish implements SPUploadBlocEvent {}

class SPUploadBlocState with EquatableMixin {
  // Using the state variables, one should be able to figure out whether
  // this upload is initiated locally or is a remote response to uploads in progress
  final bool isBusy;
  final bool isUploaded;
  final Either<String, Uint8List>? pathOrBytes;
  final int? fileSize;
  final bool metadataConfirmed;
  final PifsFileStagedMetadata metadata;
  final PifsUpload? upload;
  final PifsUploadTask? task;

  const SPUploadBlocState._internal(
      {required this.isBusy,
      required this.isUploaded,
      required this.pathOrBytes,
      required this.fileSize,
      required this.metadataConfirmed,
      required this.metadata,
      required this.upload,
      required this.task});

  factory SPUploadBlocState.initial(PifsUpload? upload) {
    return SPUploadBlocState._internal(
        isBusy: false,
        isUploaded: false,
        pathOrBytes: null,
        fileSize: null,
        metadataConfirmed: false,
        metadata: const PifsFileStagedMetadata.blank()..withName(upload?.name ?? ""),
        upload: upload,
        task: null);
  }

  SPUploadBlocState apply({
    Option<bool> isBusy = const None(),
    Option<bool> isUploaded = const None(),
    Option<Either<String, Uint8List>?> pathOrBytes = const None(),
    Option<int?> fileSize = const None(),
    Option<bool> metadataConfirmed = const None(),
    Option<PifsFileStagedMetadata> metadata = const None(),
    Option<PifsUpload?> upload = const None(),
    Option<PifsUploadTask?> task = const None(),
  }) {
    return SPUploadBlocState._internal(
      isBusy: isBusy.fold(() => this.isBusy, (a) => a),
      isUploaded: isUploaded.fold(() => this.isUploaded, (a) => a),
      pathOrBytes: pathOrBytes.fold(() => this.pathOrBytes, (a) => a),
      fileSize: fileSize.fold(() => this.fileSize, (a) => a),
      metadataConfirmed:
          metadataConfirmed.fold(() => this.metadataConfirmed, (a) => a),
      metadata: metadata.fold(() => this.metadata, (a) => a),
      upload: upload.fold(() => this.upload, (a) => a),
      task: task.fold(() => this.task, (a) => a),
    );
  }

  @override
  List<Object?> get props =>
      [isBusy, isUploaded, pathOrBytes, upload, task, fileSize, metadata, metadataConfirmed];
}

class SPUploadBloc extends Bloc<SPUploadBlocEvent, SPUploadBlocState> {
  final SPUploadManager manager;

  SPUploadBloc(this.manager, {PifsUpload? upload})
      : super(SPUploadBlocState.initial(upload)) {
    on<SPUploadBlocBegin>(_onUploadBegin);
    on<_SPUploadBlocUpload>(_onUploadUpload);
    on<SPUploadBlocCancel>(_onUploadCancel);
    on<_SPUploadBlocFinish>(_onUploadFinish);
    on<SPUploadBlocSetMetadata>(
        (event, emit) => emit(state.apply(metadata: Some(event.metadata))));
    on<SPUploadSetMetadataConfirmed>((event, emit) {
      emit(state.apply(metadataConfirmed: Some(event.confirmed)));
      if(state.isUploaded) {
        add(_SPUploadBlocFinish());
      }
    });
  }

  Future<void> _onUploadBegin(SPUploadBlocBegin event, Emitter emit) async {
    emit(state.apply(isBusy: const Some(true)));

    // Prepare a [PifsUploadBeginParameters] and request starting the upload
    final chunks = event.pathOrStream
        .fold((path) => File(path).openRead(), (stream) => stream)
        .map((x) => x as Uint8List);

    final hashOutput = AccumulatorSink<Digest>();
    final hashInput = sha256.startChunkedConversion(hashOutput);

    var uploadableBytes =
        event.pathOrStream.isRight() ? List<int>.empty(growable: true) : null;

    await chunks.forEach((e) {
      hashInput.add(e);
      uploadableBytes?.addAll(e);
    });
    hashInput.close();

    var hashDigest = hashOutput.events.single.toString();
    print(hashDigest);

    final fileSize = event.fileLength;
    final fileName = event.fileName;

    final parameters =
        PifsUploadsBeginParameters(hashDigest, fileSize, fileName);
    final response = await manager.client.uploadBegin(parameters);

    response.fold((upload) {
      print("Upload has begun: ${upload.id.raw}");
      emit(state.apply(
          isBusy: const Some(false),
          pathOrBytes: Some(event.pathOrStream.fold((l) => Left(l),
              (r) => Right(Uint8List.fromList(uploadableBytes!)))),
          fileSize: Some(event.fileLength),
          metadata: Some(
              const PifsFileStagedMetadata.blank().withName(event.fileName)),
          upload: Some(upload)));
      add(_SPUploadBlocUpload());
    }, (error) {
      print("There was an error beginning the upload: $error");
      emit(state.apply(isBusy: const Some(false)));
    });
  }

  Future<void> _onUploadUpload(_SPUploadBlocUpload event, Emitter emit) async {
    Uri? target;
    if (state.upload is PifsTargetableUpload) {
      target = (state.upload as PifsTargetableUpload).uploadUrl;
    }
    if (state.pathOrBytes == null) return;
    if (target == null) return;

    final chunks = state.pathOrBytes!.fold(
        (path) => File(path).openRead().map((x) => x as Uint8List),
        // The bytes code path is janky, but there is no time to make it not suck
        (bytes) => Stream.fromIterable(partition(bytes, 4096))
            .map((x) => Uint8List.fromList(x)));

    final task = manager.uploader
        .start(chunkSource: chunks, length: state.fileSize!, target: target);

    emit(state.apply(task: Some(task)));

    /// Will throw if an error occurs
    try {
      await task.complete;
      emit(state.apply(
        isUploaded: const Some(true),
        task: const Some(null),
      ));
      print("File upload task completed");
      if(state.metadataConfirmed) {
        add(_SPUploadBlocFinish());
      }
    } catch (e, st) {
      print("File upload failed with error $e\n$st");
      emit(state.apply(task: const Some(null)));
      add(SPUploadBlocCancel());
    }
  }

  Future<void> _onUploadCancel(SPUploadBlocCancel event, Emitter emit) async {
    // Check if we can cancel this upload
    // TODO [gampixi]: Fix logic edge cases as this was quick and deeeerty

    final id = state.upload?.id;
    if (id == null) {
      // Upload is not cancelable
      return;
    }

    emit(state.apply(isBusy: const Some(true)));

    if (state.task != null) {
      // If this is called during an active upload, we must cancel the upload task first.
      // Upon cancellation, this will be called again by the [_onUploadUpload] handler.
      final t = state.task;
      t?.cancel();
      return;
    }

    final parameters = PifsUploadsCancelParameters(id);
    final response = await manager.client.uploadCancel(parameters);

    response.fold((succ) {
      emit(state.apply(isBusy: const Some(false), upload: const Some(null)));
      manager.add(SPUploadListRemove(this));
    }, (error) {
      print("There was an error cancelling the upload: $error");
      emit(state.apply(isBusy: const Some(false)));
    });
  }

  Future<void> _onUploadFinish(_SPUploadBlocFinish event, Emitter emit) async {
    final id = state.upload?.id;
    print("Finishing upload ${id?.raw ?? "None"}...");
    if (id == null && state.isUploaded == true) {
      print("Upload is not finishable");
      // Upload is not finishable
      return;
    }

    emit(state.apply(isBusy: const Some(true)));

    final parameters = PifsUploadsFinishParameters(
        uploadId: id!,
        name: state.metadata.name.fold(() => "Untitled", (a) => a),
        tags: state.metadata.tags.fold(() => [], (a) => a.toList()),
        relevanceTimestamp: state.metadata.relevanceTimestamp.toNullable());
    final response = await manager.client.uploadFinish(parameters);

    response.fold((file) {
      print("Upload successfully finished, got file: ${file.id}");
      manager.add(SPUploadListRemove(this));
    }, (error) {
      print("There was an error finishing the upload: $error");
      emit(state.apply(isBusy: const Some(false)));
    });
  }
}
