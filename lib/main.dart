// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'views/splash_screen.dart';
import 'services/cart_service.dart';
import 'services/firebase_rest_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 App starting — initializing Firebase...');

  Object? initError;
  bool firebaseInitialized = false;

  try {
    // Try to initialize Firebase but don't let it block forever.
    // If it doesn't finish within 10 seconds we'll catch a TimeoutException.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Firebase.initializeApp() timed out after 10s');
      },
    );

    firebaseInitialized = true;
    print('✅ Firebase.initializeApp() completed');
  } catch (e, st) {
    initError = e;
    print('🔥 Firebase initialization error: $e');
    print(st);
  }

  try {
    // Initialize REST Auth only if we managed to initialize Firebase
    // (but if Firebase failed we still try to initialize REST Auth using config).
    final apiKey = DefaultFirebaseOptions.android.apiKey;
    if (apiKey.isEmpty || !apiKey.startsWith('AIza')) {
      print('⚠️ Android API key looks invalid: $apiKey');
    }
    FirebaseRestAuth.initialize(apiKey: apiKey);
    print(
        '✅ FirebaseRestAuth initialized with API key (from firebase_options)');
  } catch (e, st) {
    // Ensure we capture and log any initialization error, but we don't block the app.
    initError ??= e;
    print('🔥 FirebaseRestAuth initialization error: $e');
    print(st);
  }

  // Always run the app so the UI can show a descriptive error if initialization failed.
  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  final Object? initError;
  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartService(),
      child: MaterialApp(
        title: 'AquaPure Delivery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: initError == null
            ? const SplashScreen()
            : InitErrorScreen(error: initError),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class InitErrorScreen extends StatelessWidget {
  final Object? error;
  const InitErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final message = error?.toString() ?? 'Unknown initialization error';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialization Error'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'The app failed to initialize correctly.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Give user a way to retry — just restart the app state by reloading main.
                // In development you can instruct them to cold-restart from IDE.
                // Here we pop until first route which effectively restarts the app UI.
                try {
                  // Typically does nothing in initial route, but safe to call.
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
                } catch (_) {}
              },
              child: const Text('Retry (may require full app restart)'),
            ),
            const SizedBox(height: 12),
            const Text(
              'If this persists:\n1) Check Android logcat for the full error.\n2) Verify google-services.json and applicationId match.\n3) Ensure INTERNET permission is present in AndroidManifest.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
