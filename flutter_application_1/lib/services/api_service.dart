import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  // NewsAPI key
  static const String _apiKey = 'b5cde51c0dc64a00b6b65bfcb310c0b6';
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // Stream controller for real-time updates
  final StreamController<List<Article>> _articlesController = 
      StreamController<List<Article>>.broadcast();
  
  Timer? _updateTimer;
  
  // Stream for real-time article updates
  Stream<List<Article>> get articlesStream => _articlesController.stream;
  
  // News sources configuration
  static const Map<String, String> _newsSources = {
    'bbc': 'bbc-news',
    'cnn': 'cnn',
    'ntv': 'the-star', // Kenyan news source available on NewsAPI
    'ktn': 'the-star', // Using available Kenyan source
  };
  
  // Countries for different sources
  static const Map<String, String> _sourceCountries = {
    'bbc': 'gb',
    'cnn': 'us', 
    'ntv': 'ke',
    'ktn': 'ke',
  };

  void dispose() {
    _updateTimer?.cancel();
    _articlesController.close();
  }

  // Start real-time news updates
  void startRealTimeUpdates({Duration interval = const Duration(minutes: 5)}) {
    _updateTimer?.cancel();
    
    // Initial fetch
    fetchAllSourcesNews();
    
    // Set up periodic updates
    _updateTimer = Timer.periodic(interval, (timer) {
      fetchAllSourcesNews();
    });
  }
  
  // Stop real-time updates
  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
  }
  
  // Fetch news from all configured sources
  Future<void> fetchAllSourcesNews() async {
    final List<Article> allArticles = [];
    
    // Fetch from each source
    for (final sourceEntry in _newsSources.entries) {
      final sourceName = sourceEntry.key;
      final sourceId = sourceEntry.value;
      final country = _sourceCountries[sourceName] ?? 'us';
      
      try {
        final articles = await _fetchFromSource(
          sourceName: sourceName,
          sourceId: sourceId, 
          country: country,
        );
        allArticles.addAll(articles);
      } catch (e) {
        print('Error fetching from $sourceName: $e');
      }
    }
    
    // Sort by publish time (most recent first)
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
    // Add to stream
    if (!_articlesController.isClosed) {
      _articlesController.add(allArticles);
    }
    
    print('Real-time update: Fetched ${allArticles.length} articles from ${_newsSources.length} sources');
  }
  // Fetch news from a specific source
  Future<List<Article>> _fetchFromSource({
    required String sourceName,
    required String sourceId,
    required String country,
  }) async {
    try {
      // Try source-specific endpoint first
      Uri url = Uri.parse('$_baseUrl/top-headlines?sources=$sourceId&apiKey=$_apiKey');
      
      print('Fetching from $sourceName: $url');
      
      http.Response response = await http.get(url);
      
      // If source-specific fails, try country-based
      if (response.statusCode != 200) {
        url = Uri.parse('$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey');
        response = await http.get(url);
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .where((article) => 
                article['title'] != null && 
                article['title'] != '[Removed]' &&
                article['description'] != null
            )
            .map((json) => Article.fromNewsApi(json, sourceName: sourceName))
            .toList();
        
        print('✓ $sourceName: ${articles.length} articles fetched');
        return articles;
      } else {
        print('✗ $sourceName API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('✗ $sourceName fetch error: $e');
      return [];
    }
  }
  // Fallback method for compatibility
  Future<List<Article>> fetchArticles() async {
    await fetchAllSourcesNews();
    // Return sample articles if stream is empty
    return Article.sampleArticles;
  }
  
  // Get latest articles from stream (for non-stream usage)
  Future<List<Article>> getLatestArticles() async {
    try {
      await fetchAllSourcesNews();
      return await articlesStream.first.timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error getting latest articles: $e');
      return Article.sampleArticles;
    }
  }

  // Optional: Fetch by category
  Future<List<Article>> fetchArticlesByCategory(String category) async {
    try {
      final url = Uri.parse('$_baseUrl/top-headlines?category=${category.toLowerCase()}&apiKey=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .where((article) => article['title'] != '[Removed]')
            .map((json) => Article.fromNewsApi(json))
            .toList();

        return articles;
      } else {
        return Article.sampleArticles;
      }
    } catch (e) {
      print('Error fetching category articles: $e');
      return Article.sampleArticles;
    }
  }

  // Optional: Search news by keyword
  Future<List<Article>> searchArticles(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/everything?q=$query&sortBy=publishedAt&apiKey=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .where((article) => article['title'] != '[Removed]')
            .map((json) => Article.fromNewsApi(json))
            .toList();

        return articles;
      } else {
        return Article.sampleArticles;
      }
    } catch (e) {
      print('Error searching articles: $e');
      return Article.sampleArticles;
    }
  }
}