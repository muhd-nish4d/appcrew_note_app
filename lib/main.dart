import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/app_routes.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/network_provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError caught: ${details.exception}');
      // Here you would integrate Crashlytics: FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error caught: $error');
      // Here you would integrate Crashlytics: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }

    final prefs = await SharedPreferences.getInstance();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => NetworkProvider()),
          ChangeNotifierProvider(create: (_) => LogInAuthProvider()),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
        ],
        child: const NotesApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('runZonedGuarded error caught: $error');
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
