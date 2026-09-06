import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bakiru/core/model/trash_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// タップした位置からガラスにひびが入る、叩き割る演出の画面。
class ShatterPage extends StatefulWidget {
  /// [ShatterPage] を作る。
  const ShatterPage({
    required this.item,
    this.epitaphText,
    super.key,
  });

  /// 叩き割る対象。
  final TrashItem item;

  /// 破壊成功時に保存する遺言の下書き。
  ///
  /// 実際の保存は、Destroyer が破壊を完了した時点で行う。
  final String? epitaphText;

  @override
  State<ShatterPage> createState() => _ShatterPageState();
}

class _ShatterPageState extends State<ShatterPage>
    with SingleTickerProviderStateMixin {
  static const _holeRadius = .09;
  final _screenKey = GlobalKey();
  final List<Offset> _impactPoints = [];
  final List<_GlassHole> _holes = [];
  bool _isFinishing = false;
  bool _showCompletion = false;
  late final AnimationController _finishAnimation;
  ui.Image? _screenSnapshot;

  @override
  void initState() {
    super.initState();
    _finishAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    _finishAnimation.dispose();
    _screenSnapshot?.dispose();
    super.dispose();
  }

  void _strike(TapUpDetails details) {
    if (_isFinishing) return;
    final renderBox = _screenKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final size = renderBox.size;
    final point = Offset(
      (localPosition.dx / size.width).clamp(0.0, 1.0) as double,
      (localPosition.dy / size.height).clamp(0.0, 1.0) as double,
    );

    setState(() {
      _impactPoints.add(point);
      _registerHole(point);
    });
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  Future<void> _finishShatter() async {
    if (_isFinishing) return;

    final snapshot = await _captureScreen();
    if (!mounted) return;
    setState(() {
      _screenSnapshot = snapshot;
      _isFinishing = true;
    });
    await HapticFeedback.heavyImpact();
    await _finishAnimation.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    setState(() => _showCompletion = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Destroyer の接続後は、ここで破壊成功を待ってから画面を閉じる。
    Navigator.of(context).pop();
  }

  Future<ui.Image?> _captureScreen() async {
    final renderObject = _screenKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    try {
      return await renderObject.toImage(pixelRatio: 1);
    } on Exception {
      return null;
    }
  }

  void _registerHole(Offset point) {
    for (final hole in _holes) {
      if ((hole.point - point).distance < _holeRadius) {
        hole.impactCount++;
        return;
      }
    }

    final nearbyPoints = _impactPoints
        .where((impact) => (impact - point).distance < _holeRadius)
        .toList();
    if (nearbyPoints.length < 3) return;

    final anchor = _impactPoints.firstWhere(nearbyPoints.contains);
    _holes.add(
      _GlassHole(point: anchor, seed: _holes.length, impactCount: nearbyPoints.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151515),
      appBar: AppBar(
        title: const Text('叩き割る'),
        backgroundColor: const Color(0xff151515),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              const Text(
                '同じ場所を叩き続けると、ガラスが抜ける。',
                style: TextStyle(
                  color: Color(0xffd8d8d8),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTapUp: _strike,
                    onLongPress: _finishShatter,
                    child: RepaintBoundary(
                      key: _screenKey,
                      child: AnimatedBuilder(
                        animation: _finishAnimation,
                        builder: (context, _) => _GlassScreen(
                          item: widget.item,
                          impactPoints: List<Offset>.unmodifiable(_impactPoints),
                          holes: List<_GlassHole>.unmodifiable(_holes),
                          isFinishing: _isFinishing,
                          shatterProgress: _finishAnimation.value,
                          screenSnapshot: _screenSnapshot,
                          showCompletion: _showCompletion,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassScreen extends StatelessWidget {
  const _GlassScreen({
    required this.item,
    required this.impactPoints,
    required this.holes,
    required this.isFinishing,
    required this.shatterProgress,
    required this.screenSnapshot,
    required this.showCompletion,
  });

  final TrashItem item;
  final List<Offset> impactPoints;
  final List<_GlassHole> holes;
  final bool isFinishing;
  final double shatterProgress;
  final ui.Image? screenSnapshot;
  final bool showCompletion;

  @override
  Widget build(BuildContext context) {
    final isBroken = impactPoints.isNotEmpty;

    return AspectRatio(
      aspectRatio: .68,
      child: Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: const Color(0xffd8d8d8),
          border: Border.all(color: const Color(0xfff5f5f5), width: 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - Curves.easeIn.transform(shatterProgress),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _ScreenDividers(),
                  Opacity(
                    opacity: isBroken ? .28 : 1,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconFor(item.type),
                            color: Colors.black,
                            size: 56,
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'monospace',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _GlassCrackPainter(
                        impactPoints: impactPoints,
                        holes: holes,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isFinishing)
              IgnorePointer(
                child: CustomPaint(
                  painter: _EmailShardPainter(
                    progress: shatterProgress,
                    screenSnapshot: screenSnapshot,
                  ),
                ),
              ),
            if (showCompletion)
              const ColoredBox(
                color: Color(0xff151515),
                child: Center(
                  child: Image(image: AssetImage('assets/images/good.png')),
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
          Divider(color: Color(0xff151515), height: 1, thickness: 1),
          Spacer(flex: 5),
          Divider(color: Color(0xff151515), height: 1, thickness: 1),
          Spacer(flex: 2),
        ],
      );
}

class _EmailShardPainter extends CustomPainter {
  const _EmailShardPainter({
    required this.progress,
    required this.screenSnapshot,
  });

  final double progress;
  final ui.Image? screenSnapshot;

  @override
  void paint(Canvas canvas, Size size) {
    final easedProgress = Curves.easeOutCubic.transform(progress);
    final center = Offset(size.width / 2, size.height / 2);
    final image = screenSnapshot;

    for (var index = 0; index < 30; index++) {
      final column = index % 5;
      final row = index ~/ 5;
      final origin = Offset(
        size.width * (.12 + column * .19),
        size.height * (.08 + row * .16),
      );
      final rawDirection = origin - center;
      final direction = rawDirection.distance == 0
          ? const Offset(0, -1)
          : rawDirection / rawDirection.distance;
      final travel = size.shortestSide * (.28 + _fragmentNoise(index) * .45);
      final position = origin + direction * travel * easedProgress;
      final rotation = (_fragmentNoise(index + 30) - .5) * 7 * easedProgress;
      final width = 26 + _fragmentNoise(index + 60) * 30;
      final sourceAspect = image == null
          ? .8
          : (image.width / 5) / (image.height / 6);
      final height = width / sourceAspect;
      final fragmentBounds = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      final edge = Paint()
        ..color = const Color(0xff151515)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      final fragment = _fragmentPath(fragmentBounds, index);

      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(rotation)
        ..clipPath(fragment);
      if (image != null) {
        final source = _sourceRect(image, column, row);
        canvas.drawImageRect(image, source, fragmentBounds, Paint());
      } else {
        canvas.drawRect(
          fragmentBounds,
          Paint()..color = const Color(0xffd8d8d8),
        );
      }
      canvas
        ..drawPath(fragment, edge)
        ..restore();
    }
  }

  Path _fragmentPath(Rect bounds, int seed) {
    final path = Path();
    final points = [
      Offset(bounds.left, bounds.top + bounds.height * _fragmentNoise(seed)),
      Offset(bounds.left + bounds.width * .7, bounds.top),
      Offset(bounds.right, bounds.top + bounds.height * .3),
      Offset(bounds.right - bounds.width * .25, bounds.bottom),
      Offset(bounds.left + bounds.width * .2, bounds.bottom),
    ];
    path.addPolygon(points, true);
    return path;
  }

  Rect _sourceRect(ui.Image image, int column, int row) {
    final cellWidth = image.width / 5;
    final cellHeight = image.height / 6;
    return Rect.fromLTWH(
      column * cellWidth,
      row * cellHeight,
      cellWidth,
      cellHeight,
    );
  }

  double _fragmentNoise(int value) {
    return (math.sin(value * 19.173) * 7584.31).abs() % 1;
  }

  @override
  bool shouldRepaint(covariant _EmailShardPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GlassCrackPainter extends CustomPainter {
  const _GlassCrackPainter({
    required this.impactPoints,
    required this.holes,
  });

  final List<Offset> impactPoints;
  final List<_GlassHole> holes;

  @override
  void paint(Canvas canvas, Size size) {
    for (var impactIndex = 0;
        impactIndex < impactPoints.length;
        impactIndex++) {
      _drawImpact(canvas, size, impactPoints[impactIndex], impactIndex);
    }

    for (final hole in holes) {
      _drawHole(canvas, size, hole);
    }
  }

  void _drawImpact(Canvas canvas, Size size, Offset normalizedPoint, int seed) {
    final impact = Offset(
      normalizedPoint.dx * size.width,
      normalizedPoint.dy * size.height,
    );
    final primaryPaint = Paint()
      ..color = const Color(0xff101010)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var ray = 0; ray < 30; ray++) {
      final angle = ray * math.pi * 2 / 30 + _noise(seed + ray) * .13;
      final maxDistance = size.longestSide * (.34 + _noise(ray + seed) * .3);
      final segments = 4 + (ray % 3);
      final path = Path()..moveTo(impact.dx, impact.dy);

      for (var segment = 1; segment <= segments; segment++) {
        final distance = maxDistance * segment / segments;
        final sideways = (_noise(seed * 7 + ray * 3 + segment) - .5) * 13;
        final point = impact +
            Offset(math.cos(angle), math.sin(angle)) * distance +
            Offset(math.cos(angle + math.pi / 2), math.sin(angle + math.pi / 2)) *
                sideways;
        path.lineTo(point.dx, point.dy);

        if (segment > 1 && (ray + segment) % 3 == 0) {
          _drawBranch(canvas, point, angle, primaryPaint, seed + ray + segment);
        }
      }
      canvas.drawPath(path, primaryPaint);
    }

    _drawImpactStar(canvas, impact, primaryPaint, seed);
  }

  void _drawBranch(
    Canvas canvas,
    Offset start,
    double parentAngle,
    Paint paint,
    int seed,
  ) {
    final angle = parentAngle + (seed.isEven ? .6 : -.6);
    final length = 12 + _noise(seed) * 20;
    canvas.drawLine(
      start,
      start + Offset(math.cos(angle), math.sin(angle)) * length,
      paint,
    );
  }

  void _drawImpactStar(Canvas canvas, Offset impact, Paint paint, int seed) {
    final star = Path();
    for (var point = 0; point < 9; point++) {
      final angle = point * math.pi * 2 / 9;
      final radius = 4 + _noise(seed + point) * 7;
      final position = impact + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (point == 0) {
        star.moveTo(position.dx, position.dy);
      } else {
        star.lineTo(position.dx, position.dy);
      }
    }
    star.close();
    canvas.drawPath(star, paint);
  }

  void _drawHole(Canvas canvas, Size size, _GlassHole holeData) {
    final normalizedPoint = holeData.point;
    final seed = holeData.seed;
    final center = Offset(
      normalizedPoint.dx * size.width,
      normalizedPoint.dy * size.height,
    );
    final extraRadius = math.min((holeData.impactCount - 3) * .03, .1);
    final baseRadius = size.shortestSide * (.21 + extraRadius);
    final hole = Path();
    for (var point = 0; point < 11; point++) {
      final angle = point * math.pi * 2 / 11;
      final radius = baseRadius * (.55 + _noise(seed + point * 11) * .8);
      final position = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (point == 0) {
        hole.moveTo(position.dx, position.dy);
      } else {
        hole.lineTo(position.dx, position.dy);
      }
    }
    hole.close();

    canvas.drawPath(hole, Paint()..color = const Color(0xff050505));
  }

  double _noise(int value) => (math.sin(value * 12.9898) * 43758.5453).abs() % 1;

  @override
  bool shouldRepaint(covariant _GlassCrackPainter oldDelegate) =>
      oldDelegate.impactPoints != impactPoints || oldDelegate.holes != holes;
}

class _GlassHole {
  _GlassHole({
    required this.point,
    required this.seed,
    required this.impactCount,
  });

  final Offset point;
  final int seed;
  int impactCount;
}
