import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// App settings: theme, sound, reset progress, export/import progress JSON.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final progress = context.watch<ProgressProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.darkMode,
                  onChanged: settings.setDarkMode,
                  title: const Text('Dark mode'),
                  subtitle:
                      const Text('Easier on the eyes for evening study.'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: settings.soundOn,
                  onChanged: settings.setSoundOn,
                  title: const Text('Sound effects'),
                  subtitle: const Text('Tap and feedback sounds.'),
                  secondary: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_rounded),
                  title: const Text('Export progress'),
                  subtitle:
                      const Text('Copy your progress JSON to the clipboard.'),
                  trailing: const Icon(Icons.copy_rounded),
                  onTap: () => _exportProgress(context, progress),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Import progress'),
                  subtitle:
                      const Text('Paste a JSON snapshot you saved earlier.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _importProgress(context, progress),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded,
                      color: AppColors.error),
                  title: const Text('Reset all progress',
                      style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Clears XP, streak, and lessons.'),
                  onTap: () => _confirmReset(context, progress),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: const Text('Course source'),
                  subtitle: Text(
                    context
                            .read<ProgressProvider>()
                            .progress
                            .lastActiveDate ==
                        null
                        ? 'Stewart, Clegg, Watson — Calculus 9e'
                        : 'Stewart, Clegg, Watson — Calculus 9e',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About'),
                  subtitle: const Text(
                      'Calculus Quest v1.0 — A Duolingo-style calculus tutor.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportProgress(
      BuildContext context, ProgressProvider progress) async {
    final s = progress.exportJson();
    await Clipboard.setData(ClipboardData(text: s));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress JSON copied to clipboard.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importProgress(
      BuildContext context, ProgressProvider progress) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import progress'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Paste exported JSON here…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    try {
      await progress.importJson(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress imported successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmReset(
      BuildContext context, ProgressProvider progress) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset everything?'),
        content: const Text(
          'This will permanently erase your XP, streak, and lesson history. There is no undo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await progress.resetAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress has been reset.')),
        );
      }
    }
  }
}
