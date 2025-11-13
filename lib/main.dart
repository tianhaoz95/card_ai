import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/card_service.dart';
import 'services/llm_service.dart';
import 'services/cactus_llm_service.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/spend_screen.dart'; // Import SpendScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<CardService>(
          create: (_) => CardService(),
        ),
        Provider<LlmService>(
          create: (_) => CactusLlmService(),
        ),
        ChangeNotifierProvider<AppState>(
          create: (context) => AppState(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<LlmService>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Card AI',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('zh', ''), // Chinese
          ],
          locale: appState.currentLocale,
          home: appState.currentUser == null ? const LoginScreen() : const SpendScreen(), // Changed to SpendScreen
        );
      },
    );
  }
}
