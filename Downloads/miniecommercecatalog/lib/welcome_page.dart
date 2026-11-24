import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'app_theme.dart';
import 'cartoon_character.dart';
import 'page_transitions.dart';
import 'shiny_logo.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const double _girlHeight = 125;
  static const double _girlOverflow = 16;
  static const double _girlBackInset = 0.10;
  static const double _girlWidth = _girlHeight * 501 / 531;
  static const double _gutter =
      _girlWidth * (1 - _girlBackInset) - _girlOverflow;

  Widget _girl() {
    return const CartoonCharacter(
      bodyAsset: 'assets/girl.png',
      imageWidth: 501,
      imageHeight: 531,
      height: _girlHeight,
      lidColor: Color(0xFFFAD7B1),
      blinkPhase: 0.45,
      eyes: [
        CharacterEye(cx: 103.2, cy: 125.5, rx: 15, ry: 11, angleDeg: 0),
        CharacterEye(cx: 172.3, cy: 127, rx: 15, ry: 11, angleDeg: 0),
      ],
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: glassDecoration(radius: 28, alpha: 0.18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ShinyLogo(height: 120, fallbackSize: 65),
          const SizedBox(height: 20),
          const Text(
            'AAST Shopping Catalog',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Discover products you will love.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: whiteButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  slideFadeRoute(page: const LoginPage()),
                );
              },
              child: const Text(
                'Welcome to our catalog',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kDeepRed,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const GradientBackground(),
            SafeArea(
              child: Center(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            bottom: 0,
                            right: -_girlOverflow,
                            child: _girl(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: _gutter,
                            ),
                            child: _card(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}