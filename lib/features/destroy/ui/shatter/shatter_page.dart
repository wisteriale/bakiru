import 'package:bakiru/core/model/trash_item.dart';
import 'package:flutter/material.dart';

/// 選んだ項目を叩き割る演出を表示する仮画面。
///
/// 次の段階で、この中央部分をRiveの演出へ置き換える。
class ShatterPage extends StatelessWidget {
  /// [ShatterPage] を作る。
  const ShatterPage({required this.item, super.key});

  /// 叩き割る対象。
  final TrashItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('叩き割る')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.front_hand_outlined,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text('ここに「叩き割る」演出を追加します。'),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('ごみ箱に戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
