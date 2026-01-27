class VideoArticle {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelName;
  final DateTime publishedAt;
  final int? viewCount;
  final String? duration;
  final String? channelId;

  VideoArticle({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelName,
    required this.publishedAt,
    this.viewCount,
    this.duration,
    this.channelId,
  });

  // Constructor for YouTube API data
  factory VideoArticle.fromYouTubeApi(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'];
    
    return VideoArticle(
      videoId: json['id']?['videoId'] ?? json['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? 
                   snippet['thumbnails']?['default']?['url'] ?? '',
      channelName: snippet['channelTitle'] ?? '',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
      viewCount: statistics != null ? int.tryParse(statistics['viewCount'] ?? '0') : null,
      channelId: snippet['channelId'],
    );
  }

  // Get time ago string
  String get publishedAtLabel {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  // Format view count
  String get formattedViewCount {
    if (viewCount == null) return '';
    
    if (viewCount! < 1000) {
      return '$viewCount views';
    } else if (viewCount! < 1000000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    } else {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    }
  }

  // Sample video articles for testing
  static List<VideoArticle> get sampleVideos => [
    VideoArticle(
      videoId: 'dQw4w9WgXcQ',
      title: 'Breaking: Kenya Launches Digital Identity System',
      description: 'Government officials announce the rollout of a comprehensive digital ID system aimed at modernizing public services and improving accessibility for all citizens.',
      thumbnailUrl: 'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
      channelName: 'NTV Kenya',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      viewCount: 15432,
      duration: '3:45',
    ),
    VideoArticle(
      videoId: 'M7lc1UVf-VE',
      title: 'Tech Startups Boom in Nairobi',
      description: 'Exploring the growing technology sector in Nairobi with interviews from successful entrepreneurs and investors shaping the future of African innovation.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg',
      channelName: 'KTN News',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      viewCount: 8765,
      duration: '5:20',
    ),
    VideoArticle(
      videoId: 'jNQXAC9IVRw',
      title: 'Global Economic Update',
      description: 'Analysis of current global economic trends and their impact on developing markets, featuring expert commentary from leading economists.',
      thumbnailUrl: 'https://images.pexels.com/photos/3831645/pexels-photo-3831645.jpeg',
      channelName: 'BBC News',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      viewCount: 234567,
      duration: '8:15',
    ),
  ];
}