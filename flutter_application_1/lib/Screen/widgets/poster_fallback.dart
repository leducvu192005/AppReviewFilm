import 'package:flutter/material.dart';

class PosterFallback extends StatelessWidget {
  const PosterFallback({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withValues(alpha: .12),
      child: const Icon(Icons.movie, color: Color(0xFFFFD21E)),
    );
  }
}
