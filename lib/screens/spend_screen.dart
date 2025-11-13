import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import '../providers/app_state.dart';
import '../services/llm_service.dart';
import '../services/card_service.dart';
import '../models/credit_card.dart';
import 'settings_screen.dart';
import 'card_screen.dart'; // Import CardScreen

class SpendScreen extends StatefulWidget {
  const SpendScreen({super.key});

  @override
  State<SpendScreen> createState() => _SpendScreenState();
}

class _SpendScreenState extends State<SpendScreen> {
  final TextEditingController _purchaseInfoController = TextEditingController();
  String _bestCardMatch = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final llmService = Provider.of<LlmService>(context);
    final cardService = Provider.of<CardService>(context);
    final localizations = AppLocalizations.of(context)!;

    final bool isModelDownloaded = appState.isModelDownloaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.spendScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card), // Card icon
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CardScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isModelDownloaded) ...[
                Text(localizations.modelNotDownloaded),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                  child: Text(localizations.goToSettingsButton),
                ),
              ] else ...[
                TextField(
                  controller: _purchaseInfoController,
                  decoration: InputDecoration(labelText: localizations.purchaseInfoHint),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final purchaseInfo = _purchaseInfoController.text;
                    if (purchaseInfo.isNotEmpty) {
                      final List<CreditCard> userCards = await cardService.getCardsForUser().first;
                      final List<Map<String, String>> cardInfo = userCards
                          .map((card) => {'name': card.name, 'url': card.url})
                          .toList();
                      final result = await llmService.getBestCardMatch(cardInfo, purchaseInfo);
                      setState(() {
                        _bestCardMatch = result;
                      });
                    }
                  },
                  child: Text(localizations.getMatchButton),
                ),
                const SizedBox(height: 20),
                if (_bestCardMatch.isNotEmpty)
                  Text(
                    'Best Card: $_bestCardMatch',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
