import 'dart:math' as math;

import 'package:bakiru/core/model/trash_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 画面をひび割れさせる、叩き割る演出の画面。
class ShatterPage extends StatefulWidget {
  /// [ShatterPage] を作る。
  const ShatterPage({required this.item, super.key});

  /// 叩き割る対象。
  final TrashItem item;

  @override
  State<ShatterPage> createState() => _ShatterPageState();
}

class _ShatterPageState extends State<ShatterPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  bool _isBroken = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _breakScreen() async {
    if (_isBroken) return;

    await HapticFeedback.heavyImpact();
    await _animation.forward();
    if (mounted) setState(() => _isBroken = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffcf7),
      appBar: AppBar(title: const Text('叩き割る')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final progress = _animation.value;
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Semantics(
                        button: true,
                        label: '画面を叩き割る',
                        child: GestureDetector(
                          onTap: _isBroken ? null : _breakScreen,
                          child: _GlassScreen(
                            item: widget.item,
                            crackProgress: progress,
                            isBroken: _isBroken,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isBroken)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        'バーン',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xfff04d54),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  if (_isBroken)
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('ごみ箱に戻る'),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}

class _GlassScreen extends StatelessWidget {
  const _GlassScreen({
    required this.item,
    required this.crackProgress,
    required this.isBroken,
  });

  final TrashItem item;
  final double crackProgress;
  final bool isBroken;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .68,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xfffbf9f4),
          border: Border.all(color: const Color(0xff252525), width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _ScreenDividers(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconFor(item.type), size: 54, color: const Color(0xff252525)),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    isBroken ? 'バキッ!' : 'バキる',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xfff04d54),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            if (crackProgress > 0)
              IgnorePointer(
                child: CustomPaint(
                  painter: _CrackPainter(progress: crackProgress),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(TrashItemType type) => switch (type) {
        TrashItemType.photo => Icons.photo_outlined,
        TrashItemType.mail => Icons.mail_outline,
        TrashItemType.text => Icons.link,
      };
}

class _ScreenDividers extends StatelessWidget {
  const _ScreenDividers();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          Spacer(flex: 2),
          Divider(color: Color(0xff252525), height: 1, thickness: 2),
          Spacer(flex: 5),
          Divider(color: Color(0xff252525), height: 1, thickness: 2),
          Spacer(flex: 2),
        ],
      );
}

class _CrackPainter extends CustomPainter {
  const _CrackPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .53);
    final paint = Paint()
      ..color = const Color(0xff252525).withValues(alpha: progress)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final endpoints = [
      Offset(.05, .16),
      Offset(.92, .12),
      Offset(.97, .43),
      Offset(.84, .82),
      Offset(.52, .97),
      Offset(.12, .88),
      Offset(.02, .56),
      Offset(.29, .03),
    ];

    for (var index = 0; index < endpoints.length; index++) {
      final end = Offset(endpoints[index].dx * size.width, endpoints[index].dy * size.height);
      final bend = Offset.lerp(center, end, .45)! +
          Offset(index.isEven ? 12 : -12, index.isEven ? -8 : 8);
      final visibleEnd = Offset.lerp(center, end, progress)!;
      final visibleBend = Offset.lerp(center, bend, progress)!;
      final crack = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(visibleBend.dx, visibleBend.dy)
        ..lineTo(visibleEnd.dx, visibleEnd.dy);
      canvas.drawPath(crack, paint);
    }
    canvas.drawCircle(center, 14 * progress, paint);
  }

  @override
  bool shouldRepaint(covariant _CrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
