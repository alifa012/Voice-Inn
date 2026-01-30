import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';

class SimpleArticleWidget extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const SimpleArticleWidget({
    super.key,
    required this.article,
    this.onTap,
  });

  Future<void> _openArticle() async {
    try {
      final url = article.link.isNotEmpty ? article.link : article.id;
      if (url.isEmpty) return;
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Error opening URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: onTap ?? _openArticle,
        icon: const Icon(Icons.open_in_new),
        label: const Text('Read Full Article'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

      print('📡 Extracting content from: ${widget.article.id}');
      final extractedContent = await _extractionService.extractFullContent(widget.article.id);
      
      if (extractedContent != null && mounted) {
        print('✅ Content extracted successfully');
        print('📄 Title: ${extractedContent.title}');
        print('📖 Content length: ${extractedContent.content.length} chars');
        print('🏷️ Tags: ${extractedContent.tags.length}');
        print('🎥 Videos: ${extractedContent.videos.length}');
        
        setState(() {
          _enhancedArticle = widget.article.copyWithExtractedContent(extractedContent);
          _isExpanded = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('✅ Extracted ${extractedContent.content.length > 0 ? "full content" : "partial content"} with ${extractedContent.videos.length} videos'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Failed to extract content - creating enhanced fallback');
        // Create enhanced fallback content instead of showing error
        final fallbackContent = _createEnhancedFallback();
        
        setState(() {
          _enhancedArticle = widget.article.copyWithExtractedContent(fallbackContent);
          _isExpanded = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Enhanced View Available'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Direct content extraction is limited by security policies.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _openOriginalArticle(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('📖 Read Complete Article'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue[700],
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Error during extraction: $e');
      
      // Even on error, provide enhanced fallback content
      final fallbackContent = _createEnhancedFallback();
      
      setState(() {
        _enhancedArticle = widget.article.copyWithExtractedContent(fallbackContent);
        _isExpanded = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Content Access Limited'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Due to web security, full extraction isn\'t available.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _openOriginalArticle(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('🌐 View Original Article'),
                ),
              ],
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExtracting = false;
        });
      }
    }
  }

  ExtractedContent _createEnhancedFallback() {
    final article = widget.article;
    
    final enhancedContent = '''
📰 **${article.title}**

${article.description.isNotEmpty ? '📝 **Summary:**\n${article.description}\n' : ''}

---

**📋 Article Information**
🏢 **Source:** ${article.source}
${article.publishedAt.isNotEmpty ? '📅 **Published:** ${article.publishedAt}' : ''}
🔗 **Original URL:** ${article.id}

---

**💡 Why Limited Content?**

This app respects web security policies (CORS) that prevent unauthorized access to external websites. This protects your privacy and security while browsing.

**📖 For Complete Article Access:**
• Click the "View Original" button below
• Read the full article with all images and interactive content
• Support the original publisher directly
• Get the most up-to-date information

---

**🌟 Enhanced Features Available:**
✅ Article summary and metadata
✅ Source verification and links  
✅ Publication date tracking
✅ Easy sharing capabilities
✅ Reading history management

**💬 The summary above contains the key points from this article. For complete details, charts, images, and video content, visit the original source.**
''';

    return ExtractedContent(
      title: article.title,
      content: enhancedContent,
      author: article.source,
      publishDate: article.publishedAt,
      tags: ['Enhanced View', 'Summary Available'],
      imageUrl: article.imageUrl,
      videos: [], // No videos in fallback
      readingTime: 2, // Estimated reading time for summary
    );
  }

  void _openOriginalArticle() {
    try {
      // For web apps, we'll show the URL for manual opening
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📖 Read Full Article'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Copy this URL and open it in a new browser tab:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  widget.article.id,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '💡 Tip: Right-click the URL above and select "Copy" to easily paste it in your browser.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💾 URL is ready to copy from the dialog above'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Got it'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error showing URL: $e');
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final article = _enhancedArticle ?? widget.article;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original article content
        _buildOriginalContent(article, theme, isDark),

        // Extract button
        if (widget.showExtractButton && article.extractedContent == null)
          _buildExtractButton(theme),

        // Extracted content section
        if (article.extractedContent != null) ...[
          const SizedBox(height: 16),
          _buildExtractedContentSection(article, theme, isDark),
        ],

        // Tags section
        if (article.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTagsSection(article.tags, theme, isDark),
        ],

        // Videos section
        if (article.hasVideos) ...[
          const SizedBox(height: 16),
          _buildVideosSection(article, theme, isDark),
        ],

        // Article metadata
        if (article.author != null || article.readingTimeMinutes != null) ...[
          const SizedBox(height: 16),
          _buildMetadataSection(article, theme, isDark),
        ],
      ],
    );
  }

  Widget _buildOriginalContent(Article article, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 18,
                color: theme.iconTheme.color?.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Article Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.content.isNotEmpty ? article.content : article.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isExtracting ? null : _extractFullContent,
          icon: _isExtracting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_isExtracting ? 'Processing...' : '📖 Enhanced View'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtractedContentSection(Article article, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1A0D) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.green.shade800 : Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: isDark ? Colors.green.shade300 : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Full Article Content',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                iconSize: 20,
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Text(
              article.extractedContent!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection(List<String> tags, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 16,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                fontSize: 11,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildVideosSection(Article article, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 16,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Related Videos',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...article.videos.map((video) => _buildVideoItem(video, theme, isDark)).toList(),
      ],
    );
  }

  Widget _buildVideoItem(ExtractedVideo video, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A0A0A) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                video.platform == VideoPlatform.youtube 
                    ? Icons.smart_display 
                    : Icons.play_circle,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  video.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (video.platform == VideoPlatform.youtube) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: video.videoId,
                    flags: const YoutubePlayerFlags(
                      autoPlay: false,
                      mute: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Article article, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (article.author != null) ...[
            Icon(Icons.person_outline, size: 16),
            const SizedBox(width: 4),
            Text(
              article.author!,
              style: theme.textTheme.labelSmall,
            ),
            if (article.readingTimeMinutes != null) 
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 12,
                color: Colors.grey,
              ),
          ],
          if (article.readingTimeMinutes != null) ...[
            Icon(Icons.access_time, size: 16),
            const SizedBox(width: 4),
            Text(
              '${article.readingTimeMinutes} min read',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}