import 'dart:convert';

import 'package:bakiru/core/db/database.dart';
import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/features/trash/repository/trash_repository.dart';
import 'package:drift/drift.dart';

/// ごみ箱の中身を Drift（SQLite）に保存する本物の実装。
///
/// ドメイン型の [TrashItem] と、DB のテーブル行 [TrashItemRow] は別物なので、
/// その変換をこのクラスが引き受ける。こうしておくと画面や演出は
/// Drift を一切知らずに済む。
class DriftTrashRepository implements TrashRepository {
  /// 渡された [AppDatabase] にごみ箱を保存する。
  DriftTrashRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<TrashItem>> watchAll() {
    final query = _db.select(_db.trashItems)
      ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]);

    // watch() は、テーブルの中身が変わるたびに新しいリストを流す Stream を返す。
    // 画面はこれを見ているだけで、add / remove のあとに自分で
    // 読み直さなくても勝手に描き直される。
    return query.watch().map((rows) => rows.map(_toItem).toList());
  }

  @override
  Future<void> add(TrashItem item) async {
    await _db.into(_db.trashItems).insert(_toCompanion(item));
  }

  @override
  Future<void> remove(String id) async {
    await (_db.delete(_db.trashItems)..where((t) => t.id.equals(id))).go();
  }

  /// DB の行をドメイン型に戻す。
  TrashItem _toItem(TrashItemRow row) {
    return TrashItem(
      id: row.id,
      type: row.type,
      title: row.title,
      thumbnailPath: row.thumbnailPath,
      addedAt: row.addedAt,
      purgeAt: row.purgeAt,
      payload: _decodePayload(row.payloadJson),
    );
  }

  /// ドメイン型を DB に入れられる形にする。
  ///
  /// Companion は「まだ DB に入っていない行」を表す Drift の型。
  /// 未指定の列を `Value.absent()` で表せるので、
  /// 既定値を持つ列（payloadJson）を省略できる。
  TrashItemsCompanion _toCompanion(TrashItem item) {
    return TrashItemsCompanion.insert(
      id: item.id,
      type: item.type,
      title: item.title,
      thumbnailPath: Value(item.thumbnailPath),
      addedAt: item.addedAt,
      purgeAt: item.purgeAt,
      payloadJson: Value(jsonEncode(item.payload)),
    );
  }

  /// JSON 文字列を [TrashItem.payload] の形に戻す。
  ///
  /// 想定外の中身（配列など）が入っていても落ちないように空の Map を返す。
  /// payload は「種別ごとの逃げ道」なので、ここで例外を投げると
  /// ごみ箱一覧そのものが表示できなくなってしまう。
  Map<String, Object?> _decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const {};
  }
}
