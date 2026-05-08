import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Briefly displays a "+N XP" pill at the top centre of the screen.
///
/// Drive by changing the [xp] value: each new non-null value triggers an
/// animated entry/exit. Set to null to clear immediately.
class XpGainOverlay extends StatefulWidget {
  final int? xp;
  final VoidCallback onDone;
  const XpGainOverlay({super.key, required this.xp, required this.onDone});

  @override
  State<XpGainOverlay> createState() => _XpGainOverlayState();
}

class _XpGainOverlayState extends State<XpGainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  int? _shown;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _ac.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onDone();
        if (mounted) setState(() => _shown = null);
      }
    });
    _maybeStart();
  }

  @override
  void didUpdateWidget(covariant XpGainOverlay old) {
    super.didUpdateWidget(old);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.xp != null && widget.xp != _shown) {
      _shown = widget.xp;
      _ac
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shown == null) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _ac,
          builder: (_, __) {
            // Slide down + fade in for the first 30%, hold, then fade out.
            final t = _ac.value;
            final fade = t < 0.3
                ? t / 0.3
                : t > 0.8
                    ? 1 - ((t - 0.8) / 0.2)
                    : 1.0;
            final dy = (1 - fade) * -20;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Opacity(
                opacity: fade.clamp(0, 1).toDouble(),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '+$_shown XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
