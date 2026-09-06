import 'package:bakiru/core/model/trash_item.dart';

/// Gmailからメールを取り込む窓口。
abstract class MailRepository {
  /// Gmailからごみ箱へ入れる候補のメールを取得する。
  Future<List<TrashItem>> fetchMessages();

  /// [item] に対応するメールをGmailのゴミ箱へ移動する。
  ///
  /// 完全削除は行わない。
  Future<void> moveToTrash(TrashItem item);
}
