import 'package:bakiru/core/db/connection/connection.dart';
import 'package:bakiru/core/db/tables/epitaphs.dart';
import 'package:bakiru/core/db/tables/trash_items.dart';
import 'package:bakiru/core/model/destroy_method.dart';
import 'package:bakiru/core/model/trash_item.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

/// アプリのローカル DB。
///
/// テーブルの定義そのものは core/db/tables/ に1ファイルずつ置き、
/// ここは「どのテーブルを使うか」の宣言だけにしている。
/// 2人が別々のテーブルを同時に触っても衝突しにくくするため。
@DriftDatabase(tables: [TrashItems, Epitaphs])
class AppDatabase extends _$AppDatabase {
  /// プラットフォームに合った接続で DB を開く。
  ///
  /// LazyDatabase で包むのは、接続を開く処理が非同期
  /// （ファイルのパス取得や wasm の読み込み）なため。
  /// 実際に最初のクエリが走るまで接続は開かれない。
  AppDatabase() : super(LazyDatabase(openConnection));

  /// 接続を外から差し込む。テスト専用。
  ///
  /// 通常のコンストラクタは接続先がプラットフォーム任せ
  /// （端末のファイル / ブラウザの wasm）で、テストからは差し替えられない。
  /// ここに `NativeDatabase.memory()` を渡すと、実機もブラウザも使わずに
  /// メモリ上の SQLite で動かせる。テストごとに中身が空になるので
  /// 前のテストの結果が残らない。
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
