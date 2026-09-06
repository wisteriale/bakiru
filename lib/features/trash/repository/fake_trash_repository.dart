import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/features/trash/repository/trash_repository.dart';

/// DB完成前に画面と演出を確認するための、一時的なごみ箱実装。
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
