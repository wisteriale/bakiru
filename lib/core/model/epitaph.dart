import 'package:bakiru/core/model/trash_item.dart';

/// 破壊したときに残す一言を表す。
///
/// 捨てた写真やメールの中身は保存せず、
/// 破壊の記録として必要な情報だけを持つ。
/// 後で Drift のテーブルへ保存する予定の共通モデル。
class Epitaph {
  /// [Epitaph] を作る。
  const Epitaph({
    required this.id,
    required this.text,
    required this.type,
    required this.title,
    required this.destroyedAt,
    required this.destroyMethod,
  });

  /// 一意な ID。
  final String id;

  /// 破壊する直前に入力した一言。
  final String text;

  /// 何を破壊したときの記録かを表す種別。
  final TrashItemType type;

  /// 破壊した対象の一覧用表示名。
  final String title;

  /// 破壊を完了した日時。
  final DateTime destroyedAt;

  /// 使用した破壊演出。
  final DestroyMethod destroyMethod;
}

/// 捨て台詞の記録に残す破壊演出の種別。
enum DestroyMethod {
  /// 叩き割る演出。
  shatter,

  /// 燃やす演出。
  burn,
}
