import 'package:bakiru/core/model/trash_item.dart';
import 'package:flutter/material.dart';

/// 破壊前に、対象への思いを入力する画面。
///
/// 実際の保存は破壊成功後に行うため、ここでは入力値を [onContinue] へ渡す。
class EpitaphEntryPage extends StatefulWidget {
  /// [EpitaphEntryPage] を作る。
  const EpitaphEntryPage({
    required this.item,
    required this.onContinue,
    super.key,
  });

  /// 破壊する対象。
  final TrashItem item;

  /// 入力した言葉、または空欄のまま進むときの null を受け取る。
  final ValueChanged<String?> onContinue;

  @override
  State<EpitaphEntryPage> createState() => _EpitaphEntryPageState();
}

class _EpitaphEntryPageState extends State<EpitaphEntryPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final text = _controller.text.trim();
    widget.onContinue(text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('遺言を残す')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'このメールに対する思いを残せます。\n'
                'メール本文は保存されず、言葉だけが残ります。',
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 120,
                maxLines: 4,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: '例：第一志望だった。悔しいけど、次へ進む。',
                  labelText: '遺言',
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _continue,
                child: const Text('叩き割る画面へ'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => widget.onContinue(null),
                child: const Text('言葉を残さず進む'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
