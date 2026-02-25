import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/manager_workspace.dart';
import 'ui/worker_workspace.dart';
// import 'ui/task_modals.dart'; // Import this if you want to preview ModalsShowcase()
import 'core/app_strings.dart';

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

class PulseApp extends StatefulWidget {
  const PulseApp({super.key});

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  late final Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _fetchUserRole();
  }

  Future<String> _fetchUserRole() async {
    // API Call to backend
    await Future.delayed(const Duration(seconds: 2));
    return 'Worker'; // Switched to 'Worker' to load the new screen
  }

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
      home: FutureBuilder<String>(
        future: _roleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: const AssetImage('assets/pulse_loading.gif'), width: 150, height: 150),
                    const SizedBox(height: 16),
                    const Text('טוען סביבת עבודה...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data == 'Manager') {
            return const ManagerWorkspace();
          } else {
            return const WorkerWorkspace();
          }
        },
      ),
    );
  }
}