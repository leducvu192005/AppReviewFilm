import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/setting/setting_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/Screen/favorite/favorite.dart';
import 'package:flutter_application_1/Screen/movie/home_movie.dart';
import 'package:flutter_application_1/Screen/TV_show/TV_show_home.dart';
import 'package:flutter_application_1/Screen/library/library_screen.dart';

class Layout extends StatefulWidget {
  final int initialIndex;

  const Layout({super.key, this.initialIndex = 0});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late int selectedIndex;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  final List<Widget> pages = [
    const Home(),
    const TVShowHome(),
    const LibraryScreen(),
    const FavoriteScreen(),
    const SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,

      body: pages[selectedIndex],

      bottomNavigationBar: BottomMovieNav(
        selectedIndex: selectedIndex,

        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

class BottomMovieNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomMovieNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(34, 0, 34, 12),

      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: const Color(0xFF44484D).withValues(alpha: .9),

          borderRadius: BorderRadius.circular(30),

          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            _buildSvgItem(
              index: 0,
              title: 'Movie',
              icon: 'assets/icons/Icon.svg',
            ),

            _buildSvgItem(
              index: 1,
              title: 'Tv Show',
              icon: 'assets/icons/tv-02.svg',
            ),

            _buildSvgItem(
              index: 2,
              title: 'Library',
              icon: 'assets/icons/image-01.svg',
            ),

            _buildIconItem(
              index: 3,
              title: 'Favorite',
              icon: Icons.favorite_border,
            ),

            _buildIconItem(
              index: 4,
              title: 'Setting',
              icon: Icons.settings_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgItem({
    required int index,
    required String title,
    required String icon,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 0,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD21E) : Colors.transparent,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 18,
              height: 18,

              colorFilter: ColorFilter.mode(
                isSelected ? Colors.black : Colors.grey,

                BlendMode.srcIn,
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              child: isSelected
                  ? Padding(
                      key: ValueKey(title),
                      padding: const EdgeInsets.only(left: 6),

                      child: Text(
                        title,

                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 0,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD21E) : Colors.transparent,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 20,

              color: isSelected ? Colors.black : Colors.grey,
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              child: isSelected
                  ? Padding(
                      key: ValueKey(title),
                      padding: const EdgeInsets.only(left: 6),

                      child: Text(
                        title,

                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
