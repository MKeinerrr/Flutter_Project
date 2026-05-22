import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.0,
            colors: [
              Color(0xFF101827),
              AppColors.bg0,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 220,
                      child: Image.asset(
                        'assets/images/bookmaster_splash.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _BookMasterLogo(accent: AppColors.accent);
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFF97F3E1),
                            AppColors.accent,
                          ],
                        ).createShader(bounds);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookMasterLogo extends StatelessWidget {
  const _BookMasterLogo({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Positioned(
            top: 18,
            left: 60,
            child: _ChairIcon(
              angle: -0.52,
              accent: accent,
            ),
          ),
          Positioned(
            top: 18,
            right: 60,
            child: _ChairIcon(
              angle: 0.52,
              accent: accent,
            ),
          ),
          Positioned(
            bottom: 28,
            left: 46,
            child: _ChairIcon(
              angle: -2.62,
              accent: accent,
            ),
          ),
          Positioned(
            bottom: 28,
            right: 46,
            child: _ChairIcon(
              angle: 2.62,
              accent: accent,
            ),
          ),
          Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          Positioned(
            top: 22,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bg1.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: accent,
                size: 28,
              ),
            ),
          ),
          Positioned(
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ClipboardTab(accent: accent),
                const SizedBox(width: 20),
                _ClipboardTab(accent: accent),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            child: Container(
              width: 60,
              height: 26,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            child: Container(
              width: 96,
              height: 10,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChairIcon extends StatelessWidget {
  const _ChairIcon({required this.angle, required this.accent});

  final double angle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 56,
        height: 86,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.72), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipboardTab extends StatelessWidget {
  const _ClipboardTab({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 18,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}