import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Android / iOS 用の DB 接続。
///
/// アプリ専用のディレクトリに `bakiru.sqlite` を置く。
/// ここは他アプリから見えないので、消したデータの残骸が漏れない。
///
/// `createInBackground` を使うのは、DB の処理を別スレッドに逃がして
/// 演出アニメーションのフレーム落ちを防ぐため。
Future<QueryExecutor> openConnection() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'bakiru.sqlite'));
  return NativeDatabase.createInBackground(file);
}
