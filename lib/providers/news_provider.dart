import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/fake_news_detector_service.dart';

class NewsProvider with ChangeNotifier {
  final FakeNewsDetectorService _detectorService = FakeNewsDetectorService();
  
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;
  String? _apiKey;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  void setApiKey(String key) {
    _apiKey = key;
    _detectorService.setApiKey(key);
    notifyListeners();
  }

  Future<void> analyzeNews(String title, String content, {String? url, String? imageUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final article = NewsArticle(
        title: title,
        content: content,
        url: url,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      final result = await _detectorService.analyzeNews(title, content, url: url, imageUrl: imageUrl);
      
      final verifiedArticle = article.copyWith(verificationResult: result);
      _articles.insert(0, verifiedArticle);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearArticles() {
    _articles.clear();
    notifyListeners();
  }

  void clearHistory() {
    _articles.clear();
    notifyListeners();
  }

  void removeArticle(int index) {
    _articles.removeAt(index);
    notifyListeners();
  }
}
