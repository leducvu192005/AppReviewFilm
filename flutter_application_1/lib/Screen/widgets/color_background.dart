import 'package:flutter/material.dart';

class MovieHomeBackground extends StatelessWidget {
  const MovieHomeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const Color figmaColor = Color(0xFF101112);

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B1C2C),
                Color(0xFF12303A),
                figmaColor,
                figmaColor,
              ],
              stops: [0.0, 0.25, 0.55, 1.0],
            ),
          ),
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.7),
              radius: 1.0,
              colors: [
                const Color(0xFF1ED5A9).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, 0.8),
              radius: 1.1,
              colors: [
                const Color(0xFF7B3FE4).withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),

        DecoratedBox(
          decoration: BoxDecoration(color: figmaColor.withValues(alpha: 0.5)),
        ),

        child,
      ],
    );
  }
}
