import 'dart:math' as math;

import 'package:clerk_flutter/src/widgets/ui/style/clerk_theme.dart';
import 'package:flutter/material.dart';

/// Animated loading indicator (three pulsing dots) for Clerk UI and
/// [ClerkAuthConfig.loading].
class ClerkLoadingIndicator extends StatefulWidget {
  /// Construct a new [ClerkLoadingIndicator]
  const ClerkLoadingIndicator({
    super.key,
    this.size = 36,
    this.dotSize,
    this.spacing = 6,
  });

  /// Row height
  final double size;

  /// Dot diameter; derived from [size] when null
  final double? dotSize;

  /// Half-spacing between dots
  final double spacing;

  @override
  State<ClerkLoadingIndicator> createState() => _ClerkLoadingIndicatorState();
}

class _ClerkLoadingIndicatorState extends State<ClerkLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _color(BuildContext context) {
    final theme = Theme.of(context);
    final clerk = theme.extension<ClerkThemeExtension>();
    if (clerk != null) {
      return clerk.colors.link;
    }
    return theme.colorScheme.primary;
  }

  double _dotScale(int index, double t) {
    final phase = t * 2 * math.pi + index * (2 * math.pi / 3);
    return 0.35 + 0.65 * (math.sin(phase) + 1) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final dotDiameter = widget.dotSize ?? widget.size * 0.28;
    final color = _color(context);

    return Semantics(
      label: 'Loading',
      child: SizedBox(
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final scale = _dotScale(i, t);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: dotDiameter,
                      height: dotDiameter,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
