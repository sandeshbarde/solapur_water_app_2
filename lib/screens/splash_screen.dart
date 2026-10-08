import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

/// App Startup Splash Screen
/// Job: "Civic startup screen with authentication session verification."
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RipplePainter(_rippleAnimation.value, accent),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    size: 44,
                    color: accent,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.s20),
        Text(
          'Solapur Smart Water',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'JalNirnay AI Management',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.s28),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: disableAnimations
            ? content
            : FadeTransition(
                opacity: _fadeAnimation,
                child: content,
              ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1 - progress);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) + (progress * 50),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => oldDelegate.progress != progress;
}
