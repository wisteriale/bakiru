/// ごみ箱に入っているもの1件を表す。
///
/// 写真・メール・アプリと中身は違っても、一覧の表示や消去の演出では
/// 同じように扱いたい。そのため各機能はこの型に変換してから
/// ごみ箱に渡す、という約束にしている。
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
  final TrashType type;

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
  /// 写真なら `{'assetId': 'xxx'}`、メールなら `{'messageId': 'xxx'}`
  /// のように入れておき、実際に消すときに Destroyer が読み出す。
  /// 種別が増えても [TrashItem] 自体を変えずに済むようにするための逃げ道。
  final Map<String, Object?> payload;
}

/// [TrashItem] の種別。
///
/// 削除処理をどの Destroyer に任せるかの判定に使う。
enum TrashType {
  /// 端末内の写真。
  photo,

  /// メール（お祈りメールなど）。
  mail,

  /// インストール済みのアプリ。
  app,

  /// 他アプリから共有されてきた URL やテキスト。
  shared,
}
