import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_ai/l10n/app_localizations.dart';

import '../services/card_service.dart';
import '../models/credit_card.dart';
import 'settings_screen.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  void _showAddEditCardDialog(BuildContext context, AppLocalizations localizations, CardService cardService, {CreditCard? card}) {
    final TextEditingController nameController = TextEditingController(text: card?.name ?? '');
    final TextEditingController urlController = TextEditingController(text: card?.url ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(card == null ? localizations.addCardButton : localizations.editButton),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: localizations.cardNameHint),
              ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: localizations.cardUrlHint),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancelButton), // Assuming a 'cancelButton' localization key
            ),
            ElevatedButton(
              onPressed: () async {
                if (card == null) {
                  await cardService.addCard(nameController.text, urlController.text);
                } else {
                  await cardService.updateCard(card.id, nameController.text, urlController.text);
                }
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(localizations.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardService = Provider.of<CardService>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.cardScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CreditCard>>(
        stream: cardService.getCardsForUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(localizations.noCardsMessage)); // Assuming a 'noCardsMessage' localization key
          }

          final cards = snapshot.data!;
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(card.name),
                  subtitle: Text(card.url),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditCardDialog(context, localizations, cardService, card: card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          // TODO: Implement confirmation dialog for deletion
                          await cardService.deleteCard(card.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCardDialog(context, localizations, cardService),
        child: const Icon(Icons.add),
      ),
    );
  }
}
