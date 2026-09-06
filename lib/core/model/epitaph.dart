import 'package:bakiru/core/model/destroy_method.dart';
import 'package:bakiru/core/model/trash_item.dart';

/// 破壊の直前にユーザーが残した一言（捨て台詞）。
///
/// [TrashItem] とは別テーブルに保存する。TrashItem が消えたあとも
/// 捨て台詞だけは残したいため。
///
/// 元データの中身は一切持たない。写真そのものやメール本文は残さない。
/// 「消したはずのものがアプリ内に残っている」状態を作らないため。
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

  /// 一意な ID。uuid パッケージで採番する。
  final String id;

  /// ユーザーが残した言葉。
  final String text;

  /// 何を捨てたときのものか。
  final TrashItemType type;

  /// 捨てたものの表示名。
  ///
  /// 中身ではなく「一覧に出ていた名前」だけを残す。
  final String title;

  /// 破壊した日時。
  final DateTime destroyedAt;

  /// どの演出で壊したか。
  final DestroyMethod destroyMethod;
}
