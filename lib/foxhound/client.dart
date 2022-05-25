import "package:json_rpc_2/json_rpc_2.dart" as jsonrpc;
import "package:dartz/dartz.dart";
import "package:spaniel/config.dart";
import "package:spaniel/foxhound/connection.dart";
import "package:spaniel/pifs/client.dart";
import 'package:spaniel/pifs/data/search_result.dart';
import "package:spaniel/pifs/error.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/parameters/parameters.dart";
import "package:spaniel/pifs/responses/responses.dart";
import "package:http/http.dart" as http;
import "package:spaniel/pifs/support/json.dart";

/// This class always serializes to an empty map. The const instance at [instance]
/// should be used to prevent needless instantiation.
class _EmptyParameters implements Jsonable {
  const _EmptyParameters();
  static const instance = _EmptyParameters();

  @override
  toJson() => const <String, dynamic>{};
}

/// Helper class to generate typesafe bound [fromJson] constructors for arbitrary
/// list types, instead of modifying the [List] type itself. Instantiations of this
/// class should be performable at AOT compilation stage, and runtime bloat should
/// be minimal due to the const-ness throughout.
class _ListBuilder<Elem> {
  final Elem Function(dynamic) builder;
  const _ListBuilder(this.builder);

  List<Elem> fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return json.map((elem) => builder(elem)).toList(growable: false);
    } else {
      throw JsonRepresentationException.invalidShape(json);
    }
  }
}

class FoxhoundClient implements PifsClient {
  jsonrpc.Client _connection;
  FoxhoundClient._(this._connection);
  static Future<FoxhoundClient> build() async {
    final conn = await FXConnection.connect(http.Client(), Config.fxSecretKey);
    final client = jsonrpc.Client(conn);
    client.listen();
    return FoxhoundClient._(client);
  }

  PifsResponse<T> _send<T>(String method, Jsonable params, T Function(dynamic) builder,
      {bool autoRetryOnTokenExpiry = true}) async {
    try {
      var response = await _connection.sendRequest(method, params.toJson());
      var transformed = builder(response);
      return Left(transformed);
    } on jsonrpc.RpcException catch (error) {
      // Special case: if the response is a 2401, the session token has expired
      // and should be renewed, after which the request should be tried again.
      // To prevent infinite loops, this is only tried once.
      if (error.code == PifsError.codeUnauthorized && autoRetryOnTokenExpiry) {
        _connection.close();
        final conn = await FXConnection.connect(http.Client(), Config.fxSecretKey);
        _connection = jsonrpc.Client(conn);
        _connection.listen();
        return _send(method, params, builder, autoRetryOnTokenExpiry: false);
      }

      return Right(PifsError.fromRpc(error));
    }
  }

  @override
  PifsResponse<PifsTargetableUpload> uploadBegin(PifsUploadsBeginParameters params) {
    return _send("uploads.begin", params, PifsTargetableUpload.fromJson);
  }

  @override
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params) {
    return _send("uploads.cancel", params, PifsNullResponse.fromJson);
  }

  @override
  PifsResponse<PifsFile> uploadFinish(PifsUploadsFinishParameters params) {
    return _send("uploads.finish", params, PifsFile.fromJson);
  }

  @override
  PifsResponse<List<PifsUpload>> uploadsList() {
    return _send("uploads.list", _EmptyParameters.instance,
        const _ListBuilder(PifsUpload.fromJson).fromJson);
  }

  @override
  PifsResponse<PifsFile> filesGet(PifsFilesGetParameters params) {
    return _send("files.get", params, PifsFile.fromJson);
  }

  @override
  PifsResponse<PifsNullResponse> filesDelete(PifsFilesDeleteParameters params) {
    return _send("files.delete", params, PifsNullResponse.fromJson);
  }

  @override
  PifsResponse<PifsStringResponse> filesRequestDownload(PifsFilesRequestDownloadParameters params) {
    return _send("files.request_download", params, PifsStringResponse.fromJson);
  }

  @override
  PifsResponse<List<PifsFile>> filesList() {
    return _send("files.list", _EmptyParameters.instance,
      const _ListBuilder(PifsFile.fromJson).fromJson);
  }

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) {
    return _send("files.edit", params, PifsFile.fromJson);
  }

  @override
  PifsResponse<List<PifsSearchResult>> searchPerform(PifsSearchPerformParameters params) {
    return _send("search.perform", params,
      const _ListBuilder(PifsSearchResult.fromJson).fromJson);
  }
}
