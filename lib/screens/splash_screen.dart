import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../screens/main_navigation.dart';
import '../widgets/parallax_floating_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late AnimationController _cursorController;
  late AnimationController _fadeController;

  final String _appName = 'WallVault';
  String _displayedText = '';
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

    // Typing animation controller
    _typingController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _appName.length * 150,
      ), // 150ms per character
    );

    // Cursor blinking controller
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);

    // Fade out controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Listen to typing animation
    _typingController.addListener(() {
      setState(() {
        final progress = _typingController.value;
        final charCount = (_appName.length * progress).floor();
        _displayedText = _appName.substring(0, charCount);
      });
    });

    // Listen to cursor animation
    _cursorController.addListener(() {
      setState(() {
        _showCursor = _cursorController.value > 0.5;
      });
    });

    // Start the animation sequence
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Wait a bit before starting
    await Future.delayed(const Duration(milliseconds: 500));

    // Start typing animation
    await _typingController.forward();

    // Keep the full text visible for a moment
    await Future.delayed(const Duration(milliseconds: 800));

    // Stop cursor blinking
    _cursorController.stop();
    setState(() {
      _showCursor = false;
    });

    // Wait a bit more
    await Future.delayed(const Duration(milliseconds: 400));

    // Fade out
    await _fadeController.forward();

    // Navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    _cursorController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F5F5),
      body: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController),
        child: Stack(
          children: [
            // Animated parallax floating background
            const Positioned.fill(child: ParallaxFloatingBackground()),

            // Glass container with text
            Center(
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  thickness: 20,
                  blur: 15,
                  glassColor: isDark
                      ? const Color(0x33FFFFFF)
                      : const Color(0x33000000),
                ),
                child: LiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 32,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Typed text
                        Text(
                          _displayedText,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),

                        // Blinking cursor
                        AnimatedOpacity(
                          opacity: _showCursor ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            width: 3,
                            height: 42,
                            margin: const EdgeInsets.only(left: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
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
