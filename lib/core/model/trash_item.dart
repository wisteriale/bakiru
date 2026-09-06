/// ごみ箱に入っているもの1件を表す。
///
/// 写真・メール・テキストと中身は違っても、一覧の表示や消去の演出では
/// 同じように扱いたい。そのため各機能はこの型に変換してから
/// ごみ箱に渡す、という約束にしている。
///
/// DB のテーブル（TrashItemRow）とは別物。DB の都合はテーブル側が持ち、
/// repository が両者を変換する。こうしておくとこの型は Drift に
/// 依存しないので、Web の偽実装でもそのまま使える。
class TrashItem {
  /// [TrashItem] を作る。
  const TrashItem({
    required this.id,
    required this.type,
    required this.title,
    required this.addedAt,
    required this.purgeAt,
    this.thumbnailPath,
    this.payload = const {},
  });

  /// 一意な ID。uuid パッケージで採番する。
  final String id;

  /// 何を捨てたのかの種別。
  final TrashItemType type;

  /// 一覧に表示する名前。
  final String title;

  /// サムネイル画像のパス。
  ///
  /// メールのように画像を持たない種別もあるので null を許す。
  final String? thumbnailPath;

  /// ごみ箱に入れた日時。
  final DateTime addedAt;

  /// 完全消去する予定の日時。
  final DateTime purgeAt;

  /// 種別ごとの追加情報。
  ///
  /// 中身は [type] で決まる。
  /// - [TrashItemType.photo] … アプリ内にコピーした画像のファイルパス
  /// - [TrashItemType.mail] … Gmail の messageId・送信者・件名・日付
  /// - [TrashItemType.text] … 共有されてきたテキストや URL
  ///
  /// 種別が増えても [TrashItem] 自体を変えずに済むようにするための逃げ道。
  /// DB には JSON 文字列に変換して保存する。
  final Map<String, Object?> payload;
}

/// [TrashItem] の種別。
///
/// 削除処理をどの Destroyer に任せるかの判定に使う。
enum TrashItemType {
  /// アプリ内に取り込んだ写真のコピー。端末の写真ライブラリは含まない。
  photo,

  /// Gmail から取り込んだメール。
  mail,

  /// 共有シートから受け取ったテキストや URL。
  text,
}
