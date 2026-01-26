// lib/models/article.dart

class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String url;
  final String? imageUrl;     // optional image field
  final String? source;       // optional source name
  final String? publishedAt;  // optional published date

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.url,
    this.imageUrl,
    this.source,
    this.publishedAt,
  });

  /// Factory constructor to create an Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],       // safe: may be null
      source: json['source'],
      publishedAt: json['publishedAt'],
    );
  }

  /// Convert Article back to JSON (useful for saving or debugging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt,
    };
  }

  @override
  String toString() {
    return 'Article(id: $id, title: $title, source: $source, publishedAt: $publishedAt)';
  }
}
