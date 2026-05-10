// lib/screens/main_shell.dart
//
// Bottom-nav shell. Hosts the four primary tabs and the global XP /
// achievement toast overlays. Toasts watch the AppState ValueNotifiers so
// they appear regardless of which tab the user is on.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'path_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _pages = [
    HomeScreen(),
    PathScreen(),
    ReviewScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _idx, children: _pages),
          // Global XP toast.
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(child: _XpToast()),
          ),
          // Global achievement toast.
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(child: _AchievementToast()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Path',
          ),
          NavigationDestination(
            icon: Icon(Icons.replay_outlined),
            selectedIcon: Icon(Icons.replay_rounded),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _XpToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ValueListenableBuilder<int?>(
      valueListenable: app.xpJustGained,
      builder: (context, xp, _) {
        if (xp == null) return const SizedBox.shrink();
        // Auto-clear after 1.6s so it doesn't stay forever.
        Future.delayed(const Duration(milliseconds: 1600), app.clearXpToast);
        final scheme = Theme.of(context).colorScheme;
        final palette = AppPalette.fromScheme(scheme);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: palette.streak,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: palette.streak.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white),
              const SizedBox(width: 6),
              Text('+$xp XP',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        )
            .animate(key: ValueKey(xp))
            .moveY(begin: -12, end: 0, curve: Curves.easeOutBack)
            .fadeIn(duration: 220.ms);
      },
    );
  }
}

class _AchievementToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ValueListenableBuilder<String?>(
      valueListenable: app.achievementJustEarned,
      builder: (context, name, _) {
        if (name == null) return const SizedBox.shrink();
        Future.delayed(const Duration(seconds: 3), app.clearAchievementToast);
        final scheme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radLarge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: scheme.onTertiaryContainer),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achievement unlocked',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                )),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(name))
            .moveY(begin: -12, end: 0, curve: Curves.easeOutBack)
            .fadeIn(duration: 240.ms);
      },
    );
  }
}
