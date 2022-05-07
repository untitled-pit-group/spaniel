import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:spaniel/pifs/client.dart';
import 'package:spaniel/pifs/data/upload.dart';
import 'package:spaniel/pifs/parameters/parameters.dart';
import 'package:spaniel/pifs/upload/uploader.dart';

abstract class SPUploadBlocEvent {}

class SPUploadBlocBegin implements SPUploadBlocEvent {
  final String filePath;
  const SPUploadBlocBegin(this.filePath);
}

class _SPUploadBlocUpload implements SPUploadBlocEvent {}

class SPUploadBlocCancel implements SPUploadBlocEvent {}

class _SPUploadBlocFinish implements SPUploadBlocEvent {}

class SPUploadBlocState with EquatableMixin {
  // Using the state variables, one should be able to figure out whether
  // this upload is initiated locally or is a remote response to uploads in progress
  final bool isBusy;
  final String? filePath;
  final PifsUpload? upload;
  final PifsUploadTask? task;

  const SPUploadBlocState._internal({
    required this.isBusy,
    required this.filePath,
    required this.upload,
    required this.task
  });

  factory SPUploadBlocState.initial(PifsUpload? upload) {
    return SPUploadBlocState._internal(
      isBusy: false,
      filePath: null,
      upload: upload,
      task: null
    );
  }

  SPUploadBlocState apply({
    Option<bool> isBusy = const None(),
    Option<String?> filePath = const None(),
    Option<PifsUpload?> upload = const None(),
    Option<PifsUploadTask?> task = const None(),
  }) {
    return SPUploadBlocState._internal(
      isBusy: isBusy.fold(() => this.isBusy, (a) => a),
      filePath: filePath.fold(() => this.filePath, (a) => a),
      upload: upload.fold(() => this.upload, (a) => a),
      task: task.fold(() => this.task, (a) => a),
    );
  }

  @override
  List<Object?> get props => [isBusy, filePath, upload, task];
}

class SPUploadBloc extends Bloc<SPUploadBlocEvent, SPUploadBlocState> {
  final PifsClient client;
  final PifsUploader uploader;

  SPUploadBloc(this.client, this.uploader, {PifsUpload? upload}) : super(SPUploadBlocState.initial(upload)) {
    on<SPUploadBlocBegin>(_onUploadBegin);
    on<_SPUploadBlocUpload>(_onUploadUpload);
    on<SPUploadBlocCancel>(_onUploadCancel);
    on<_SPUploadBlocFinish>(_onUploadFinish);
  }

  Future<void> _onUploadBegin(SPUploadBlocBegin event, Emitter emit) async {
    emit(state.apply(isBusy: const Some(true)));

    // Prepare a [PifsUploadBeginParameters] and request starting the upload
    final path = event.filePath;
    final file = File(path);
    final chunks = file.openRead().map((x) => x as Uint8List);

    final hashOutput = AccumulatorSink<Digest>();
    final hashInput = sha1.startChunkedConversion(hashOutput);
    await chunks.forEach((e) { hashInput.add(e); });
    hashInput.close();
    
    var hashDigest = hashOutput.events.single.toString();
    print(hashDigest);
    // FIXME: Temp, disable hashes because they don't matter at the moment
    const _chars = "abcdef1234567890";

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
    
    hashDigest = getRandomString(40);
    print(hashDigest);
    
    final fileSize = await file.length();
    final fileName = p.basename(path);

    final parameters = PifsUploadsBeginParameters(hashDigest, fileSize, fileName);
    final response = await client.uploadBegin(parameters);

    response.fold(
      (upload) {
        print("Upload has begun: ${upload.id.raw}");
        emit(state.apply(
          isBusy: const Some(false),
          filePath: Some(path),
          upload: Some(upload)
        ));
      },
      (error) {
        print("There was an error beginning the upload: $error");
        emit(state.apply(isBusy: const Some(false)));
      }
    );
  }

  Future<void> _onUploadUpload(_SPUploadBlocUpload event, Emitter emit) async {
    throw UnimplementedError();
  }

  Future<void> _onUploadCancel(SPUploadBlocCancel event, Emitter emit) async {
    // Check if we can cancel this upload
    // TODO [gampixi]: Fix logic edge cases as this was quick and deeeerty

    final id = state.upload?.id;
    if(id == null) {
      // Upload is not cancelable
      return;
    }

    emit(state.apply(isBusy: const Some(true)));

    final parameters = PifsUploadsCancelParameters(id);
    final response = await client.uploadCancel(parameters);

    response.fold(
      (succ) {
        emit(state.apply(
          isBusy: const Some(false),
          upload: const Some(null)
        ));
      },
      (error) {
        print("There was an error cancelling the upload: $error");
        emit(state.apply(isBusy: const Some(false)));
      }
    );
  }

  Future<void> _onUploadFinish(_SPUploadBlocFinish event, Emitter emit) async {
    throw UnimplementedError();
  }
}