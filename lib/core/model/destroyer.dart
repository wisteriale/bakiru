import 'package:bakiru/core/model/trash_item.dart';

/// ごみ箱の中身を実際に消す処理。
///
/// 種別ごとに実装を1つ用意する（写真用・メール用・アプリ用）。
/// 呼ぶ側は「どれが担当か」を知らなくてよく、[supports] が true を
/// 返した実装に [destroy] を任せるだけでよい。
///
/// 新しい種別を足すときは、この実装を1つ増やして
/// destroy 機能の provider に登録するだけで済む。
abstract class Destroyer {
  /// この実装が [item] を消せるなら true。
  bool supports(TrashItem item);

  /// [item] を実際に消す。
  ///
  /// OS への削除依頼やネットワーク通信を伴うので Future を返す。
  /// 消せなかった場合は例外を投げる。
  Future<void> destroy(TrashItem item);
}
