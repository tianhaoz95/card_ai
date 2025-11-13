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
  String _thinkContent = ''; // New state variable for think content
  bool _isLoading = false; // Added loading state

  // Helper to extract content between <think> tags
  String _extractThinkContent(String text) {
    final RegExp regExp = RegExp(r'<think>(.*?)</think>', dotAll: true);
    final Match? match = regExp.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }

  // Helper to remove <think> tags and their content, and also "<|im_end|>"
  String _removeThinkContent(String text) {
    final RegExp thinkRegExp = RegExp(r'<think>.*?</think>', dotAll: true);
    String cleanedText = text.replaceAll(thinkRegExp, '').trim();
    cleanedText = cleanedText.replaceAll('<|im_end|>', '').trim();
    return cleanedText;
  }

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
                _isLoading
                    ? const CircularProgressIndicator() // Show progress indicator when loading
                    : ElevatedButton(
                        onPressed: () async {
                          final purchaseInfo = _purchaseInfoController.text;
                          if (purchaseInfo.isNotEmpty) {
                            setState(() {
                              _isLoading = true; // Set loading to true
                              _bestCardMatch = ''; // Clear previous match
                              _thinkContent = ''; // Clear previous think content
                            });
                            try {
                              final List<CreditCard> userCards = await cardService.getCardsForUser().first;
                              final List<Map<String, String>> cardInfo = userCards
                                  .map((card) => {'name': card.name, 'url': card.url})
                                  .toList();
                              final rawResult = await llmService.getBestCardMatch(cardInfo, purchaseInfo);
                              setState(() {
                                _thinkContent = _extractThinkContent(rawResult);
                                _bestCardMatch = _removeThinkContent(rawResult);
                              });
                            } catch (e) {
                              // Handle error, e.g., show a SnackBar
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error getting card match: $e')),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false; // Set loading to false
                              });
                            }
                          }
                        },
                        child: Text(localizations.getMatchButton),
                      ),
                const SizedBox(height: 20),
                if (_bestCardMatch.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Best Card: $_bestCardMatch',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (_thinkContent.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () => _showThinkContentDialog(context, localizations, _thinkContent),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showThinkContentDialog(BuildContext context, AppLocalizations localizations, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.thinkingProcessTitle), // Assuming a localization key for "Thinking Process"
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.okButton), // Assuming a localization key for "OK"
            ),
          ],
        );
      },
    );
  }
}
