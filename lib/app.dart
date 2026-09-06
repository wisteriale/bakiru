import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/core/theme/app_theme.dart';
import 'package:bakiru/features/destroy/ui/shatter/shatter_page.dart';
import 'package:bakiru/features/epitaph/ui/epitaph_entry_page.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xfff7f6f2),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            const Text(
              'バキる',
              style: TextStyle(
                color: Color(0xff111111),
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const Spacer(flex: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HomeMenuButton(
                    icon: Icons.photo_outlined,
                    label: '写真',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('写真の取り込みは準備中です。')),
                    ),
                  ),
                  _HomeMenuButton(
                    icon: Icons.mail_outline,
                    label: 'メール',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => _MailSelectionPage(
                            loadMailItems: _PreviewMailSource.load,
                          ),
                        ),
                      );
                    },
                  ),
                  _HomeMenuButton(
                    icon: Icons.delete_outline,
                    label: 'ゴミ箱',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const _TrashItemsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onPressed,
        radius: 40,
        child: SizedBox(
          width: 64,
          height: 56,
          child: Icon(icon, size: 32, color: const Color(0xff111111)),
        ),
      ),
    );
  }
}

class _TrashItemsPage extends ConsumerWidget {
  const _TrashItemsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(trashRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(title: const Text('ゴミ箱')),
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
              builder: (context) => EpitaphEntryPage(
                item: item,
                onContinue: (epitaph) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => ShatterPage(
                        item: item,
                        epitaphText: epitaph,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
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

/// Gmailから選べるメールの取得処理。
///
/// 現在は仮データを返し、Gmail連携が完成したら
/// MailRepository.fetchRecent を呼ぶ関数へ差し替える。
typedef _MailItemsLoader = Future<List<TrashItem>> Function();

class _MailSelectionPage extends StatefulWidget {
  const _MailSelectionPage({required this.loadMailItems});

  final _MailItemsLoader loadMailItems;

  @override
  State<_MailSelectionPage> createState() => _MailSelectionPageState();
}

class _MailSelectionPageState extends State<_MailSelectionPage> {
  late final Future<List<TrashItem>> _mailItems;

  @override
  void initState() {
    super.initState();
    _mailItems = widget.loadMailItems();
  }

  void _selectMail(TrashItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EpitaphEntryPage(
          item: item,
          onContinue: (epitaph) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (context) => ShatterPage(
                  item: item,
                  epitaphText: epitaph,
                ),
              ),
              (route) => route.isFirst,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メールを選ぶ')),
      body: FutureBuilder<List<TrashItem>>(
        future: _mailItems,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('メールを読み込めませんでした。'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mailItems = snapshot.requireData;
          return ListView.separated(
            itemCount: mailItems.length,
            itemBuilder: (context, index) {
              final item = mailItems[index];
              return ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(item.title),
                subtitle: Text(_senderFor(item)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectMail(item),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        },
      ),
    );
  }

  String _senderFor(TrashItem item) {
    return item.payload['sender'] as String? ?? '送信者不明';
  }
}

class _PreviewMailSource {
  static Future<List<TrashItem>> load() async => [
        TrashItem(
          id: 'preview-mail-1',
          type: TrashItemType.mail,
          title: '選考結果のお知らせ',
          addedAt: DateTime(2026, 9, 6),
          purgeAt: DateTime(2026, 10, 6),
          payload: const {
            'messageId': 'preview-message-1',
            'sender': '採用担当 <recruit@example.com>',
          },
        ),
        TrashItem(
          id: 'preview-mail-2',
          type: TrashItemType.mail,
          title: '今後の選考について',
          addedAt: DateTime(2026, 9, 5),
          purgeAt: DateTime(2026, 10, 5),
          payload: const {
            'messageId': 'preview-message-2',
            'sender': '人事部 <hr@example.com>',
          },
        ),
      ];
}
