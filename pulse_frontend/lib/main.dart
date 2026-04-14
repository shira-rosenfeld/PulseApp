import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/manager_workspace.dart';
import 'ui/worker_workspace.dart';
import 'core/app_strings.dart';
import 'providers/pulse_providers.dart';

// Calls window._pulseRemoveLoader() defined in index.html.
// dart:js_interop is the modern, non-deprecated JS interop API (Dart 3.x).
@JS('_pulseRemoveLoader')
external void _pulseRemoveLoader();

void main() {
  // Remove the HTML loading indicator now that Flutter's engine is ready.
  // The div is visible during engine init; this call removes it so Flutter's
  // rendered output is no longer covered.
  _pulseRemoveLoader();
  runApp(const ProviderScope(child: PulseApp()));
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('he', 'IL')],
      locale: const Locale('he', 'IL'),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Segoe UI',
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);
    return workspace == 'MANAGER'
        ? const ManagerWorkspace()
        : const WorkerWorkspace();
  }
}
