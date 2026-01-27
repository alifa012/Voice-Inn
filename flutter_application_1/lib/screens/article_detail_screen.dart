import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/article.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text, {String lang = "en-US"}) async {
    await flutterTts.setLanguage(lang);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.speak(text);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  String _getFullArticleText() {
    final article = widget.article;
    // Combine all available text content, ensuring maximum information is displayed
    final List<String> textParts = [];
    
    // Always add content if available and substantial
    if (article.content.isNotEmpty && article.content.trim().length > 10) {
      textParts.add(article.content.trim());
    }
    
    // Add description if it's different and substantial
    if (article.description.isNotEmpty && 
        article.description.trim().length > 10 &&
        article.description.trim() != article.title.trim() &&
        !textParts.any((part) => part.toLowerCase().contains(article.description.toLowerCase().substring(0, 
          article.description.length > 50 ? 50 : article.description.length)))) {
      textParts.add(article.description.trim());
    }
    
    // Add summary if it's different and adds value
    if (article.summary.isNotEmpty && 
        article.summary.trim().length > 10 &&
        article.summary.trim() != article.title.trim() &&
        article.summary.trim() != article.description.trim() &&
        !textParts.any((part) => part.toLowerCase().contains(article.summary.toLowerCase().substring(0, 
          article.summary.length > 50 ? 50 : article.summary.length)))) {
      textParts.add(article.summary.trim());
    }
    
    // If we have substantial content, join it with proper formatting
    if (textParts.isNotEmpty) {
      return textParts.join('\n\n• • •\n\n');
    }
    
    // Fallback to any available text with priority order
    if (article.content.trim().isNotEmpty) {
      return article.content.trim();
    } else if (article.description.trim().isNotEmpty) {
      return article.description.trim();
    } else if (article.summary.trim().isNotEmpty) {
      return article.summary.trim();
    } else {
      return 'This article\'s full content is not available in the current feed. The article title and metadata are shown above.';
    }
  }

  int _getWordCount() {
    final fullText = _getFullArticleText();
    return fullText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  int _getEstimatedReadingTime() {
    final wordCount = _getWordCount();
    // Average reading speed is 200-250 words per minute, using 225
    return (wordCount / 225).ceil().clamp(1, 99);
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? color.shade300 : color.shade700,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? color.shade300 : color.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voice-INN',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0D0D10) : Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CATEGORY + SOURCE + TIME
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children: [
                  if (article.category.isNotEmpty)
                    Chip(
                      label: Text(
                        article.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          isDark ? Colors.redAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.08),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.redAccent.shade100 : Colors.redAccent,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  if (article.source != null && article.source!.isNotEmpty)
                    Text(
                      article.source!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('•  ', style: TextStyle(fontSize: 12)),
                      Icon(Icons.access_time, size: 14, color: theme.iconTheme.color?.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        article.publishedAtLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // TITLE
              Text(
                article.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 18),

              // ARTICLE METADATA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetadataItem(
                      icon: Icons.schedule_outlined,
                      label: 'Reading Time',
                      value: '${_getEstimatedReadingTime()} min',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    _buildMetadataItem(
                      icon: Icons.text_fields_outlined,
                      label: 'Word Count',
                      value: '~${_getWordCount()}',
                      color: Colors.green,
                      isDark: isDark,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    _buildMetadataItem(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: article.category.isNotEmpty ? article.category : 'News',
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // IMAGE
              if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Text('Image unavailable'),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ARTICLE SUMMARY/DESCRIPTION
              if (article.summary.isNotEmpty && article.summary != article.title)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1F) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
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
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Article Summary',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // DETAILED DESCRIPTION
              if (article.description.isNotEmpty && 
                  article.description != article.summary && 
                  article.description != article.title)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1F1A) : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
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
                            Icons.info_outline,
                            size: 18,
                            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Detailed Information',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // FULL CONTENT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF15151A) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: theme.iconTheme.color?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Complete Article',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getFullArticleText(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    
                    // SOURCE INFORMATION ONLY
                    const SizedBox(height: 16),
                    Divider(color: theme.dividerColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    if (article.source != null && article.source!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.source_outlined,
                            size: 16,
                            color: theme.iconTheme.color?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Source: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              article.source!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 80), // space for FABs
            ],
          ),
        ),
      ),

      // Bottom-right controls stacked vertically
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TTS button
          FloatingActionButton(
            heroTag: "speakBtn",
            backgroundColor: isDark ? Colors.redAccent.shade200 : Colors.redAccent,
            onPressed: () async {
              final lang = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 600, 20, 100),
                items: const [
                  PopupMenuItem(value: "en-US", child: Text("English")),
                  PopupMenuItem(value: "fr-FR", child: Text("French")),
                  PopupMenuItem(value: "es-ES", child: Text("Spanish")),
                  PopupMenuItem(value: "de-DE", child: Text("German")),
                  PopupMenuItem(value: "it-IT", child: Text("Italian")),
                  PopupMenuItem(value: "pt-PT", child: Text("Portuguese")),
                  PopupMenuItem(value: "hi-IN", child: Text("Hindi")),
                  PopupMenuItem(value: "zh-CN", child: Text("Chinese")),
                ],
              );
              if (lang != null) {
                // Create comprehensive text for TTS
                final speakText = '${article.title}. ${_getFullArticleText()}';
                _speak(speakText, lang: lang);
              }
            },
            child: const Icon(Icons.volume_up_rounded, size: 26),
          ),
          const SizedBox(height: 12),
          // STOP button
          FloatingActionButton(
            heroTag: "stopBtn",
            backgroundColor: Colors.red.shade700,
            onPressed: _stop,
            child: const Icon(Icons.stop_rounded),
          ),
        ],
      ),
    );
  }
}