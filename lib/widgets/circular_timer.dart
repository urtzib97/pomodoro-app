import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/timer_controller.dart';
import '../core/ui_ids.dart';

class CircularTimer extends StatelessWidget {
  final double diameter;

  const CircularTimer({
    super.key,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('CircularTimer diameter=$diameter');

    return SizedBox(
      width: diameter,
      height: diameter,
      child: GetBuilder<TimerController>(
        id: UiIds.ID_TIMER_PROGRESS,
        builder: (timerController) {
          final progress = timerController.progress;
          final isBreak = timerController.isBreakPhase;

          Color progressColor;
          if (isBreak) {
            progressColor =
                timerController.currentBreakType == BreakType.longBreak
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.secondary;
          } else {
            progressColor = Theme.of(context).colorScheme.primary;
          }

          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: progressColor, end: progressColor),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (_, animatedColor, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CustomPaint(
                    size: Size(diameter, diameter),
                    painter: CircleBackgroundPainter(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  // Progress circle
                  CustomPaint(
                    size: Size(diameter, diameter),
                    painter: CircleProgressPainter(
                      progress: progress,
                      color: animatedColor ?? progressColor,
                    ),
                  ),
                  // Time display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GetBuilder<TimerController>(
                        id: UiIds.ID_TIMER_TEXT,
                        builder: (controller) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            controller.formattedTime,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                              // Scale font relative to size
                              fontSize: diameter * 0.28,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -2,
                              fontFeatures: [
                                const FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

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
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
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
