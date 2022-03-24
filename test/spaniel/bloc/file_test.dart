import "package:bloc_test/bloc_test.dart";
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import "package:spaniel/pifs/parameters/files_edit.dart";
import "package:spaniel/spaniel/bloc/file.dart";

class _MockClient extends Mock implements PifsClient {}

void main() {
  final file = PifsFile(
      id: "testId",
      name: "An excellent file",
      tags: ["Tag1", "Tag2", "Tag3", "Tag4"],
      uploadTimestamp: DateTime.now(),
      relevanceTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
      length: 69,
      hash: "test",
      type: "test",
      indexingState: 0
  );

  // ignore: prefer_function_declarations_over_variables
  final getBloc = (PifsFile file) {
    final client = _MockClient();
    when(() => client.filesEdit(any())).thenAnswer((i) async {
      return Left(file);
    });
    return SPFileBloc(
      SPFileBlocState.initial(file),
      client: client
    );
  };

  setUpAll(() {
    // Required for mocks to work
    registerFallbackValue(PifsFilesEditParameters(
        fileId: "",
        name: "",
        tags: [],
        relevanceTimestamp: null));
  });

  blocTest("Modify name event sets name in staged metadata",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSetModifiedName("Test name")),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.name, "name matches", equals("Test name"))
    ],
  );

  blocTest("Modify tags event sets tags in staged metadata",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSetModifiedTags(["NewTag1", "NewTag2"])),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.tags, "tags match", orderedEquals(["NewTag1", "NewTag2"]))
    ],
  );

  blocTest("Modify relevance date event sets it in staged metadata",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSetModifiedRelevanceDate(DateTime.fromMillisecondsSinceEpoch(10000))),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.relevanceTimestamp, "timestamp matches", equals(DateTime.fromMillisecondsSinceEpoch(10000)))
    ],
  );

  blocTest("Save event calls client files edit method",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSaveChanges()),
    wait: const Duration(seconds: 1), // Wait because save is async
    verify: (SPFileBloc b) { // Use verify because no state is emitted
      verify(() => b.client.filesEdit(any())).called(1);
    },
  );

  blocTest("Save event calls client files edit with correct arguments",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b
      ..add(SPFileBlocSetModifiedName("Test name"))
      ..add(SPFileBlocSetModifiedTags(["NewTag1", "NewTag2"]))
      ..add(SPFileBlocSetModifiedRelevanceDate(DateTime.fromMillisecondsSinceEpoch(10000)))
      ..add(SPFileBlocSaveChanges()),
    wait: const Duration(seconds: 1), // Wait because save is async
    verify: (SPFileBloc b) { // Use verify because no state is emitted
      final args = verify(() => b.client.filesEdit(any())).captured.first as PifsFilesEditParameters;
      expect(args.name, equals("Test name"));
      expect(args.tags, orderedEquals(["NewTag1", "NewTag2"]));
      expect(args.relevanceTimestamp, equals(DateTime.fromMillisecondsSinceEpoch(10000)));
    },
  );
}