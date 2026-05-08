import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../widgets/achievement_toast.dart';
import '../widgets/xp_gain_overlay.dart';

/// Persistent bottom-nav shell. Hosts the four primary tabs and overlays
/// global +XP / achievement toasts above any of them.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _routes = ['/', '/path', '/stats', '/settings'];

  int _indexFor(String location) {
    if (location.startsWith('/path')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // Touch the streak when the user opens the app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().touchActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _indexFor(loc);
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          // Global toasts.
          ValueListenableBuilder<int?>(
            valueListenable: progress.xpJustGained,
            builder: (_, value, __) => XpGainOverlay(
              xp: value,
              onDone: progress.clearXpToast,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: progress.newlyEarned,
            builder: (_, value, __) => AchievementToast(
              achievement: value,
              onDone: progress.clearAchievementToast,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => context.go(_routes[i]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_rounded),
            label: 'Path',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
