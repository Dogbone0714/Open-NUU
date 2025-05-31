import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../models/news_item.dart';

class NewsService {
  static const String baseUrl = 'https://www.nuu.edu.tw';
  static const String newsPath = '/p/406-1000-77,r6.php';  // 更新為新的新聞頁面路徑
  static const int pageSize = 5;
  static const int maxRetries = 3;  // 最大重試次數

  Future<http.Response> _getWithRetry(Uri uri, {int retryCount = 0}) async {
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml',
          'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(
        const Duration(seconds: 10),  // 設置超時時間
        onTimeout: () {
          throw TimeoutException('請求超時');
        },
      );

      return response;
    } catch (e) {
      if (retryCount < maxRetries) {
        print('重試第 ${retryCount + 1} 次...');
        await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));  // 指數退避
        return _getWithRetry(uri, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<List<NewsItem>> fetchLatestNews({int page = 1}) async {
    try {
      final uri = Uri.parse('$baseUrl$newsPath?page=$page');
      print('正在獲取新聞，URL: $uri');

      final response = await _getWithRetry(uri);

      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final document = parse(body);
        
        // 更新選擇器以匹配新的頁面結構
        final newsElements = document.querySelectorAll('.list-wrapper .h5');
        final dateElements = document.querySelectorAll('.list-wrapper .date');

        if (newsElements.isEmpty) {
          print('找不到新聞元素');
          return [];
        }

        List<NewsItem> news = [];

        for (var i = 0; i < newsElements.length && news.length < pageSize; i++) {
          try {
            final titleElement = newsElements[i];
            final dateElement = dateElements[i];
            final linkElement = titleElement.parent;

            final title = titleElement.text.trim();
            final date = dateElement.text.trim();
            final href = linkElement?.attributes['href'];
            
            if (href == null || href.isEmpty) {
              print('新聞連結為空: $title');
              continue;
            }

            final link = href.startsWith('http') ? href : baseUrl + href;

            if (title.isNotEmpty && date.isNotEmpty) {
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
          } catch (e) {
            print('處理新聞項目時發生錯誤: $e');
            continue;
          }
        }

        if (news.isEmpty) {
          print('沒有找到有效的新聞');
        } else {
          print('成功獲取 ${news.length} 則新聞');
        }

        return news;
      } else {
        print('HTTP 錯誤: ${response.statusCode}');
        print('回應內容: ${response.body}');
        throw Exception('無法獲取新聞列表 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('獲取新聞時發生錯誤: $e');
      throw Exception('無法獲取新聞列表: $e');
    }
  }

  Future<int> getTotalPages() async {
    try {
      final uri = Uri.parse('$baseUrl$newsPath');
      final response = await _getWithRetry(uri);

      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final document = parse(body);
        
        // 更新選擇器以匹配新的頁面結構
        final newsElements = document.querySelectorAll('.list-wrapper .h5');
        final totalPages = (newsElements.length / pageSize).ceil();
        print('總頁數: $totalPages');
        return totalPages > 0 ? totalPages : 1;
      } else {
        print('獲取總頁數時發生HTTP錯誤: ${response.statusCode}');
        return 1;
      }
    } catch (e) {
      print('獲取總頁數時發生錯誤: $e');
      return 1;
    }
  }
} 