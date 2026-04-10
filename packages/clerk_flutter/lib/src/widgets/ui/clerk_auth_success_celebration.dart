import 'dart:async';

import 'package:clerk_flutter/src/widgets/ui/style/clerk_theme.dart';
import 'package:flutter/material.dart';

/// Post sign-in / sign-up success animation ([show] pushes a modal route).
class ClerkAuthSuccessCelebration extends StatefulWidget {
  /// Construct a new [ClerkAuthSuccessCelebration]
  const ClerkAuthSuccessCelebration({
    super.key,
    this.iconSize = 88,
    this.onEntranceComplete,
  });

  /// Badge diameter
  final double iconSize;

  /// Called when the entrance animation completes
  final VoidCallback? onEntranceComplete;

  /// Modal celebration; awaits until the route is popped
  static Future<void> show(
    BuildContext context, {
    Duration holdDuration = const Duration(milliseconds: 900),
    Duration exitDuration = const Duration(milliseconds: 320),
  }) {
    const entranceMs = 700;
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.38),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, __) {
          return _CelebrationAutoClose(
            entranceHoldMs: entranceMs,
            holdDuration: holdDuration,
            exitDuration: exitDuration,
            child: const ClerkAuthSuccessCelebration(),
          );
        },
        transitionsBuilder: (ctx, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<ClerkAuthSuccessCelebration> createState() =>
      _ClerkAuthSuccessCelebrationState();
}

class _ClerkAuthSuccessCelebrationState extends State<ClerkAuthSuccessCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) {
        widget.onEntranceComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _accent(BuildContext context) {
    final clerk = Theme.of(context).extension<ClerkThemeExtension>();
    if (clerk != null) {
      return clerk.colors.link;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Semantics(
          label: 'Signed in successfully',
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    width: widget.iconSize,
                    height: widget.iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.22),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: widget.iconSize * 0.55,
                      color: accent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CelebrationAutoClose extends StatefulWidget {
  const _CelebrationAutoClose({
    required this.child,
    required this.entranceHoldMs,
    required this.holdDuration,
    required this.exitDuration,
  });

  final Widget child;
  final int entranceHoldMs;
  final Duration holdDuration;
  final Duration exitDuration;

  @override
  State<_CelebrationAutoClose> createState() => _CelebrationAutoCloseState();
}

class _CelebrationAutoCloseState extends State<_CelebrationAutoClose>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exit;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(
      vsync: this,
      duration: widget.exitDuration,
    );
    final wait = Duration(
      milliseconds:
          widget.entranceHoldMs + widget.holdDuration.inMilliseconds,
    );
    _timer = Timer(wait, () {
      if (!mounted) return;
      _exit.forward().then((_) {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _exit, curve: Curves.easeIn),
        ),
        child: widget.child,
      ),
    );
  }
}
