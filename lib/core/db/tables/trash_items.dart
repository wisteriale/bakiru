import 'package:bakiru/core/model/trash_item.dart';
import 'package:drift/drift.dart';

/// ごみ箱の中身を保存するテーブル。
///
/// ドメイン型の [TrashItem] とは別物。
/// 「Map をそのまま保存できない」「enum をそのまま保存できない」といった
/// DB の都合はこのテーブルが引き受け、repository が両者を変換する。
///
/// 生成されるデータクラスの名前を TrashItemRow にしているのは、
/// 手書きの [TrashItem] と名前がぶつからないようにするため。
@DataClassName('TrashItemRow')
class TrashItems extends Table {
  /// 一意な ID（uuid 文字列）。
  TextColumn get id => text()();

  /// 種別。enum の名前（'photo' など）を文字列で保存する。
  ///
  /// index（整数）ではなく名前で保存するのは、あとで enum の並び順を
  /// 入れ替えても既存データが壊れないようにするため。
  TextColumn get type => textEnum<TrashItemType>()();

  /// 一覧に表示する名前。
  TextColumn get title => text()();

  /// サムネイル画像のパス。持たない種別もあるので null 可。
  TextColumn get thumbnailPath => text().nullable()();

  /// ごみ箱に入れた日時。
  DateTimeColumn get addedAt => dateTime()();

  /// 完全消去する予定の日時。
  DateTimeColumn get purgeAt => dateTime()();

  /// 種別ごとの追加情報を JSON 文字列にしたもの。
  ///
  /// Map のままでは保存できないので、repository で jsonEncode して入れ、
  /// 読むときに jsonDecode して [TrashItem.payload] に戻す。
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
