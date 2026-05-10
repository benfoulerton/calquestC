// lib/screens/settings_screen.dart
//
// User-facing controls. The theme picker is the centrepiece — large
// preview tiles let the user feel the difference before committing.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SectionHeader(title: 'Appearance'),
          // Dynamic color toggle.
          _ToggleRow(
            icon: Icons.palette_outlined,
            title: 'Use device colour',
            subtitle: 'Match my Android wallpaper',
            value: app.progress.useDynamicColor,
            onChanged: app.setUseDynamicColor,
          ),
          _ToggleRow(
            icon: Icons.dark_mode_rounded,
            title: 'Dark mode',
            subtitle: 'Easier on the eyes at night',
            value: app.progress.darkMode,
            onChanged: app.setDarkMode,
          ),
          const SizedBox(height: 12),
          // Theme picker (only when dynamic colour is OFF).
          if (!app.progress.useDynamicColor) ...[
            Text('Theme',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: [
                for (final p in ThemePresets.all)
                  _ThemeTile(
                    preset: p,
                    selected: app.progress.activeThemeId == p.id,
                    onTap: () => app.setActiveTheme(p.id),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(title: 'Comfort'),
          _ToggleRow(
            icon: Icons.motion_photos_pause_rounded,
            title: 'Reduce motion',
            subtitle: 'Less animation',
            value: app.progress.reduceMotion,
            onChanged: app.setReduceMotion,
          ),
          _ToggleRow(
            icon: Icons.volume_up_rounded,
            title: 'Sound',
            subtitle: 'Audio cues on tap',
            value: app.progress.soundOn,
            onChanged: app.setSoundOn,
          ),
          _ToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            subtitle: 'Subtle vibration on tap',
            value: app.progress.hapticsOn,
            onChanged: app.setHapticsOn,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Goals'),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_rounded, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('Daily goal',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in [5, 10, 15, 20])
                      ChoiceChip(
                        label: Text('$m min'),
                        selected: app.progress.dailyGoalMinutes == m,
                        onSelected: (_) => app.setDailyGoal(m),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Account'),
          _LinkRow(
            icon: Icons.refresh_rounded,
            title: 'Reset all progress',
            destructive: true,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset everything?'),
                  content: const Text(
                      'This wipes all XP, streaks, and lesson progress. Cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          Navigator.of(context).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await app.resetAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress reset.')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Calculus Quest · v2.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : scheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radMedium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppTheme.radMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                      )),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });
  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seed = preset.seedColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: seed.withOpacity(selected ? 1.0 : 0.85),
          borderRadius: BorderRadius.circular(AppTheme.radLarge),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: seed.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(preset.icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(preset.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
