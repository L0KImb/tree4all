import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RankBadge extends StatelessWidget {
  final String icone;
  final double progress; // 0..1
  final VoidCallback onTap;

  const RankBadge({super.key, required this.icone, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(46, 46),
              painter: _RingPainter(progress: progress),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFF3A2760), AppColors.night]),
              ),
              alignment: Alignment.center,
              child: Text(icone, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = AppColors.goldBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * 3.14159265 * progress.clamp(0, 1);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159265 / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
