import 'package:flutter/material.dart';

class EmptyMovies extends StatelessWidget {
  const EmptyMovies({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      alignment: Alignment.center,
      child: Text(
        'No movies found',
        style: TextStyle(color: Colors.white.withValues(alpha: .6)),
      ),
    );
  }
}
