import 'package:bakiru/core/model/trash_item.dart';

/// Gmail からメールを取り込み、Gmail のゴミ箱へ移す。
///
/// **完全削除はしない。** 使うスコープは gmail.readonly（一覧の取得）と
/// gmail.modify（ゴミ箱移動）の2つだけ。
abstract class MailRepository {
  /// 保存済みの資格情報で静かにサインインを試す。
  ///
  /// 初回や期限切れのときは何も起きない（例外にはしない）。
  /// Web では Google が用意したボタンを押してもらう必要があり、
  /// このメソッドだけではサインインを開始できないため。
  Future<void> signIn();

  /// サインインしているかどうかの変化を流す。
  ///
  /// Future ではなく Stream なのは、Web ではサインインが
  /// 「ボタンを押した結果あとから起きること」で、
  /// 呼び出した側が待って受け取れるものではないため。
  Stream<bool> watchSignedIn();

  /// 直近のメールを取得し、ごみ箱に入れられる形にして返す。
  ///
  /// [limit] は取得する件数の上限。
  /// [query] は Gmail の検索窓と同じ構文の絞り込み条件。
  /// 検索は Gmail 側で行われるので、アプリが本文を受け取ることはない。
  Future<List<TrashItem>> fetchRecent({int limit = 20, String? query});

  /// [messageId] のメールを Gmail のゴミ箱に移す。
  ///
  /// 30日後に Gmail 側で自動削除される。こちらから完全削除はしない。
  /// 失敗したら例外を投げる（呼び出し側が復帰処理をするため）。
  Future<void> moveToTrash(String messageId);
}
