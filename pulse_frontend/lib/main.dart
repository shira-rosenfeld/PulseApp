import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/manager_workspace.dart';
import 'ui/worker_workspace.dart';
// import 'ui/task_modals.dart'; // Import this if you want to preview ModalsShowcase()
import 'core/app_strings.dart';

void main() {
  runApp(const ProviderScope(child: PulseApp()));
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

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
        future: _fetchUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: const AssetImage('assets/pulse_loading.gif'), width: 120, height: 120),
                    const SizedBox(height: 16),
                    const Text('Pulse', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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