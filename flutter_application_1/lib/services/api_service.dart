import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/article.dart';

class ApiService {
  Future<List<Article>> fetchArticles() async {
    try {
      final String response =
          await rootBundle.loadString('assets/sample_articles.json');
      print('Loaded JSON: $response');

      final dynamic data = json.decode(response);

      if (data is List) {
        // JSON is a list of articles
        return data.map((json) => Article.fromJson(json)).toList();
      } else if (data is Map<String, dynamic>) {
        // JSON is a single article object
        return [Article.fromJson(data)];
      } else {
        print('Unexpected JSON format');
        return [];
      }
    } catch (e) {
      print('Error loading articles: $e');
      return [];
    }
  }
}
