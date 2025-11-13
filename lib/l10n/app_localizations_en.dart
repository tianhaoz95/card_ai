// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Card AI';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get cardScreenTitle => 'My Cards';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get spendScreenTitle => 'Spend';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get cardNameHint => 'Card Name';

  @override
  String get cardUrlHint => 'Card Info URL';

  @override
  String get saveButton => 'Save';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get languageSetting => 'Language';

  @override
  String get downloadModelButton => 'Download LLM Model';

  @override
  String get purchaseInfoHint =>
      'Enter purchase details (e.g., \'coffee at Starbucks\')';

  @override
  String get getMatchButton => 'Get Best Card Match';

  @override
  String get modelNotDownloaded =>
      'LLM Model not downloaded. Please go to Settings to download.';

  @override
  String get goToSettingsButton => 'Go to Settings';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get noCardsMessage => 'No cards added yet. Add your first card!';

  @override
  String get thinkingProcessTitle => 'Thinking Process';

  @override
  String get okButton => 'OK';
}
