import 'package:bakiru/core/model/trash_item.dart';

/// ごみ箱の中身を読み書きする。
///
/// UI と provider はこの型だけを知っていればよく、
/// 実際に DB を使うのかダミーを返すのかは気にしない。
/// Web で画面だけ作っている間は偽実装に差し替える
/// （差し替えは main.dart の ProviderScope.overrides で行う）。
abstract class TrashRepository {
  /// ごみ箱の中身を監視する。
  ///
  /// Future ではなく Stream を返すのは、中身が増減したときに
  /// 画面を自動で描き直したいため。Drift は変更を Stream で流せる。
  Stream<List<TrashItem>> watchAll();

  /// ごみ箱に1件入れる。
  Future<void> add(TrashItem item);

  /// ごみ箱から1件消す（DB のレコードだけ）。
  ///
  /// 実データ（写真のコピーや Gmail のメール）を消すのは Destroyer の仕事。
  /// ここでレコードを消すだけだと実データが残るので、
  /// 必ず Destroyer とセットで呼ぶこと。
  Future<void> remove(String id);
}
