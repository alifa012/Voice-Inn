import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_article.dart';

class YouTubeService {
  // YouTube Data API v3 key (you'll need to get your own)
  static const String _apiKey = 'AIzaSyC5Xs74gBX5rjpv93xA82Lvhy7o-utemyE'; // Replace with your key
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // News channel configuration
  static const Map<String, String> _newsChannels = {
    'BBC News': 'UC16niRr50-MSBwiO3YDb3RA',
    'CNN': 'UCupvZG-5ko_eiXAupbDfxWw',
    'NTV Kenya': 'UCu0-EB8l5gNjWEp9fPCCNzQ', 
    'KTN News Kenya': 'UCvNKpTI5OXu3HfE0Xdy4kPQ',
  };
  
  // Stream controller for real-time updates
  final StreamController<List<VideoArticle>> _videosController = 
      StreamController<List<VideoArticle>>.broadcast();
  
  Timer? _updateTimer;
  
  // Stream for real-time video updates
  Stream<List<VideoArticle>> get videosStream => _videosController.stream;

  void dispose() {
    _updateTimer?.cancel();
    _videosController.close();
  }

  // Start real-time video updates
  void startRealTimeUpdates({Duration interval = const Duration(minutes: 10)}) {
    _updateTimer?.cancel();
    
    // Initial fetch
    fetchAllChannelVideos();
    
    // Set up periodic updates
    _updateTimer = Timer.periodic(interval, (timer) {
      fetchAllChannelVideos();
    });
  }
  
  // Stop real-time updates
  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
  }

  // Fetch videos from all news channels
  Future<void> fetchAllChannelVideos() async {
    final List<VideoArticle> allVideos = [];
    
    for (final entry in _newsChannels.entries) {
      final channelName = entry.key;
      final channelId = entry.value;
      
      try {
        final videos = await fetchChannelVideos(channelId, channelName);
        allVideos.addAll(videos);
      } catch (e) {
        print('Error fetching videos from $channelName: $e');
      }
    }
    
    // Sort by publish time (most recent first)
    allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
      // Add to stream safely
    try {
      if (!_videosController.isClosed) {
        _videosController.add(allVideos);
      }
    } catch (e) {
      print('Error adding videos to stream: $e');
    }
    
    print('Fetched ${allVideos.length} videos from ${_newsChannels.length} channels');
  }

  // Fetch latest videos from a specific channel
  Future<List<VideoArticle>> fetchChannelVideos(String channelId, String channelName) async {
    try {
      // Get latest uploads from channel
      final url = Uri.parse(
        '$_baseUrl/search?'
        'part=snippet&'
        'channelId=$channelId&'
        'order=date&'
        'type=video&'
        'maxResults=5&'
        'publishedAfter=${DateTime.now().subtract(const Duration(days: 7)).toIso8601String()}&'
        'key=$_apiKey'
      );
      
      print('Fetching from $channelName: $url');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Safely check if items exist and is a list
        if (data != null && data['items'] != null && data['items'] is List) {
          final videos = (data['items'] as List)
              .where((item) => item != null) // Filter out null items
              .map((json) {
                try {
                  // Safely set the channel name from our mapping
                  if (json['snippet'] != null) {
                    json['snippet']['channelTitle'] = channelName;
                  }
                  return VideoArticle.fromYouTubeApi(json);
                } catch (e) {
                  print('Error parsing video item: $e');
                  return null;
                }
              })
              .where((video) => video != null) // Filter out failed parses
              .cast<VideoArticle>()
              .toList();
        
          print('✓ $channelName: ${videos.length} videos fetched');
          return videos;
        } else {
          print('✗ $channelName: No valid items in response');
          return [];
        }
      } else {
        print('✗ $channelName API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('✗ $channelName error: $e');
      return [];
    }
  }

  // Search for news videos by keyword
  Future<List<VideoArticle>> searchNewsVideos(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?'
        'part=snippet&'
        'q=$query+news&'
        'order=relevance&'
        'type=video&'
        'publishedAfter=${DateTime.now().subtract(const Duration(days: 3)).toIso8601String()}&'
        'maxResults=10&'
        'key=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null && data['items'] != null && data['items'] is List) {
          final videos = (data['items'] as List)
              .where((item) => item != null)
              .map((json) {
                try {
                  return VideoArticle.fromYouTubeApi(json);
                } catch (e) {
                  print('Error parsing search video: $e');
                  return null;
                }
              })
              .where((video) => video != null)
              .cast<VideoArticle>()
              .toList();
          
          return videos;
        } else {
          return [];
        }
      } else {
        print('Search API error: ${response.statusCode}');
        return VideoArticle.sampleVideos;
      }
    } catch (e) {
      print('Search error: $e');
      return VideoArticle.sampleVideos;
    }
  }

  // Fallback method for compatibility
  Future<List<VideoArticle>> fetchVideos() async {
    try {
      await fetchAllChannelVideos();
      return await videosStream.first.timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error getting latest videos: $e');
      return VideoArticle.sampleVideos;
    }
  }

  // Get video details (view count, duration, etc.)
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/videos?'
        'part=statistics,contentDetails&'
        'id=$videoId&'
        'key=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && 
            data['items'] != null && 
            data['items'] is List && 
            (data['items'] as List).isNotEmpty) {
          return (data['items'] as List)[0] ?? {};
        }
      }
      
      return {};
    } catch (e) {
      print('Error getting video details: $e');
      return {};
    }
  }
}