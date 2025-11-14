import '../models/llm_response_chunk.dart';

abstract class LlmService {
  Stream<LlmResponseChunk> getBestCardMatch(List<Map<String, String>> cardInfo, String purchaseInfo, bool isThinkingMode);
  Stream<double> get downloadProgress;
  Future<void> downloadModel();
  bool get isModelDownloaded;
}
