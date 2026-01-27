import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/article.dart';
import '../models/news_location.dart';
import '../models/filter_selection.dart';

class MultiSourceNewsService {
  // =============================================================================
  // API KEYS (Replace with your own API keys)
  // =============================================================================
  static const String NEWSAPI_API_KEY = 'b5cde51c0dc64a00b6b65bfcb310c0b6';
  static const String GNEWS_API_KEY = '8b0f196a220f95e2d33a00929b864d0a';
  static const String NEWSDATA_API_KEY = 'pub_2c2b7f5af28a4d8cbeee5ce45ec523cc';
  static const String MEDIASTACK_API_KEY = '35de1dee70cb6417a65eb2a15207dd09';

  // =============================================================================
  // CACHE MANAGEMENT
  // =============================================================================
  final Map<String, CachedResult> _cache = {};
  static const Duration cacheExpiry = Duration(minutes: 3);

  // =============================================================================
  // STREAM CONTROLLERS
  // =============================================================================
  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>.broadcast();
  Timer? _updateTimer;
  FilterSelection? _currentFilter;

  Stream<List<Article>> get articlesStream => _articlesController.stream;

  void dispose() {
    _updateTimer?.cancel();
    _articlesController.close();
  }

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Fetch news articles by continent
  Future<List<Article>> fetchByContinent(Continent continent) async {
    final cacheKey = 'continent_${continent.name}';
    
    // Check cache first
    if (_isCacheValid(cacheKey)) {
      print('📦 Returning cached results for $continent');
      return _cache[cacheKey]!.articles;
    }

    try {
      print('🌍 Fetching news for continent: ${continent.displayName}');
      final List<Article> allArticles = [];

      // Get continent-specific sources
      final sources = WorldNews.getSourcesForContinent(continent);
      
      for (final source in sources) {
        try {
          final articles = await fetchBySource(source);
          allArticles.addAll(articles);
        } catch (e) {
          print('❌ Error fetching from ${source.name}: $e');
        }
      }

      // Deduplicate articles
      final deduplicated = _deduplicateArticles(allArticles);
      
      // Cache results
      _cache[cacheKey] = CachedResult(deduplicated, DateTime.now());
      
      print('✅ Fetched ${deduplicated.length} articles for ${continent.displayName}');
      return deduplicated;

    } catch (e) {
      print('❌ Error fetching continent news: $e');
      return _getCachedOrEmpty(cacheKey);
    }
  }

  /// Fetch news articles by country
  Future<List<Article>> fetchByCountry(String countryCode) async {
    final cacheKey = 'country_$countryCode';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.articles;
    }

