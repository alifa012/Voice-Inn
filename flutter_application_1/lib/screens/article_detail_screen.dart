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

  @override
  void dispose() {
    flutterTts.stop(); // stop speech when leaving screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.source ?? 'Voice-INN',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Meta info
            if (article.source != null || article.publishedAt != null)
              Row(
                children: [
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (article.source != null && article.publishedAt != null)
                    const Text(' • '),
                  if (article.publishedAt != null)
                    Text(
                      article.publishedAt!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Image unavailable'),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Content
            Text(
              article.content.isNotEmpty
                  ? article.content
                  : 'No content available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),

      // Floating Action Buttons for TTS
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "speakBtn",
            onPressed: () async {
              final lang = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 600, 20, 100),
                items: [
                  const PopupMenuItem(value: "en-US", child: Text("English")),
                  
                  const PopupMenuItem(value: "fr-FR", child: Text("French")),
                  const PopupMenuItem(value: "es-ES", child: Text("Spanish")),
                  const PopupMenuItem(value: "de-DE", child: Text("German")),
                  const PopupMenuItem(value: "it-IT", child: Text("Italian")),
                  const PopupMenuItem(value: "pt-PT", child: Text("Portuguese")),
                  const PopupMenuItem(value: "hi-IN", child: Text("Hindi")),
                  const PopupMenuItem(value: "zh-CN", child: Text("Chinese")),
                  
                ],
              );
              if (lang != null) {
                _speak(article.content, lang: lang);
              }
            },
            child: Image.asset(
              'logo.png',   // ✅ Voice-INN logo
              fit: BoxFit.contain,
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "stopBtn",
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
            onPressed: _stop,
          ),
        ],
      ),
    );
  }
}
