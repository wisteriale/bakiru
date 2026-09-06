import 'package:bakiru/core/db/database.dart';
import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/features/trash/repository/drift_trash_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftTrashRepository repository;

  setUp(() {
    // メモリ上の SQLite を使う。テストごとに作り直すので中身は毎回空。
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTrashRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  TrashItem makeItem({
    required String id,
    TrashItemType type = TrashItemType.photo,
    String title = 'テスト項目',
    DateTime? addedAt,
    Map<String, Object?> payload = const {},
  }) {
    final added = addedAt ?? DateTime(2026, 9, 6, 12);
    return TrashItem(
      id: id,
      type: type,
      title: title,
      addedAt: added,
      purgeAt: added.add(const Duration(days: 30)),
      payload: payload,
    );
  }

  test('追加した項目が watchAll に流れる', () async {
    await repository.add(makeItem(id: 'a', title: '選考結果のお知らせ'));

    final items = await repository.watchAll().first;

    expect(items, hasLength(1));
    expect(items.first.id, 'a');
    expect(items.first.title, '選考結果のお知らせ');
  });

  test('payload が Map のまま往復する', () async {
    await repository.add(
      makeItem(
        id: 'mail-1',
        type: TrashItemType.mail,
        payload: const {
          'messageId': 'abc123',
          'from': 'saiyo@example.com',
          'subject': '選考結果',
        },
      ),
    );

    final items = await repository.watchAll().first;

    expect(items.first.type, TrashItemType.mail);
    expect(items.first.payload['messageId'], 'abc123');
    expect(items.first.payload['from'], 'saiyo@example.com');
  });

  test('thumbnailPath が無くても保存できる', () async {
    await repository.add(makeItem(id: 'a'));

    final items = await repository.watchAll().first;

    expect(items.first.thumbnailPath, isNull);
  });

  test('remove で消える', () async {
    await repository.add(makeItem(id: 'a'));
    await repository.add(makeItem(id: 'b'));

    await repository.remove('a');
    final items = await repository.watchAll().first;

    expect(items, hasLength(1));
    expect(items.first.id, 'b');
  });

  test('新しく入れたものが先に並ぶ', () async {
    await repository.add(
      makeItem(id: 'old', addedAt: DateTime(2026, 9, 2)),
    );
    await repository.add(
      makeItem(id: 'new', addedAt: DateTime(2026, 9, 6)),
    );

    final items = await repository.watchAll().first;

    expect(items.map((item) => item.id).toList(), ['new', 'old']);
  });

  test('中身が変わると watchAll が新しいリストを流す', () async {
    // 画面が自動で描き直される根拠を確かめるテスト。
    // 先に Stream を購読しておき、あとから add したものが流れてくるか見る。
    final emitted = <List<TrashItem>>[];
    final subscription = repository.watchAll().listen(emitted.add);

    // pumpEventQueue は、待っている非同期処理を進めてくれるヘルパー。
    // これを挟まないと、購読した直後の「今の中身」がまだ届いていない。
    await pumpEventQueue();
    expect(emitted.last, isEmpty);

    await repository.add(makeItem(id: 'a'));
    await pumpEventQueue();

    expect(emitted.last, hasLength(1));

    await subscription.cancel();
  });
}
