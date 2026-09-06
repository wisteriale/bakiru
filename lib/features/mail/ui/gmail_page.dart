import 'dart:async';

import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/features/mail/provider/mail_repository_provider.dart';
import 'package:bakiru/features/mail/ui/sign_in_button/sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// お祈りメールを拾うための Gmail 検索条件。
///
/// 件名だけでは拾いきれないので、本文によく出る定型句も混ぜている。
/// 検索は Gmail のサーバー側で行われ、アプリが受け取るのは一致した
/// メールのヘッダだけ。本文がアプリに入ってくることはない。
const String _rejectionQuery =
    '"誠に残念ながら" OR "ご期待に添えない" OR "ご期待に沿えない" '
    'OR "今後のご活躍をお祈り" OR subject:(選考結果 OR 選考のご案内)';

/// メール一覧の絞り込み。
enum _MailFilter {
  rejection('お祈りメール', _rejectionQuery),
  all('すべて', null);

  const _MailFilter(this.label, this.query);

  final String label;
  final String? query;
}

/// Gmail からメールを取り込む画面。
///
/// 選んだメールを [TrashItem] のリストにして `Navigator.pop` で返す。
/// ここで直接ごみ箱に入れないのは、mail 機能から trash 機能を
/// 直接 import しない規約のため。ごみ箱に入れるのは呼び出した側の仕事。
class GmailPage extends ConsumerStatefulWidget {
  /// [GmailPage] を作る。
  const GmailPage({super.key});

  @override
  ConsumerState<GmailPage> createState() => _GmailPageState();
}

class _GmailPageState extends ConsumerState<GmailPage> {
  List<TrashItem> _mails = const [];
  final Set<String> _selectedIds = {};
  _MailFilter _filter = _MailFilter.rejection;
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // 前回の資格情報が残っていれば、これで黙ってサインインが済む。
    // 残っていなければ何も起きず、サインインボタンが表示される。
    unawaited(ref.read(mailRepositoryProvider).signIn());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final mails = await ref
          .read(mailRepositoryProvider)
          .fetchRecent(query: _filter.query);
      if (!mounted) {
        return;
      }
      setState(() {
        _mails = mails;
        _selectedIds.clear();
        _loading = false;
        _loaded = true;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'メールを取得できませんでした。\n$error';
        _loading = false;
      });
    }
  }

  void _toggle(String id, {required bool selected}) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(gmailSignedInProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gmail から取り込む')),
      body: signedIn.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('サインインの状態を確認できませんでした。\n$error'),
          ),
        ),
        data: (isSignedIn) =>
            isSignedIn ? _buildMailList(context) : _buildSignIn(context),
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                final selected = _mails
                    .where((mail) => _selectedIds.contains(mail.id))
                    .toList();
                Navigator.of(context).pop(selected);
              },
              icon: const Icon(Icons.delete_outline),
              label: Text('ごみ箱に入れる (${_selectedIds.length})'),
            ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Gmail のメールをごみ箱に入れられます。\n'
              'まず Google にサインインしてください。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMailList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TrashNotice(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              for (final filter in _MailFilter.values)
                ChoiceChip(
                  label: Text(filter.label),
                  selected: _filter == filter,
                  onSelected: (_) async {
                    setState(() => _filter = filter);
                    await _load();
                  },
                ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_loaded) {
      return Center(
        child: FilledButton.icon(
          onPressed: () async {
            await _load();
          },
          icon: const Icon(Icons.download),
          label: const Text('メールを読み込む'),
        ),
      );
    }

    if (_mails.isEmpty) {
      return const Center(child: Text('該当するメールは見つかりませんでした。'));
    }

    return ListView.builder(
      itemCount: _mails.length,
      itemBuilder: (context, index) {
        final mail = _mails[index];
        return CheckboxListTile(
          value: _selectedIds.contains(mail.id),
          onChanged: (checked) => _toggle(mail.id, selected: checked ?? false),
          title: Text(mail.title),
          subtitle: Text(mail.payload['from']?.toString() ?? ''),
        );
      },
    );
  }
}

/// メールを壊したときに何が起きるかの説明。
///
/// 「完全削除される」と誤解させないために必ず出す。
class _TrashNotice extends StatelessWidget {
  const _TrashNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
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
                '壊したメールは Gmail のゴミ箱に移動します。\n'
                '30日後に Gmail 側で自動削除されます。',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
