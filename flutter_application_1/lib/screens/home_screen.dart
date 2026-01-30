import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../models/filter_selection.dart';
import '../models/news_location.dart';
import '../services/api_service.dart';
import '../services/multi_source_news_service.dart';
import '../widgets/news_filter_bottom_sheet.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final MultiSourceNewsService _multiSourceService = MultiSourceNewsService();
  List<Article> _articles = [];
  List<Article> _allArticles = []; // Store all articles before filtering
  final List<Article> _filteredArticles = []; // Store filtered articles
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdate;
  late Stream<List<Article>> _articlesStream;
  FilterSelection _currentFilter = const FilterSelection();

  @override
  void initState() {
    super.initState();
    _articlesStream = _multiSourceService.articlesStream;
    _loadNews(); // Start with direct load
    _startRealTimeUpdates();
  }
  
  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      print('🔄 Loading news articles...');
      final articles = await _multiSourceService.fetchFromAllSources(filter: _currentFilter);
      print('✅ Loaded ${articles.length} articles');
      
      if (mounted) {
        setState(() {
          _allArticles = articles;
          _applyCurrentFilters();
          _isLoading = false;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      print('❌ Error loading news: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load news: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  void _startRealTimeUpdates() {
    // Start real-time updates every 3 minutes with current filter
    _multiSourceService.startRealTimeUpdates(
      interval: const Duration(minutes: 3),
      filter: _currentFilter,
    );
    
    // Listen to the stream
    _articlesStream.listen(
      (articles) {
        if (mounted) {
          setState(() {
            _allArticles = articles;
            _applyCurrentFilters();
            _isLoading = false;
            _lastUpdate = DateTime.now();
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  // Check if news is recent (within last 30 minutes)
  bool _isRecentNews(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    return difference.inMinutes <= 30;
  }
  
  // Get source-specific colors
  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'bbc':
        return Colors.red.shade800;
      case 'cnn':
        return Colors.blue.shade800;
      case 'ntv':
        return Colors.green.shade700;
      case 'ktn':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
  
  // Get display name for sources
  String _getSourceDisplayName(String source) {
    switch (source.toLowerCase()) {
      case 'bbc':
        return 'BBC';
      case 'cnn':
        return 'CNN';
      case 'ntv':
        return 'NTV';
      case 'ktn':
        return 'KTN';
      default:
        return source.toUpperCase();
    }
  }

  String _buildStatusText() {
    if (_currentFilter.hasActiveFilters) {
      return 'Filtered results • ${_articles.length} of ${_allArticles.length} articles • ${_currentFilter.activeFilterCount} filters active';
    } else {
      return 'Live updates active • ${_articles.length} articles from multiple sources';
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _multiSourceService.fetchFromAllSources(filter: _currentFilter);
      setState(() {
        _allArticles = articles;
        _applyCurrentFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _apiService.stopRealTimeUpdates();
    _apiService.dispose();
    _multiSourceService.dispose();
    super.dispose();
  }

  void _showFilterSheet() async {
    final result = await NewsFilterBottomSheet.show(
      context,
      initialSelection: _currentFilter,
    );
    
    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    // Update the multi-source service with new filter
    _multiSourceService.updateFilter(_currentFilter);
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentFilter.hasActiveFilters 
          ? 'Filters applied • Fetching from ${_currentFilter.selectedSources.isNotEmpty ? _currentFilter.selectedSources.length : "selected"} sources'
          : 'Filters cleared • Fetching from all sources'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _applyCurrentFilters() {
    // Since we're now filtering at the API level, we just use all received articles
    // The filtering happens in the service when fetching from selected sources
    _articles = List.from(_allArticles);
  }

  // Helper method to get country from article source
  Country? _getArticleCountry(Article article) {
    final source = article.source?.toLowerCase() ?? '';
    
    // Map article sources to countries
    if (source.contains('kenya') || source.contains('nation') || 
        source.contains('standard') || source.contains('tuko') ||
        source.contains('citizen') || source.contains('ktn') || 
        source.contains('ntv') || source.contains('capital')) {
      return WorldNews.countriesByContinent[Continent.africa]?.firstWhere(
        (country) => country.code == 'ke',
        orElse: () => const Country(code: 'ke', name: 'Kenya', continent: Continent.africa, mainCities: ['Nairobi'], flagEmoji: '🇰🇪'),
      );
    }
    
    if (source.contains('bbc') && source.contains('africa')) {
      return null; // BBC Africa covers multiple countries
    }
    
    if (source.contains('bbc') || source.contains('uk')) {
      return WorldNews.countriesByContinent[Continent.europe]?.firstWhere(
        (country) => country.code == 'gb',
        orElse: () => const Country(code: 'gb', name: 'United Kingdom', continent: Continent.europe, mainCities: ['London'], flagEmoji: '🇬🇧'),
      );
    }
    
    if (source.contains('cnn') || source.contains('usa') || source.contains('us')) {
      return WorldNews.countriesByContinent[Continent.northAmerica]?.firstWhere(
        (country) => country.code == 'us',
        orElse: () => const Country(code: 'us', name: 'United States', continent: Continent.northAmerica, mainCities: ['New York'], flagEmoji: '🇺🇸'),
      );
    }
    
    return null;
  }

  // Helper method to get news source from article
  NewsSource? _getArticleNewsSource(Article article) {
    final source = article.source?.toLowerCase() ?? '';
    
    // Find matching news source from WorldNews
    for (final continent in WorldNews.sourcesByContinent.keys) {
      for (final newsSource in WorldNews.sourcesByContinent[continent] ?? []) {
        if (source.contains(newsSource.name.toLowerCase()) ||
            newsSource.name.toLowerCase().contains(source) ||
            newsSource.id.toLowerCase().contains(source)) {
          return newsSource;
        }
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice-INN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_lastUpdate != null)
              Text(
                'Live • Updated ${_getTimeAgo(_lastUpdate!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
                tooltip: 'Filter News',
              ),
              if (_currentFilter.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentFilter.activeFilterCount}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Refresh button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _multiSourceService.updateFilter(_currentFilter);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_currentFilter.hasActiveFilters 
                        ? 'Refreshing news from selected sources...'
                        : 'Refreshing news from all sources...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Refresh News',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Column(
      children: [
        // Real-time status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isLoading 
                ? Colors.orange.shade50 
                : Colors.green.shade50,
            border: Border(
              bottom: BorderSide(
                color: _isLoading 
                    ? Colors.orange.shade200 
                    : Colors.green.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isLoading 
                      ? 'Fetching latest news from multiple sources...'
                      : _buildStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isLoading 
                        ? Colors.orange.shade700 
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_lastUpdate != null && !_isLoading)
                Text(
                  'Updated ${_getTimeAgo(_lastUpdate!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade600,
                  ),
                ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: _buildMainContent(theme),
        ),
      ],
    );
  }
  
  Widget _buildMainContent(ThemeData theme) {
    if (_isLoading && _articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load news',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadArticles,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(
        child: Text('No articles available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return _ArticleCard(
            article: article,
            onTap: () async {
              // Try to open article link directly
              try {
                final url = article.id;
                if (url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return;
                  }
                }
              } catch (e) {
                print('Error opening article link: $e');
              }
              
              // Fallback: open detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor,
                theme.cardColor.withOpacity(0.95),
              ],
            ),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  article.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category, Source and time with real-time indicators
                  Row(
                    children: [
                      // Source badge with live indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSourceColor(article.source ?? 'Unknown'),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _isRecentNews(article.publishedAt) 
                                    ? Colors.red 
                                    : Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getSourceDisplayName(article.source ?? 'Unknown'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Real-time delivery indicator
                      Row(
                        children: [
                          if (_isRecentNews(article.publishedAt))
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: _isRecentNews(article.publishedAt)
                                ? Colors.red
                                : theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(article.publishedAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _isRecentNews(article.publishedAt)
                                  ? Colors.red
                                  : theme.hintColor,
                              fontWeight: _isRecentNews(article.publishedAt)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    article.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Summary/Description with click hint
                  if (article.summary.isNotEmpty)
                    Text(
                      article.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  
                  // Click to read indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to read full article',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for article card
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  // Check if news is recent (within last 30 minutes)
  bool _isRecentNews(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    return difference.inMinutes <= 30;
  }
  
  // Get source-specific colors
  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'bbc':
        return Colors.red.shade800;
      case 'cnn':
        return Colors.blue.shade800;
      case 'ntv':
        return Colors.green.shade700;
      case 'ktn':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
  
  // Get display name for sources
  String _getSourceDisplayName(String source) {
    switch (source.toLowerCase()) {
      case 'bbc':
        return 'BBC';
      case 'cnn':
        return 'CNN';
      case 'ntv':
        return 'NTV';
      case 'ktn':
        return 'KTN';
      default:
        return source.toUpperCase();
    }
  }
}