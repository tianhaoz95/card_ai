import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import 'llm_service.dart';

class CactusLlmService implements LlmService {
  final CactusLM _cactusLM = CactusLM();

  final BehaviorSubject<double> _downloadProgress =
      BehaviorSubject<double>.seeded(0.0);

  bool _isModelDownloaded = false;

  static const String _isModelDownloadedKey = 'isModelDownloaded'; // Key for shared_preferences

  CactusLlmService() {
    _initModelStatus(); // Initialize model status asynchronously
  }

  Future<void> _initModelStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isModelDownloaded = prefs.getBool(_isModelDownloadedKey) ?? false;
    if (_isModelDownloaded) {
      _downloadProgress.add(1.0); // If already downloaded, set progress to 1.0
    } else {
      _downloadProgress.add(0.0); // If not downloaded, set progress to 0.0
    }
  }

  @override
  Stream<double> get downloadProgress => _downloadProgress.stream;

  @override
  bool get isModelDownloaded => _isModelDownloaded;

  @override
  Future<void> downloadModel() async {
    if (_isModelDownloaded) {
      _downloadProgress.add(1.0);
      return;
    }

    _downloadProgress.add(0.0);

    try {
      await _cactusLM.downloadModel(
        model: "qwen3-0.6", // Using a default model as per example

        downloadProcessCallback: (progress, status, isError) {
          if (isError) {
            if (kDebugMode) {
              print("Download error: $status");
            }

            _downloadProgress.add(0.0);
          } else {
            if (progress != null) {
              _downloadProgress.add(progress);
            }

            if (kDebugMode) {
              print(
                "$status ${progress != null ? '(${progress * 100}%)' : ''}",
              );
            }
          }
        },
      );

      // After successful download, initialize the model

      await _cactusLM
          .initializeModel(); // Assuming initializeModel is needed after download

      _isModelDownloaded = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isModelDownloadedKey, true); // Save status

      _downloadProgress.add(1.0);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model: $e');
      }

      _downloadProgress.add(0.0); // Reset on error
    }
  }

  @override
  Future<String> getBestCardMatch(
    List<Map<String, String>> cardInfo,
    String purchaseInfo,
  ) async {
    if (!_isModelDownloaded) {
      throw Exception('LLM Model not downloaded.');
    }

    String prompt =
        "Given the following credit card information and a purchase, recommend the best credit card with the highest cash back reward that fits the purchase's category.\n\n";

    prompt += "Purchase: $purchaseInfo\n\n";

    prompt += "Available Credit Cards:\n";

    for (var card in cardInfo) {
      prompt += "- Name: ${card['name']}, Info: ${card['url']}\n";
    }

    prompt +=
        "\nBased on the purchase and card information, which credit card offers the best reward or benefit? Just output the card name and the expected cash back reward rate in this format";

    try {
      final result = await _cactusLM.generateCompletion(
        messages: [ChatMessage(content: prompt, role: "user")],
        params: CactusCompletionParams(maxTokens: 1024),
      );

      if (result.success) {
        return result.response ?? 'No response from LLM.';
      } else {
        return 'LLM completion failed: Unknown error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting card match from LLM: $e');
      }

      return 'Error getting card match.';
    }
  }
}
