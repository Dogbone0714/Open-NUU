import 'package:flutter/foundation.dart';
import '../models/news_item.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<NewsItem> _news = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = true;

  List<NewsItem> get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  Future<void> refreshNews() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    try {
      final totalPages = await _newsService.getTotalPages();
      _totalPages = totalPages;
      
      final fetchedNews = await _newsService.fetchLatestNews(page: _currentPage);
      _news = fetchedNews;
      _hasMorePages = _currentPage < _totalPages;
      _error = null;
    } catch (e) {
      _error = '無法更新新聞：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNews() async {
    if (_isLoading || !_hasMorePages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final fetchedNews = await _newsService.fetchLatestNews(page: nextPage);
      
      if (fetchedNews.isNotEmpty) {
        _news.addAll(fetchedNews);
        _currentPage = nextPage;
        _hasMorePages = _currentPage < _totalPages;
      } else {
        _hasMorePages = false;
      }
    } catch (e) {
      _error = '無法載入更多新聞：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 自動更新新聞（每30分鐘）
  void startAutoRefresh() {
    Future.delayed(const Duration(minutes: 30), () {
      refreshNews();
      startAutoRefresh();
    });
  }
} 