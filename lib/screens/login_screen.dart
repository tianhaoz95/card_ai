import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../providers/app_state.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.loginButton),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: localizations.emailHint),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: localizations.passwordHint),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: Text(localizations.loginButton),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Sign Up screen
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
              },
              child: Text(localizations.signupButton),
            ),
          ],
        ),
      ),
    );
  }
}
