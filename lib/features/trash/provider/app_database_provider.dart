import 'package:bakiru/core/db/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリのローカル DB を1つだけ作って配る Provider。
///
/// DB への接続はアプリ全体で1つにする。複数開くと同じファイルを
/// 別々に掴むことになり、片方の変更がもう片方に流れない。
///
/// 置き場所を core/db/ ではなく features/trash/ にしているのは、
/// 今 DB を使うのがごみ箱だけのため。捨て台詞（epitaphs）から
/// 使うようになったら core/ に上げる。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Provider が捨てられるときに接続も閉じる。
  // 閉じ忘れるとファイルを掴んだままになる。
  ref.onDispose(db.close);

  return db;
});
