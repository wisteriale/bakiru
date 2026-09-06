import 'package:bakiru/core/model/destroy_method.dart';
import 'package:bakiru/core/model/trash_item.dart';
import 'package:drift/drift.dart';

/// 捨て台詞を保存するテーブル。
///
/// TrashItems とは別テーブルにしている。ごみ箱の中身が消えたあとも
/// 捨て台詞だけは残す必要があるため。
///
/// **元データの中身は絶対に持たせない。** 写真そのものやメール本文を
/// ここに保存すると「消したのに残っている」状態になる。
@DataClassName('EpitaphRow')
class Epitaphs extends Table {
  /// 一意な ID（uuid 文字列）。
  TextColumn get id => text()();

  /// ユーザーが残した言葉。
  ///
  /// Dart 側の名前を message にしているのは、Table が持つ text() という
  /// メソッドと同じ名前の getter を定義できないため。
  /// ドメイン型 Epitaph 側では text という名前のまま扱う。
  TextColumn get message => text()();

  /// 何を捨てたときのものか。
  TextColumn get type => textEnum<TrashItemType>()();

  /// 捨てたものの表示名。中身ではなく名前だけ。
  TextColumn get title => text()();

  /// 破壊した日時。
  DateTimeColumn get destroyedAt => dateTime()();

  /// どの演出で壊したか。
  TextColumn get destroyMethod => textEnum<DestroyMethod>()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
