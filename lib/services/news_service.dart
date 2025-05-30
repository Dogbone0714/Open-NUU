import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../models/news_item.dart';

class NewsService {
  static const String baseUrl = 'https://www.nuu.edu.tw';
  static const String newsPath = '/p/422-1000-1076.php?Lang=zh-tw';
  static const int pageSize = 5;

  Future<List<NewsItem>> fetchLatestNews({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$newsPath&Page=$page'));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final newsElements = document.querySelectorAll('.mtitle a');
        final dateElements = document.querySelectorAll('.mdate');

        List<NewsItem> news = [];
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;

        for (var i = startIndex; i < newsElements.length && i < endIndex && i < dateElements.length; i++) {
          final title = newsElements[i].text.trim();
          final date = dateElements[i].text.trim();
          final link = baseUrl + (newsElements[i].attributes['href'] ?? '');

          news.add(NewsItem(
            category: '聯大新聞',
            title: title,
            date: date,
            description: title,
            content: '新聞內容載入中...\n\n'
                '詳細內容請點擊連結查看',
            link: link,
          ));
        }
        return news;
      }
    } catch (e) {
      print('Error fetching news: $e');
      rethrow;
    }
    return [];
  }

  // 獲取總頁數
  Future<int> getTotalPages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + newsPath));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final newsElements = document.querySelectorAll('.mtitle a');
        return (newsElements.length / pageSize).ceil();
      }
    } catch (e) {
      print('Error getting total pages: $e');
    }
    return 1;
  }
} 