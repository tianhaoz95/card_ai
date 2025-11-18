import 'dart:async'; // Import for StreamController
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import 'llm_service.dart';
import '../models/llm_response_chunk.dart'; // Import LlmResponseChunk

class CactusLlmService implements LlmService {
  final CactusLM _cactusLM = CactusLM();

  final BehaviorSubject<double> _downloadProgress =
      BehaviorSubject<double>.seeded(0.0);

  bool _isModelDownloaded = false;

  static const String _isModelDownloadedKey =
      'isModelDownloaded'; // Key for shared_preferences

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
  Stream<LlmResponseChunk> getBestCardMatch(
    List<Map<String, String>> cardInfo,
    String purchaseInfo,
    bool isThinkingMode,
  ) async* {
    // Changed to async* to return a Stream
    if (!_isModelDownloaded) {
      throw Exception('LLM Model not downloaded.');
    }

    final cardDetails = cardInfo
        .map(
          (card) =>
              "CARD: Name: ${card['name']}, Rewards: [Placeholder for specific reward rules from ${card['url']}]",
        )
        .join('\n');

    String instructionStart =
        "INSTRUCTION START\nYou are a Credit Card Cashback Optimizer. Your goal is to analyze the provided Credit Card List and the Current Purchase details. You must recommend the single credit card that offers the absolute highest cashback percentage for the stated purchase category. Provide only the recommendation and the rate. Do not use external knowledge.";
    String instructionEnd = "INSTRUCTION END";

    String promptPrefix = isThinkingMode ? "/think " : "/no_think ";

    final prompt =
        """$instructionStart
$instructionEnd

CREDIT CARD LIST
$cardDetails

CURRENT PURCHASE
PURCHASE CATEGORY: $purchaseInfo
DESCRIPTION: $purchaseInfo

TASK

Determine the highest applicable cashback rate among the listed cards for the PURCHASE CATEGORY.

Format the output exactly as requested below.

OUTPUT FORMAT
RECOMMENDED CARD: [Name of the recommended card]
HIGHEST CASHBACK RATE: [X%]
APPLICABLE REWARD RULE: [The specific reward rule that gives the highest rate] $promptPrefix""";

    try {
      final streamedResult = await _cactusLM.generateCompletionStream(
        messages: [ChatMessage(content: prompt, role: "user")],
        params: CactusCompletionParams(maxTokens: 8 * 1024),
      );

      int currentTokenCount = 0;
      await for (final chunk in streamedResult.stream) {
        currentTokenCount += chunk.length; // Estimate tokens by character count
        yield LlmResponseChunk(text: chunk, tokenCount: currentTokenCount);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting card match from LLM: $e');
      }
      // Re-throw the error to be handled by the caller
      throw Exception('Error getting card match: $e');
    }
  }
}
