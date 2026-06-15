import 'package:flutter/material.dart';

class MoodClipper extends CustomClipper<Path> {
  final int selectedIndex;
  final double progress;

  MoodClipper({required this.selectedIndex, required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (selectedIndex == -1) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final itemWidth = size.width / 4;
    final centerX = itemWidth * selectedIndex + itemWidth / 2;

    final curveHeight = 22 * progress;

    path.moveTo(0, 0);

    path.lineTo(centerX - 35, 0);

    path.cubicTo(
      centerX - 22,
      -curveHeight * 0.4,
      centerX - 12,
      -curveHeight,
      centerX,
      -curveHeight,
    );

    path.cubicTo(
      centerX + 12,
      -curveHeight,
      centerX + 22,
      -curveHeight * 0.4,
      centerX + 35,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(MoodClipper oldClipper) =>
      oldClipper.selectedIndex != selectedIndex ||
      oldClipper.progress != progress;
}
