import 'package:bakiru/app.dart';
import 'package:bakiru/core/repository/trash_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリを起動する。
void main() {
  runApp(
    ProviderScope(
      overrides: [
        trashRepositoryProvider.overrideWithValue(FakeTrashRepository()),
      ],
      child: const BakiruApp(),
    ),
  );
}
