import 'package:flutter/material.dart';
import 'package:card_ai/models/app_user.dart';
import 'package:card_ai/services/auth_service.dart';
import 'package:card_ai/services/llm_service.dart';

class AppState extends ChangeNotifier {
  AppUser? _currentUser;
  Locale _currentLocale = const Locale('en'); // Default to English
  bool _isModelDownloaded = false;
  double _downloadProgress = 0.0;

  AppUser? get currentUser => _currentUser;
  Locale get currentLocale => _currentLocale;
  bool get isModelDownloaded => _isModelDownloaded;
  double get downloadProgress => _downloadProgress;

  final AuthService _authService;
  final LlmService _llmService;

  AppState(this._authService, this._llmService) {
    _authService.user.listen((appUser) {
      _currentUser = appUser;
      notifyListeners();
    });

    _llmService.downloadProgress.listen((progress) {
      _downloadProgress = progress;
      if (progress == 1.0) {
        _isModelDownloaded = true;
      } else {
        _isModelDownloaded = false;
      }
      notifyListeners();
    });

    _isModelDownloaded = _llmService.isModelDownloaded;
    _downloadProgress = _isModelDownloaded ? 1.0 : 0.0;
  }

  void setCurrentUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  Future<void> downloadLlmModel() async {
    await _llmService.downloadModel();
  }
}
