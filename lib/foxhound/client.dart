import "package:json_rpc_2/json_rpc_2.dart" as jsonrpc;
import "package:dartz/dartz.dart";
import "package:spaniel/config.dart";
import "package:spaniel/foxhound/connection.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/data/upload.dart";
import "package:spaniel/pifs/parameters/all.dart";
import "package:spaniel/pifs/parameters/files_edit.dart";
import "package:http/http.dart" as http;
import "package:spaniel/pifs/responses/null_response.dart";
import "package:spaniel/pifs/support/json.dart";

class _VoidJsonBuilder implements JsonBuilder<void> {
  const _VoidJsonBuilder();
  static const instance = _VoidJsonBuilder();
  @override
  void fromJson(dynamic json) { }
}

class FoxhoundClient implements PifsClient {
  final jsonrpc.Client _connection;
  FoxhoundClient._(this._connection);
  static Future<FoxhoundClient> build() async {
    final conn = await FXConnection.connect(http.Client(), Config.fxSecretKey);
    final client = jsonrpc.Client(conn);
    return FoxhoundClient._(client);
  }

  PifsResponse<T> _send<T>(String method, Jsonable params, JsonBuilder<T> builder) {
    return _connection.sendRequest(method, params.toJson())
      .then((resp) => Left(builder.fromJson(resp)), onError: (error) => Right(error));
  }

  @override
  PifsResponse<PifsUpload> uploadBegin(PifsUploadsBeginParameters params) {
    return _send("uploads.begin", params, PifsUpload.jsonBuilder);
  }

  /*@override
  PifsResponse<void> uploadCancel(PifsUploadsCancelParameters params) {
    return _send("uploads.cancel", params, _VoidJsonBuilder.instance);
  }*/

  @override
  PifsResponse<PifsNullResponse> uploadCancel(PifsUploadsCancelParameters params) {
    return _send("uploads.cancel", params, PifsNullResponseBuilder());
  }

  @override
  PifsResponse<PifsFile> uploadFinish(PifsUploadsFinishParameters params) {
    // TODO: implement uploadFinish
    throw UnimplementedError();
  }

  @override
  PifsResponse<List<PifsFile>> filesList() {
    // TODO: implement filesList
    throw UnimplementedError();
  }

  @override
  PifsResponse<PifsFile> filesEdit(PifsFilesEditParameters params) {
    // TODO: implement filesEdit
    throw UnimplementedError();
  }
}