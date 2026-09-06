import 'package:bakiru/core/model/trash_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ごみ箱の実装を画面へ渡す Provider。
///
/// 現在は `main.dart` の `ProviderScope.overrides` で
/// [FakeTrashRepository] を注入する。
/// 担当Aの本実装ができたら、
/// 差し替え先だけを変更すれば画面側はそのまま使える。
final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  throw UnimplementedError(
    'TrashRepository を ProviderScope で設定してください。',
  );
});

/// ごみ箱の一覧と追加・削除を扱う窓口。
///
/// 実装は担当Aが Drift を使って作る。
/// 担当Bは同じ形の [FakeTrashRepository] を差し替え、
/// DBを待たずに
/// 画面と演出を作れる。
abstract class TrashRepository {
  /// ごみ箱内の項目を更新のたびに返す。
  Stream<List<TrashItem>> watchAll();

  /// [item] をごみ箱へ追加する。
  Future<void> add(TrashItem item);

  /// IDが [id] の項目をごみ箱から取り除く。
  Future<void> remove(String id);
}

/// B担当が画面と演出を作るための、一時的なごみ箱実装。
///
/// アプリを再起動すると初期データへ戻る。
/// 担当Aの本実装が完成したら、
/// `ProviderScope.overrides` の差し替え先を変える。
class FakeTrashRepository implements TrashRepository {
  /// ダミー項目を持つ [FakeTrashRepository] を作る。
  FakeTrashRepository({List<TrashItem>? initialItems})
    : _items = List.of(initialItems ?? _defaultItems);

  final List<TrashItem> _items;

  static final List<TrashItem> _defaultItems = [
    TrashItem(
      id: 'fake-photo-1',
      type: TrashItemType.photo,
      title: '思い出の写真',
      addedAt: DateTime(2026, 9, 5, 10),
      purgeAt: DateTime(2026, 10, 5, 10),
      payload: const {'filePath': '/fake/photo.jpg'},
    ),
    TrashItem(
      id: 'fake-mail-1',
      type: TrashItemType.mail,
      title: '選考結果のお知らせ',
      addedAt: DateTime(2026, 9, 4, 18),
      purgeAt: DateTime(2026, 10, 4, 18),
      payload: const {'messageId': 'fake-message-id'},
    ),
    TrashItem(
      id: 'fake-text-1',
      type: TrashItemType.text,
      title: 'あとで読むリンク',
      addedAt: DateTime(2026, 9, 3, 12),
      purgeAt: DateTime(2026, 10, 3, 12),
      payload: const {'text': 'https://example.com'},
    ),
  ];

  @override
  Future<void> add(TrashItem item) {
    _items.add(item);
    return Future.value();
  }

  @override
  Future<void> remove(String id) {
    _items.removeWhere((item) => item.id == id);
    return Future.value();
  }

  @override
  Stream<List<TrashItem>> watchAll() {
    return Stream.value(List.unmodifiable(_items));
  }
}
