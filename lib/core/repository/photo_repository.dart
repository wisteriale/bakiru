import 'package:bakiru/core/model/trash_item.dart';

/// 端末から選んだ写真をアプリ内へ取り込む窓口。
// ignore: one_member_abstracts
abstract class PhotoRepository {
  /// OS標準ピッカーで選んだ写真を、
  /// アプリ内へコピーして返す。
  ///
  /// 操作を取り消した場合は null を返す。
  /// 端末の写真ライブラリは変更しない。
  Future<TrashItem?> pickAndCopy();
}
