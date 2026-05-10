// lib/main.dart
//
// Entry point. We:
//   1. Create the AppState (loads progress from storage in initState).
//   2. Wrap MaterialApp.router in DynamicColorBuilder so we can offer
//      Android-12+ wallpaper-derived dynamic colour.
//   3. Pick the active ColorScheme based on settings: dynamic when toggled,
//      else the named theme preset.
//   4. Build a Material 3 Expressive ThemeData via AppTheme.build().

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalculusQuestApp());
}

class CalculusQuestApp extends StatelessWidget {
  const CalculusQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.isReady) {
      // Splash while shared_prefs loads.
      return const _Splash();
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final preset = app.activeTheme;
        final brightness =
            app.progress.darkMode ? Brightness.dark : Brightness.light;

        ColorScheme scheme;
        if (app.progress.useDynamicColor &&
            (brightness == Brightness.light
                ? lightDynamic
                : darkDynamic) !=
                null) {
          scheme = brightness == Brightness.light
              ? lightDynamic!.harmonized()
              : darkDynamic!.harmonized();
        } else {
          scheme = ColorScheme.fromSeed(
            seedColor: preset.seedColor,
            brightness: brightness,
            dynamicSchemeVariant: preset.variant,
          );
        }

        return MaterialApp.router(
          title: 'Calculus Quest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(scheme),
          routerConfig: appRouter,
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077B6)),
      ),
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
