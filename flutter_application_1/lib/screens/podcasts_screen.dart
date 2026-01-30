import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_article.dart';
import '../services/youtube_service.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  final YouTubeService _youtubeService = YouTubeService();
  List<VideoArticle> _videos = [];
  bool _isLoading = true;
  String? _error;
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initializeVideoStream();
  }

  @override
  void dispose() {
    _youtubeService.dispose();
    super.dispose();
  }

  void _initializeVideoStream() {
    _youtubeService.videosStream.listen(
      (videos) {
        if (mounted) {
          setState(() {
            _videos = videos ?? []; // Handle potential null videos list
            _isLoading = false;
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error?.toString() ?? 'Unknown error occurred';
            _isLoading = false;
          });
        }
      },
    );

    try {
      _youtubeService.startRealTimeUpdates();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to start video updates: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  List<VideoArticle> get _filteredVideos {
    if (_currentFilter == 'All') {
      return _videos;
    }
    return _videos.where((video) {
      try {
        return video.channelName.toLowerCase().contains(_currentFilter.toLowerCase());
      } catch (e) {
        print('Error filtering video: $e');
        return false; // Skip problematic videos
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video News'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _videos.length),
                  const SizedBox(width: 8),
                  _buildFilterChip('BBC', _videos.where((v) => v.channelName.toLowerCase().contains('bbc')).length),
                  const SizedBox(width: 8),
                  _buildFilterChip('CNN', _videos.where((v) => v.channelName.toLowerCase().contains('cnn')).length),
                  const SizedBox(width: 8),
                  _buildFilterChip('NTV', _videos.where((v) => v.channelName.toLowerCase().contains('ntv')).length),
                  const SizedBox(width: 8),
                  _buildFilterChip('KTN', _videos.where((v) => v.channelName.toLowerCase().contains('ktn')).length),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final theme = Theme.of(context);
    final isSelected = _currentFilter == label;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = label;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video news...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
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
              'Failed to load videos',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _youtubeService.startRealTimeUpdates();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredVideos = _filteredVideos;

    if (filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: theme.hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos available',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for the latest video news',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _youtubeService.startRealTimeUpdates();
        await Future.delayed(const Duration(seconds: 2));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredVideos.length,
        itemBuilder: (context, index) {
          return _buildVideoCard(filteredVideos[index], theme);
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoArticle video, ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        try {
          final uri = Uri.parse('https://youtube.com/watch?v=${video.videoId}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open video: $e')),
          );
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: video.thumbnailUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(video.thumbnailUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: video.thumbnailUrl.isEmpty ? theme.colorScheme.surfaceContainerHighest : null,
                    ),
                    child: video.thumbnailUrl.isEmpty
                        ? Icon(
                            Icons.video_library,
                            size: 48,
                            color: theme.hintColor,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration ?? '0:00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.channelName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          video.formattedViewCount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          video.publishedAtLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}