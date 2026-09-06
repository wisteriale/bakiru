import 'package:bakiru/features/trash/provider/app_database_provider.dart';
import 'package:bakiru/features/trash/repository/drift_trash_repository.dart';
import 'package:bakiru/features/trash/repository/trash_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ごみ箱の実装を画面へ渡す Provider。
///
/// 既定は Drift（SQLite）の本物の実装。
/// ダミーデータで画面だけ確認したいときは、main.dart の
/// `ProviderScope.overrides` で FakeTrashRepository に差し替える。
/// 本物に繋ぐときは、その override を外すだけでよい。
final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  return DriftTrashRepository(ref.watch(appDatabaseProvider));
});
