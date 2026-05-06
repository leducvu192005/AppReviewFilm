import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Screen/home.dart';

class Layout extends StatelessWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Home(),
      bottomNavigationBar: BottomMovieNav(),
    );
  }
}

class BottomMovieNav extends StatelessWidget {
  const BottomMovieNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(34, 0, 34, 12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF44484D).withValues(alpha: .9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD21E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Icon.svg',
                        width: 13.33,
                        height: 13.33,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 1),
                  const Text(
                    'Movie',
                    style: TextStyle(
                      color: Color(0xFF1D1D1D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const NavIcon(Icons.tv_outlined),
            const NavIcon(Icons.explore_outlined),
            const NavIcon(Icons.favorite_border),
            const NavIcon(Icons.person_outline),
          ],
        ),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  const NavIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white.withValues(alpha: .48), size: 18);
  }
}
