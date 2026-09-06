import 'package:bakiru/core/model/trash_item.dart';

/// Gmail からメールを取り込み、Gmail のゴミ箱へ移す。
///
/// **完全削除はしない。** 使うスコープは gmail.readonly（一覧の取得）と
/// gmail.modify（ゴミ箱移動）の2つだけ。
abstract class MailRepository {
  /// Gmail にサインインする。すでに済んでいれば何もしない。
  Future<void> signIn();

  /// 直近のメールを取得し、ごみ箱に入れられる形にして返す。
  ///
  /// [limit] は取得する件数の上限。
  Future<List<TrashItem>> fetchRecent({int limit = 20});

  /// [messageId] のメールを Gmail のゴミ箱に移す。
  ///
  /// 30日後に Gmail 側で自動削除される。こちらから完全削除はしない。
  /// 失敗したら例外を投げる（呼び出し側が復帰処理をするため）。
  Future<void> moveToTrash(String messageId);
}