    try {
      print('🏳️ Fetching news for country: $countryCode');
      final List<Article> allArticles = [];

      // Get country-specific sources
      final sources = WorldNews.getSourcesForCountry(countryCode);
      
      for (final source in sources) {
        final articles = await fetchBySource(source);
        allArticles.addAll(articles);
      }

      // Also try NewsAPI country endpoint
      final newsApiArticles = await _fetchNewsApiByCountry(countryCode);
      allArticles.addAll(newsApiArticles);

      // Deduplicate
      final deduplicated = _deduplicateArticles(allArticles);
      
      _cache[cacheKey] = CachedResult(deduplicated, DateTime.now());
      
      return deduplicated;

    } catch (e) {
      print('❌ Error fetching country news: $e');
      return _getCachedOrEmpty(cacheKey);
    }
  }

  /// Fetch news articles from a specific source
  Future<List<Article>> fetchBySource(NewsSource source) async {
    final cacheKey = 'source_${source.id}';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.articles;
    }

    try {
      List<Article> articles = [];

      switch (source.apiType) {
        case 'newsapi':
          articles = await _fetchNewsApi(source);
          break;
        case 'gnews':
          articles = await _fetchGNews(source);
          break;
        case 'newsdata':
          articles = await _fetchNewsData(source);
          break;
        case 'mediastack':
          articles = await _fetchMediaStack(source);
          break;
        case 'rss':
          articles = await _fetchRSS(source);
          break;
        default:
          print('⚠️ Unknown API type: ${source.apiType}');
      }

      _cache[cacheKey] = CachedResult(articles, DateTime.now());
      return articles;

    } catch (e) {
      print('❌ Error fetching from ${source.name}: $e');
      return _getCachedOrEmpty(cacheKey);
    }
  }

  /// Fetch news from all available sources
  Future<List<Article>> fetchFromAllSources({FilterSelection? filter}) async {
    final cacheKey = filter?.hasActiveFilters == true ? 'filtered_${filter.hashCode}' : 'all_sources';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.articles;
    }

    try {
      print('🌐 Fetching news from ${filter?.hasActiveFilters == true ? "selected" : "all"} sources...');
      final List<Article> allArticles = [];

      // Determine which sources to fetch from based on filters
      final sourcesToFetch = _getSourcesFromFilter(filter);
      
      print('📡 Fetching from ${sourcesToFetch.length} sources');
      
      // Fetch from selected sources
      for (final source in sourcesToFetch) {
        print('🔍 Calling ${source.name} (${source.apiType})...');
        final articles = await fetchBySource(source);
        allArticles.addAll(articles);
        print('✅ Got ${articles.length} articles from ${source.name}');
      }

      // Deduplicate all articles
      final deduplicated = _deduplicateArticles(allArticles);
      
      // Sort by publish time (most recent first)
      deduplicated.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      _cache[cacheKey] = CachedResult(deduplicated, DateTime.now());
      
      // Add to stream
      if (!_articlesController.isClosed) {
        _articlesController.add(deduplicated);
      }

      print('✅ Total articles after deduplication: ${deduplicated.length}');
      return deduplicated;

    } catch (e) {
      print('❌ Error fetching all sources: $e');
      return _getCachedOrEmpty(cacheKey);
    }
  }

  /// Start real-time updates
  void startRealTimeUpdates({
    Duration interval = const Duration(minutes: 5), 
    FilterSelection? filter
  }) {
    _updateTimer?.cancel();
    _currentFilter = filter;
    
    // Initial fetch
    fetchFromAllSources(filter: filter);
    
    // Set up periodic updates
    _updateTimer = Timer.periodic(interval, (timer) {
      fetchFromAllSources(filter: _currentFilter);
    });
  }

  /// Update the current filter and refresh data
  void updateFilter(FilterSelection? filter) {
    _currentFilter = filter;
    fetchFromAllSources(filter: filter);
  }

  /// Stop real-time updates
  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
  }

  // =============================================================================
  // PRIVATE API METHODS
  // =============================================================================

  /// Fetch from NewsAPI.org
  Future<List<Article>> _fetchNewsApi(NewsSource source) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?'
      'sources=${source.id}&'
      'apiKey=$NEWSAPI_API_KEY'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['articles'] != null) {
        return (data['articles'] as List)
            .where((item) => item != null)
            .map((json) {
              try {
                return Article.fromNewsApi(json, sourceName: source.name);
              } catch (e) {
                print('❌ Error parsing NewsAPI article: $e');
                return null;
              }
            })
            .where((article) => article != null)
            .cast<Article>()
            .toList();
      }
    } else if (response.statusCode == 429) {
      print('⚠️ NewsAPI rate limit exceeded for ${source.name}, trying backup...');
      // Return empty list and let other APIs handle the load
      return [];
    } else {
      print('❌ NewsAPI error ${response.statusCode} for ${source.name}');
    }
    
    return [];
  }

  /// Fetch from NewsAPI by country
  Future<List<Article>> _fetchNewsApiByCountry(String countryCode) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?'
      'country=$countryCode&'
      'pageSize=20&'
      'apiKey=$NEWSAPI_API_KEY'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['articles'] != null) {
        return (data['articles'] as List)
            .where((item) => item != null)
            .map((json) {
              try {
                return Article.fromNewsApi(json, sourceName: 'NewsAPI');
              } catch (e) {
                return null;
              }
            })
            .where((article) => article != null)
            .cast<Article>()
            .toList();
      }
    }
    
    return [];
  }

  /// Fetch from GNews API
  Future<List<Article>> _fetchGNews(NewsSource source) async {
    String query = 'news';
    if (source.countryCode != null) {
      final country = WorldNews.getCountryByCode(source.countryCode!);
      if (country != null) {
        query = country.name;
      }
    }

    final url = Uri.parse(
      'https://gnews.io/api/v4/top-headlines?'
      'q=$query&'
      'lang=en&'
      'max=10&'
      'apikey=$GNEWS_API_KEY'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['articles'] != null) {
        return (data['articles'] as List)
            .where((item) => item != null)
            .map((json) {
              try {
                return Article.fromGNews(json, source: source.name);
              } catch (e) {
                print('❌ Error parsing GNews article: $e');
                return null;
              }
            })
            .where((article) => article != null)
            .cast<Article>()
            .toList();
      }
    }
    
    return [];
  }

  /// Fetch from NewsData.io
  Future<List<Article>> _fetchNewsData(NewsSource source) async {
    String country = '';
    if (source.countryCode != null) {
      country = '&country=${source.countryCode}';
    }

    final url = Uri.parse(
      'https://newsdata.io/api/1/news?'
      'apikey=$NEWSDATA_API_KEY&'
      'language=en$country&'
      'size=10'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return (data['results'] as List)
            .where((item) => item != null)
            .map((json) {
              try {
                return Article.fromNewsData(json, source: source.name);
              } catch (e) {
                print('❌ Error parsing NewsData article: $e');
                return null;
              }
            })
            .where((article) => article != null)
            .cast<Article>()
            .toList();
      }
    }
    
    return [];
  }

  /// Fetch from MediaStack
  Future<List<Article>> _fetchMediaStack(NewsSource source) async {
    String countries = '';
    if (source.countryCode != null) {
      countries = '&countries=${source.countryCode}';
    }

    final url = Uri.parse(
      'http://api.mediastack.com/v1/news?'
      'access_key=$MEDIASTACK_API_KEY&'
      'languages=en$countries&'
      'limit=10'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        return (data['data'] as List)
            .where((item) => item != null)
            .map((json) {
              try {
                return Article.fromMediaStack(json, source: source.name);
              } catch (e) {
                print('❌ Error parsing MediaStack article: $e');
                return null;
              }
            })
            .where((article) => article != null)
            .cast<Article>()
            .toList();
      }
    }
    
    return [];
  }

  /// Fetch from RSS feeds
  Future<List<Article>> _fetchRSS(NewsSource source) async {
    if (source.apiUrl == null || source.apiUrl!.isEmpty) {
      print('⚠️ No RSS URL provided for ${source.name}');
      return [];
    }

    // List of CORS proxy services to try
    final corsProxies = [
      'https://api.allorigins.win/get?url=',
      'https://cors-anywhere.herokuapp.com/',
      'https://api.codetabs.com/v1/proxy?quest=',
      'https://cors.bridged.cc/',
    ];

    try {
      // For web apps, always use CORS proxy (direct access will fail)
      for (int i = 0; i < corsProxies.length; i++) {
        try {
          String proxyUrl;
          
          if (corsProxies[i].contains('allorigins')) {
            proxyUrl = corsProxies[i] + Uri.encodeComponent(source.apiUrl!);
          } else {
            proxyUrl = corsProxies[i] + source.apiUrl!;
          }

          print('🔄 Trying CORS proxy ${i + 1} for ${source.name}...');
          final response = await http.get(Uri.parse(proxyUrl)).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: Proxy took too long to respond');
            },
          );
          
          if (response.statusCode == 200) {
            String xmlContent = response.body;
            
            // Handle allorigins.win response format
            if (corsProxies[i].contains('allorigins')) {
              final data = json.decode(response.body);
              xmlContent = data['contents'] ?? '';
            }
            
            if (xmlContent.isNotEmpty) {
              final feed = RssFeed.parse(xmlContent);
              
              final articles = feed.items?.map((item) {
                try {
                  return Article.fromRSS(item, source: source.name);
                } catch (e) {
                  print('❌ Error parsing RSS item: $e');
                  return null;
                }
              }).where((article) => article != null).cast<Article>().take(10).toList() ?? [];
              
              if (articles.isNotEmpty) {
                print('✅ RSS success via proxy ${i + 1} for ${source.name}');
                return articles;
              }
            }
          }
        } catch (proxyError) {
          print('⚠️ Proxy ${i + 1} failed for ${source.name}: $proxyError');
          continue; // Try next proxy
        }
      }
      
      // If all proxies fail, provide helpful error message
      print('❌ All CORS proxies failed for ${source.name}');
      
    } catch (e) {
      print('❌ RSS parsing error for ${source.name}: $e');
    }
    
    return [];
  }

  // =============================================================================
  // DEDUPLICATION & CACHING
  // =============================================================================

  /// Remove duplicate articles based on title similarity
  List<Article> _deduplicateArticles(List<Article> articles) {
    final List<Article> unique = [];
    
    for (final article in articles) {
      bool isDuplicate = false;
      
      for (final existing in unique) {
        final similarity = article.title.similarityTo(existing.title);
        if (similarity > 0.8) { // 80% similarity threshold
          isDuplicate = true;
          // Keep the article with better image or longer content
          if (_isArticleBetter(article, existing)) {
            final index = unique.indexOf(existing);
            unique[index] = article;
          }
          break;
        }
      }
      
      if (!isDuplicate) {
        unique.add(article);
      }
    }
    
    print('📊 Deduplication: ${articles.length} → ${unique.length} articles');
    return unique;
  }

  /// Determine if one article is better than another
  bool _isArticleBetter(Article article1, Article article2) {
    // Prefer articles with images
    if (article1.urlToImage?.isNotEmpty == true && article2.urlToImage?.isEmpty != false) {
      return true;
    }
    if (article2.urlToImage?.isNotEmpty == true && article1.urlToImage?.isEmpty != false) {
      return false;
    }
    
    // Prefer articles with longer content
    final content1Length = article1.content.length;
    final content2Length = article2.content.length;
    
    return content1Length > content2Length;
  }

  /// Check if cache is still valid
  bool _isCacheValid(String key) {
    final cached = _cache[key];
    if (cached == null) return false;
    
    final age = DateTime.now().difference(cached.timestamp);
    return age < cacheExpiry;
  }

  /// Get cached articles or empty list
  List<Article> _getCachedOrEmpty(String key) {
    final cached = _cache[key];
    return cached?.articles ?? [];
  }

  /// Determine which sources to fetch from based on filter
  List<NewsSource> _getSourcesFromFilter(FilterSelection? filter) {
    if (filter == null || !filter.hasActiveFilters) {
      // No filter - fetch from all sources
      final List<NewsSource> allSources = [];
      
      // Add all continental sources
      for (final continent in Continent.values) {
        allSources.addAll(WorldNews.getSourcesForContinent(continent));
      }
      
      // Add international sources
      allSources.addAll(WorldNews.internationalSources);
      
      return allSources;
    }

    // Filter is active - only fetch from selected sources
    if (filter.selectedSources.isNotEmpty) {
      // User selected specific sources
      return filter.selectedSources;
    }

    // User selected continent/countries but not specific sources
    final List<NewsSource> filteredSources = [];

    if (filter.selectedContinent != null) {
      if (filter.selectedCountries.isNotEmpty) {
        // User selected specific countries
        for (final country in filter.selectedCountries) {
          filteredSources.addAll(WorldNews.getSourcesForCountry(country.code));
        }
      } else {
        // User selected only continent
        filteredSources.addAll(WorldNews.getSourcesForContinent(filter.selectedContinent!));
      }
    }

    return filteredSources.isNotEmpty ? filteredSources : []; // Return empty if no sources match
  }

  /// Extract image URL from RSS item
  String? _extractImageFromRSS(dynamic rssItem) {
    // Try to get image from enclosure
    if (rssItem.enclosure?.url != null) {
      return rssItem.enclosure!.url;
    }
    
    // Try to extract from description HTML
    final description = rssItem.description ?? '';
    final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
    final match = imgRegex.firstMatch(description);
    
    return match?.group(1);
  }
}

// =============================================================================
// HELPER CLASSES
// =============================================================================

class CachedResult {
  final List<Article> articles;
  final DateTime timestamp;

  CachedResult(this.articles, this.timestamp);
}

// End of multi-source news service