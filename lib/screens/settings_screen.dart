import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: Text(localizations.languageSetting),
              trailing: DropdownButton<Locale>(
                value: appState.currentLocale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    appState.setLocale(newLocale);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('zh'),
                    child: Text('中文'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(localizations.downloadModelButton),
            LinearProgressIndicator(
              value: appState.downloadProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Text('${(appState.downloadProgress * 100).toStringAsFixed(0)}%'),
            ElevatedButton(
              onPressed: appState.isModelDownloaded
                  ? null // Disable button if model is already downloaded
                  : () async {
                      await appState.downloadLlmModel();
                    },
              child: Text(localizations.downloadModelButton),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: Text(localizations.signOutButton),
            ),
            ElevatedButton(
              onPressed: () async {
                // TODO: Implement confirmation dialog for account deletion
                await authService.deleteAccount();
              },
              child: Text(localizations.deleteAccountButton),
            ),
          ],
        ),
      ),
    );
  }
}
