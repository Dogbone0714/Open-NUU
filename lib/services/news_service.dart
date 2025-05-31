import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/news_item.dart';

// 条件导入
import 'dart:io' if (dart.library.html) 'dart:html' as platform;

class NewsService {
  static const String baseUrl = 'http://localhost:5000';
  static const String newsEndpoint = '/api/news';
  static const String healthEndpoint = '/api/health';
  static const int pageSize = 5;
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 15);
  static const Duration retryDelay = Duration(seconds: 2);

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
      if (kIsWeb) {
        // Web 平台不需要启动本地服务器
        print('Web 平台不支持本地服務器啟動');
        return;
      }

      // 获取应用目录
      String serverPath;
      
      // 原生平台
      if (!kIsWeb) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          serverPath = '${directory.path}/server.py';
        } catch (e) {
          print('獲取應用文檔目錄失敗: $e');
          try {
            final directory = await getTemporaryDirectory();
            serverPath = '${directory.path}/server.py';
          } catch (e) {
            print('獲取臨時目錄失敗: $e');
            // 如果都失败了，使用当前目录
            serverPath = 'server.py';
          }
        }
        
        // 复制服务器脚本到目标目录
        if (!kIsWeb) {
          final serverFile = File(serverPath);
          if (!await serverFile.exists()) {
            final originalFile = File('server.py');
            if (await originalFile.exists()) {
              await originalFile.copy(serverPath);
            } else {
              throw Exception('找不到服務器腳本文件');
            }
          }

          // 启动服务器
          await Process.start('python', [serverPath]);
        }
      }
      
      // 等待服务器启动
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
    int retryCount = 0;
    while (retryCount < maxRetries) {
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
        retryCount++;
        print('獲取新聞時發生錯誤 (嘗試 $retryCount/$maxRetries): $e');
        if (retryCount < maxRetries) {
          print('等待 ${retryDelay.inSeconds} 秒後重試...');
          await Future.delayed(retryDelay);
        } else {
          throw Exception('無法獲取新聞列表: $e');
        }
      }
    }
    throw Exception('無法獲取新聞列表: 超過最大重試次數');
  }

  Future<int> getTotalPages() async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
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
        retryCount++;
        print('獲取總頁數時發生錯誤 (嘗試 $retryCount/$maxRetries): $e');
        if (retryCount < maxRetries) {
          print('等待 ${retryDelay.inSeconds} 秒後重試...');
          await Future.delayed(retryDelay);
        } else {
          return 1;
        }
      }
    }
    return 1;
  }
} 