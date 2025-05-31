import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/news_item.dart';

class NewsService {
  static const String baseUrl = 'http://localhost:5000';
  static const String newsEndpoint = '/api/news';
  static const String healthEndpoint = '/api/health';
  static const int pageSize = 5;
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 15);

  Future<bool> _checkServer() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$healthEndpoint'),
      ).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      print('服務器檢查失敗: $e');
      return false;
    }
  }

  Future<void> _startServer() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final serverPath = '${directory.path}/server.py';
      
      // 複製服務器腳本到應用目錄
      final serverFile = File(serverPath);
      if (!await serverFile.exists()) {
        final originalFile = File('server.py');
        if (await originalFile.exists()) {
          await originalFile.copy(serverPath);
        }
      }

      // 啟動服務器
      Process.start('python', [serverPath], mode: ProcessStartMode.detached);
      
      // 等待服務器啟動
      int retries = 0;
      while (retries < 10) {
        if (await _checkServer()) {
          print('服務器已成功啟動');
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
        retries++;
      }
      throw Exception('服務器啟動超時');
    } catch (e) {
      print('啟動服務器時發生錯誤: $e');
      rethrow;
    }
  }

  Future<List<NewsItem>> fetchLatestNews({int page = 1}) async {
    try {
      // 檢查服務器是否運行，如果沒有則啟動
      if (!await _checkServer()) {
        print('服務器未運行，正在啟動...');
        await _startServer();
      }

      print('正在從 Python API 獲取新聞...');
      final response = await http.get(
        Uri.parse('$baseUrl$newsEndpoint'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final news = data.map((item) => NewsItem(
          category: item['category'] ?? '聯大新聞',
          title: item['title'] ?? '',
          date: item['date'] ?? '',
          description: item['description'] ?? '',
          content: item['content'] ?? '',
          link: item['link'] ?? '',
        )).toList();

        print('成功獲取 ${news.length} 則新聞');
        return news;
      } else {
        print('API 錯誤: ${response.statusCode}');
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
      if (!await _checkServer()) {
        print('服務器未運行，正在啟動...');
        await _startServer();
      }

      final response = await http.get(
        Uri.parse('$baseUrl$newsEndpoint'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final totalPages = (data.length / pageSize).ceil();
        return totalPages > 0 ? totalPages : 1;
      }
      return 1;
    } catch (e) {
      print('獲取總頁數時發生錯誤: $e');
      return 1;
    }
  }
} 