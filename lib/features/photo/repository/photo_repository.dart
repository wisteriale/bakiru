import 'package:bakiru/core/model/trash_item.dart';

/// 写真をアプリ内に取り込む。
///
/// **端末の写真ライブラリは触らない。** OS 標準のピッカーで選ばれたものを
/// アプリ内にコピーするだけなので、写真ライブラリの権限は要らない。
/// 破壊しても消えるのはこのコピーだけで、端末の元の写真は残る。
abstract class PhotoRepository {
  /// OS 標準のピッカーを開き、選ばれた画像をアプリ内にコピーする。
  ///
  /// 戻り値はごみ箱に入れられる形にした [TrashItem]。
  /// ユーザーがキャンセルしたら null を返す。
  Future<TrashItem?> pickAndImport();

  /// アプリ内にコピーした画像ファイルを消す。
  ///
  /// [path] は [TrashItem.payload] に入れておいたコピーのパス。
  /// 消えるのはコピーだけで、端末の元の写真は残る。
  Future<void> deleteLocalCopy(String path);
}
