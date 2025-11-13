import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.signupButton),
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
                await authService.signUpWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                Navigator.of(context).pop(); // Go back to login screen
              },
              child: Text(localizations.signupButton),
            ),
          ],
        ),
      ),
    );
  }
}
