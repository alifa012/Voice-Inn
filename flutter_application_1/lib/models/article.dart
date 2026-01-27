class Article {
  final String id;
  final String title;
  final String summary;
  final String description;
  final String content;
  final String category;
  final DateTime publishedAt;
  final String? imageUrl;
  final String? urlToImage;  // For NewsAPI compatibility
  final String? source;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.content,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    this.urlToImage,
    this.source,
  });

  // Constructor for NewsAPI data
  factory Article.fromNewsApi(Map<String, dynamic> json, {String? sourceName}) {
    return Article(
      id: json['url'] ?? '',
      title: json['title'] ?? '',
      summary: json['description'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      category: sourceName?.toUpperCase() ?? json['source']?['name'] ?? 'News',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['urlToImage'],
      urlToImage: json['urlToImage'],
      source: sourceName ?? json['source']?['name'],
    );
  }

  // Constructor for GNews API data
  factory Article.fromGNews(Map<String, dynamic> json, {String? source}) {
    return Article(
      id: json['url'] ?? '',
      title: json['title'] ?? '',
      summary: json['description'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      category: source?.toUpperCase() ?? 'GNews',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['image'],
      urlToImage: json['image'],
      source: source ?? 'GNews',
    );
  }

  // Constructor for NewsData API data
  factory Article.fromNewsData(Map<String, dynamic> json, {String? source}) {
    return Article(
      id: json['link'] ?? json['article_id'] ?? '',
      title: json['title'] ?? '',
      summary: json['description'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      category: source?.toUpperCase() ?? 'NewsData',
      publishedAt: DateTime.tryParse(json['pubDate'] ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'],
      urlToImage: json['image_url'],
      source: source ?? 'NewsData',
    );
  }

  // Constructor for MediaStack API data
  factory Article.fromMediaStack(Map<String, dynamic> json, {String? source}) {
    return Article(
      id: json['url'] ?? '',
      title: json['title'] ?? '',
      summary: json['description'] ?? '',
      description: json['description'] ?? '',
      content: json['description'] ?? '',
      category: source?.toUpperCase() ?? 'MediaStack',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      imageUrl: json['image'],
      urlToImage: json['image'],
      source: source ?? 'MediaStack',
    );
  }

  // Constructor for RSS feed data
  factory Article.fromRSS(dynamic rssItem, {String? source}) {
    return Article(
      id: rssItem.link ?? '',
      title: rssItem.title ?? '',
      summary: rssItem.description ?? '',
      description: rssItem.description ?? '',
      content: rssItem.description ?? '',
      category: source?.toUpperCase() ?? 'RSS',
      publishedAt: rssItem.pubDate ?? DateTime.now(),
      imageUrl: null,
      urlToImage: null,
      source: source ?? 'RSS',
    );
  }

  // Constructor for generic JSON data
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'News',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'],
      urlToImage: json['urlToImage'],
      source: json['source'],
    );
  }

  String get publishedAtLabel {
    // For now, simple date string.
    return '${publishedAt.year}-${_two(publishedAt.month)}-${_two(publishedAt.day)}';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'description': description,
      'content': content,
      'category': category,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'urlToImage': urlToImage,
      'source': source,
    };
  }

  static List<Article> get sampleArticles => [
        Article(
          id: '1',
          title: 'Kenya launches new digital ID system',
          summary:
              'The government has rolled out a new digital identification system aimed at easing access to public services.',
          description:
              'The government has rolled out a new digital identification system aimed at easing access to public services.',
          content:
              'The Kenyan government has officially launched a new digital ID system, aiming to modernize access to public services across the country. Citizens will be able to use the digital ID to access healthcare, education, and financial services. Officials say the system is designed with security and privacy in mind, though critics have raised concerns about data protection and inclusion.',
          category: 'Politics',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          imageUrl:
              'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
          urlToImage:
              'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
          source: 'Voice-INN',
        ),
        Article(
          id: '2',
          title: 'Nairobi tech startups attract record funding',
          summary:
              'Investors continue to bet on African innovation with Nairobi leading funding rounds in fintech and healthtech.',
          description:
              'Investors continue to bet on African innovation with Nairobi leading funding rounds in fintech and healthtech.',
          content:
              'Tech startups in Nairobi have attracted record levels of funding in the past quarter, particularly in fintech and healthtech sectors. Analysts say the growth is driven by strong mobile penetration, a young population, and increasing investor confidence in African markets.',
          category: 'Business',
          publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
          imageUrl:
              'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg',
          urlToImage:
              'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg',
          source: 'Voice-INN',
        ),
        Article(
          id: '3',
          title: 'Harambee Stars prepare for crucial AFCON qualifier',
          summary:
              'The national football team is in camp as they gear up for a must-win match this weekend.',
          description:
              'The national football team is in camp as they gear up for a must-win match this weekend.',
          content:
              'Harambee Stars have intensified training ahead of a crucial AFCON qualifier match. The coaching staff say the team is focused and motivated, while fans are hopeful for a strong performance.',
          category: 'Sports',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          imageUrl:
              'https://images.pexels.com/photos/399187/pexels-photo-399187.jpeg',
          urlToImage:
              'https://images.pexels.com/photos/399187/pexels-photo-399187.jpeg',
          source: 'Voice-INN',
        ),
      ];
}