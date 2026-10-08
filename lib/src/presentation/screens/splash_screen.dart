import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import 'home_shell.dart';

/// Animated brand splash that plays once, then fades into [HomeShell].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final AnimationController _exit;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoRotation;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _tagOpacity;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _logoScale = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _logoRotation = Tween<double>(begin: -0.08, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.32, 0.62, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.32, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _tagOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.52, 0.85, curve: Curves.easeOut),
    );

    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );
    _exitScale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _intro.forward();
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted || _navigating) return;
    await _goHome();
  }

  Future<void> _goHome() async {
    if (_navigating) return;
    _navigating = true;
    _pulse.stop();
    await _exit.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.brand,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _pulse, _exit]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Scaffold(
                backgroundColor: AppColors.brand,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _SplashAtmosphere(),
                    SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.scale(
                                  scale: pulse.value,
                                  child: Container(
                                    width: 132,
                                    height: 132,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12 + (pulse.value - 0.92) * 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Transform.rotate(
                                    angle: _logoRotation.value * math.pi,
                                    child: Transform.scale(
                                      scale: 0.72 + (_logoScale.value * 0.28),
                                      child: const _BrandMark(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            SlideTransition(
                              position: _titleSlide,
                              child: FadeTransition(
                                opacity: _titleOpacity,
                                child: Text(
                                  'Pixel Vault',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.6,
                                        height: 1.1,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeTransition(
                              opacity: _tagOpacity,
                              child: Text(
                                'Discover photos from around the world',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.78),
                                      height: 1.35,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: MediaQuery.paddingOf(context).bottom + 28,
                      child: FadeTransition(
                        opacity: _tagOpacity,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Soft radial glow + diagonal wash — brand atmosphere, not flat fill.
class _SplashAtmosphere extends StatelessWidget {
  const _SplashAtmosphere();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.55),
          radius: 1.15,
          colors: [
            const Color(0xFF2A7A62),
            AppColors.brand,
            const Color(0xFF0F3D30),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _GridWashPainter(
          color: Colors.white.withValues(alpha: 0.045),
        ),
      ),
    );
  }
}

class _GridWashPainter extends CustomPainter {
  _GridWashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridWashPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Mini masonry-style mark — reads as a photo vault without an asset.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const CustomPaint(
        painter: _MasonryMarkPainter(color: AppColors.brand),
      ),
    );
  }
}

class _MasonryMarkPainter extends CustomPainter {
  const _MasonryMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final soft = Paint()..color = color.withValues(alpha: 0.55);
    final r = BorderRadius.circular(6);

    final left = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width * 0.46, size.height * 0.62),
      topLeft: r.topLeft,
      topRight: r.topRight,
      bottomLeft: r.bottomLeft,
      bottomRight: r.bottomRight,
    );
    final topRight = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.54,
        0,
        size.width * 0.46,
        size.height * 0.36,
      ),
      topLeft: r.topLeft,
      topRight: r.topRight,
      bottomLeft: r.bottomLeft,
      bottomRight: r.bottomRight,
    );
    final bottomRight = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.54,
        size.height * 0.44,
        size.width * 0.46,
        size.height * 0.56,
      ),
      topLeft: r.topLeft,
      topRight: r.topRight,
      bottomLeft: r.bottomLeft,
      bottomRight: r.bottomRight,
    );
    final bottomLeft = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        0,
        size.height * 0.7,
        size.width * 0.46,
        size.height * 0.3,
      ),
      topLeft: r.topLeft,
      topRight: r.topRight,
      bottomLeft: r.bottomLeft,
      bottomRight: r.bottomRight,
    );

    canvas.drawRRect(left, paint);
    canvas.drawRRect(topRight, soft);
    canvas.drawRRect(bottomRight, paint);
    canvas.drawRRect(bottomLeft, soft);
  }

  @override
  bool shouldRepaint(covariant _MasonryMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
