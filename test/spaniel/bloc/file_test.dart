import "package:bloc_test/bloc_test.dart";
import "package:dartz/dartz.dart";
import 'package:flutter/foundation.dart';
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:spaniel/pifs/client.dart";
import "package:spaniel/pifs/data/file.dart";
import 'package:spaniel/pifs/parameters/src/files_edit.dart';
import "package:spaniel/spaniel/bloc/file.dart";

class _MockClient extends Mock implements PifsClient {}

void main() {
  final file = PifsFile(
      id: "testId",
      name: "An excellent file",
      tags: {"Tag1", "Tag2", "Tag3", "Tag4"},
      uploadTimestamp: DateTime.now(),
      relevanceTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
      length: 69,
      hash: "test",
      type: PifsFileType.document,
      indexingState: PifsIndexingState.indexed
  );

  SPFileBloc getBloc(PifsFile file) {
    final client = _MockClient();
    when(() => client.filesEdit(any())).thenAnswer((i) async {
      return Left(file);
    });
    return SPFileBloc(
      SPFileBlocState.initial(file),
      client: client
    );
  }

  setUpAll(() {
    // Required for mocks to work
    registerFallbackValue(PifsFilesEditParameters(fileId: ""));
  });

  blocTest("Modify name event sets name in staged metadata",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSetModifiedName("Test name")),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.name.toNullable(), "name matches", equals("Test name"))
    ],
  );

  blocTest("Add tag event adds tag to existing tags",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocAddStagedTag("NewTag1")),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.tags.toNullable(), "tags match", equals({"Tag1", "Tag2", "Tag3", "Tag4", "NewTag1"}))
    ],
  );

  blocTest("Remove tag event removes tag from existing tags",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocRemoveStagedTag("Tag3")),
    expect: () => [isA<SPFileBlocState>()
        .having((s) => s.stagedMetadata.tags.toNullable(), "tags match", equals({"Tag1", "Tag2", "Tag4"}))
    ],
  );

  blocTest("Modify relevance date event sets it in staged metadata",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b.add(SPFileBlocSetModifiedRelevanceDate(DateTime.fromMillisecondsSinceEpoch(10000))),
    expect: () => [isA<SPFileBlocState>()
      .having((s) => s.stagedMetadata.relevanceTimestamp.toNullable(), "timestamp matches", equals(DateTime.fromMillisecondsSinceEpoch(10000)))
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

  blocTest("Revert restores stagedMetadata to empty",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b
      ..add(SPFileBlocSetModifiedName("Test name"))
      ..add(SPFileBlocAddStagedTag("NewTag1"))
      ..add(SPFileBlocRemoveStagedTag("Tag3"))
      ..add(SPFileBlocSetModifiedRelevanceDate(DateTime.fromMillisecondsSinceEpoch(10000)))
      ..add(SPFileBlocRevertChanges()),
    skip: 4,
    expect: () => [isA<SPFileBlocState>()
        .having((s) => s.stagedMetadata.relevanceTimestamp.isNone(), "timestamp is none", equals(true))
        .having((s) => s.stagedMetadata.name.isNone(), "name is none", equals(true))
        .having((s) => s.stagedMetadata.tags.isNone(), "tags is none", equals(true))
    ],
  );

  blocTest("Save event calls client files edit with correct arguments",
    build: () => getBloc(file),
    act: (SPFileBloc b) => b
      ..add(SPFileBlocSetModifiedName("Test name"))
      ..add(SPFileBlocAddStagedTag("NewTag1"))
      ..add(SPFileBlocRemoveStagedTag("Tag3"))
      ..add(SPFileBlocSetModifiedRelevanceDate(DateTime.fromMillisecondsSinceEpoch(10000)))
      ..add(SPFileBlocSaveChanges()),
    wait: const Duration(seconds: 1), // Wait because save is async
    verify: (SPFileBloc b) { // Use verify because no state is emitted
      final args = verify(() => b.client.filesEdit(captureAny())).captured.first as PifsFilesEditParameters;
      expect(args.name.toNullable(), equals("Test name"));
      expect(args.tags.toNullable(), equals({"Tag1", "Tag2", "Tag4", "NewTag1"}));
      expect(args.relevanceTimestamp.toNullable(), equals(DateTime.fromMillisecondsSinceEpoch(10000)));
    },
  );
}