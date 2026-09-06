import 'package:bakiru/features/trash/repository/trash_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ごみ箱の実装を画面へ渡す Provider。
///
/// `main.dart` の `ProviderScope.overrides` で、開発用の偽実装または
/// 担当Aが作るDB実装を注入する。
final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  throw UnimplementedError(
    'TrashRepository を ProviderScope で設定してください。',
  );
});
