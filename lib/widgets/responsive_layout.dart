import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum DeviceScreenType { compact, medium, expanded }

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, DeviceScreenType screenType) builder;

  const ResponsiveLayout({super.key, required this.builder});

  static DeviceScreenType getScreenType(double width) {
    if (width < 600) return DeviceScreenType.compact;
    if (width <= 1100) return DeviceScreenType.medium;
    return DeviceScreenType.expanded;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(constraints.maxWidth);
        return builder(context, constraints, screenType);
      },
    );
  }
}

/// Content wrapper that caps width and centers content on wide screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cap = maxWidth ?? (constraints.maxWidth > 1100 ? 1100 : 720);
        if (constraints.maxWidth < 600) {
          cap = double.infinity;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cap),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
