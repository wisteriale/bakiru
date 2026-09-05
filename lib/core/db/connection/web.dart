import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web 用の DB 接続。
///
/// 動かすには `web/` に以下の2つを置く必要がある（未配置ならエラー）。
///
/// - `sqlite3.wasm` … SQLite 本体を WebAssembly にしたもの
/// - `drift_worker.js` … DB 処理を Web Worker に逃がすためのスクリプト
///
/// 入手先は drift の公式ドキュメント（Web 向けセットアップ）。
/// どちらも生成物なのでリポジトリに置くかどうかは要相談。
Future<QueryExecutor> openConnection() async {
  final result = await WasmDatabase.open(
    databaseName: 'bakiru',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}
