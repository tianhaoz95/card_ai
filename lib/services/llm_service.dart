abstract class LlmService {
  Future<String> getBestCardMatch(List<Map<String, String>> cardInfo, String purchaseInfo, bool isThinkingMode);
  Stream<double> get downloadProgress;
  Future<void> downloadModel();
  bool get isModelDownloaded;
}
