import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/timer_controller.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timerController = Get.find<TimerController>();

    return Obx(() {
      final progress = timerController.progress;
      final isBreak = timerController.timerState.value == TimerState.break_time;
      
      Color progressColor;
      if (isBreak) {
        progressColor = timerController.currentBreakType.value == BreakType.long_break
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.secondary;
      } else {
        progressColor = Theme.of(context).colorScheme.primary;
      }

      return SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            CustomPaint(
              size: const Size(280, 280),
              painter: CircleBackgroundPainter(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            // Progress circle
            CustomPaint(
              size: const Size(280, 280),
              painter: CircleProgressPainter(
                progress: progress,
                color: progressColor,
              ),
            ),
            // Time display
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timerController.formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class CircleBackgroundPainter extends CustomPainter {
  final Color color;

  CircleBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
