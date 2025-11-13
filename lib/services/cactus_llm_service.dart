import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'llm_service.dart';

class CactusLlmService implements LlmService {

  final CactusLM _cactusLM = CactusLM();

  final BehaviorSubject<double> _downloadProgress = BehaviorSubject<double>.seeded(0.0);

  bool _isModelDownloaded = false;



  CactusLlmService() {

    _isModelDownloaded = false; // Initialize to false, will be set to true after successful download

    _downloadProgress.add(0.0);

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

              print("$status ${progress != null ? '(${progress * 100}%)' : ''}");

            }

          }

        },

      );



      // After successful download, initialize the model

      await _cactusLM.initializeModel(); // Assuming initializeModel is needed after download



      _isModelDownloaded = true;

      _downloadProgress.add(1.0);

    } catch (e) {

      if (kDebugMode) {

        print('Error downloading model: $e');

      }

      _downloadProgress.add(0.0); // Reset on error

    }

  }



  @override

  Future<String> getBestCardMatch(List<Map<String, String>> cardInfo, String purchaseInfo) async {

    if (!_isModelDownloaded) {

      throw Exception('LLM Model not downloaded.');

    }



    String prompt = "Given the following credit card information and a purchase, recommend the best credit card.\n\n";

    prompt += "Purchase: $purchaseInfo\n\n";

    prompt += "Available Credit Cards:\n";

    for (var card in cardInfo) {

      prompt += "- Name: ${card['name']}, Info: ${card['url']}\n";

    }

    prompt += "\nBased on the purchase and card information, which credit card offers the best reward or benefit? Just output the card name.";



    try {

      final result = await _cactusLM.generateCompletion(

        messages: [

          ChatMessage(content: prompt, role: "user"),

        ],

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


