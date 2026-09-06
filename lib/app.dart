import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/core/theme/app_theme.dart';
import 'package:bakiru/features/destroy/ui/shatter/shatter_page.dart';
import 'package:bakiru/features/trash/provider/trash_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリ全体のテーマと最初の画面を組み立てるウィジェット。
class BakiruApp extends StatelessWidget {
  /// [BakiruApp] を作る。
  const BakiruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'バキる',
      theme: AppTheme.light(),
      home: const _TrashHomePage(),
    );
  }
}

class _TrashHomePage extends ConsumerWidget {
  const _TrashHomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(trashRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(title: const Text('バキる')),
      body: StreamBuilder<List<TrashItem>>(
        stream: items,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('ごみ箱を読み込めませんでした。'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trashItems = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SafetyNotice(),
              const SizedBox(height: 24),
              Text('処分待ち', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (trashItems.isEmpty)
                const _EmptyTrashMessage()
              else
                ...trashItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TrashItemCard(item: item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '端末の写真は削除されません。\n'
                'アプリ内に取り込んだコピーだけが壊れます。',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrashMessage extends StatelessWidget {
  const _EmptyTrashMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('まだ処分待ちのものはありません。')),
    );
  }
}

class _TrashItemCard extends StatelessWidget {
  const _TrashItemCard({required this.item});

  final TrashItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconFor(item.type))),
        title: Text(item.title),
        subtitle: Text(_labelFor(item.type)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ShatterPage(item: item),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(TrashItemType type) {
    return switch (type) {
      TrashItemType.photo => Icons.photo_outlined,
      TrashItemType.mail => Icons.mail_outline,
      TrashItemType.text => Icons.link,
    };
  }

  String _labelFor(TrashItemType type) {
    return switch (type) {
      TrashItemType.photo => '写真のコピー',
      TrashItemType.mail => 'Gmailのメール',
      TrashItemType.text => 'テキスト・URL',
    };
  }
}
