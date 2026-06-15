import 'package:flutter/material.dart';
import '../../core/assets/assets_manager.dart';

class SplashBackground extends StatelessWidget {
  final int pageIndex;

  const SplashBackground({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final alignments = [
      const Alignment(-0.9, 1.8),
      const Alignment(0.2, 0.8),
      const Alignment(1.0, 0.4),
    ];

    final bottomImages = [
      AssetsManager.sIcon,
      AssetsManager.sIcon2,
      AssetsManager.sIcon3,
    ];

    final topImages = [
      AssetsManager.topCorner1,
      AssetsManager.topCorner2,
      AssetsManager.topCorner3,
    ];

    return Stack(
      children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          alignment: alignments[pageIndex],
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Transform.scale(
              scale: 1.8,
              child: Image.asset(
                bottomImages[pageIndex],
                key: ValueKey(bottomImages[pageIndex]),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          top: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Image.asset(
              topImages[pageIndex],
              key: ValueKey(topImages[pageIndex]),
              width: MediaQuery.of(context).size.width * 0.44,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
