import 'package:flutter/material.dart';

class AudioVisualizer extends StatelessWidget {
  final List<double> audioLevels;

  const AudioVisualizer({super.key, required this.audioLevels});

  @override
  Widget build(BuildContext context) {
    print(audioLevels);
    return CustomPaint(
      size: Size(double.infinity, 100),
      painter: AudioVisualizerPainter(audioLevels: audioLevels),
    );
  }
}

class AudioVisualizerPainter extends CustomPainter {
  final List<double> audioLevels;
  final Color barColor;
  final double spacingFactor;
  final double borderRadius;

  AudioVisualizerPainter({
    required this.audioLevels,
    this.barColor = Colors.limeAccent,
    this.spacingFactor = 0.2,
    this.borderRadius = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (audioLevels.isEmpty) return;

    Paint paint =
        Paint()
          ..color = barColor
          ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;
    int numBars = audioLevels.length;

    double totalSpacing = (numBars - 1) * (width / numBars) * spacingFactor;
    double availableBarWidth = width - totalSpacing;
    double barWidth = numBars > 0 ? availableBarWidth / numBars : 0;

    // Smooth the levels before drawing
    List<double> smoothedLevels = smoothAudioLevels(audioLevels);

    for (int i = 0; i < smoothedLevels.length; i++) {
      double level = smoothedLevels[i];
      double normalizedLevel = level * 500;
      double barHeight = normalizedLevel.clamp(0, height);

      double x = i * (barWidth * (1 + spacingFactor / (1 - spacingFactor)));
      double y = height - barHeight;

      RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(bar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioVisualizerPainter oldDelegate) {
    return oldDelegate.audioLevels != audioLevels ||
        oldDelegate.barColor != barColor ||
        oldDelegate.spacingFactor != spacingFactor ||
        oldDelegate.borderRadius != borderRadius;
  }

  List<double> smoothAudioLevels(List<double> levels) {
    if (levels.length < 5) return levels;

    List<double> smoothed = [];
    for (int i = 0; i < levels.length; i++) {
      double sum = 0;
      int count = 0;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j >= 0 && j < levels.length) {
          sum += levels[j];
          count++;
        }
      }
      smoothed.add(sum / count);
    }
    return smoothed;
  }
}
