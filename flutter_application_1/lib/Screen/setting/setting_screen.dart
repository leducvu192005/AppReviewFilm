import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const String appPackageName = 'com.company.movieapp';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$appPackageName';

  static const String policyUrl = 'https://www.google.com/';

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        final Uri url = Uri.parse(playStoreUrl);

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Review Error: $e');
    }
  }

  void _shareApp() {
    Share.share(
      '🎬 Watch movies with Movie App!\n'
      'Download now:\n'
      '$playStoreUrl',
    );
  }

  Future<void> _openPolicy() async {
    final Uri uri = Uri.parse(policyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFC107),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101112),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF101112).withOpacity(0.5),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(0, 192, 186, 186),
                    const Color(0xFF101112).withOpacity(0.8),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    icon: Icons.star_border,
                    title: "Rate This App",
                    onTap: _rateApp,
                  ),

                  const SizedBox(height: 18),

                  _buildButton(
                    icon: Icons.share,
                    title: "Share App",
                    onTap: _shareApp,
                  ),

                  const SizedBox(height: 18),

                  _buildButton(
                    icon: Icons.policy_outlined,
                    title: "Policy",
                    onTap: _openPolicy,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
