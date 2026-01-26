import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import 'article_detail_screen.dart'; // ✅ Import the detail screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> _articles;

  @override
  void initState() {
    super.initState();
    _articles = ApiService().fetchArticles(); // load from JSON
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice-INN')),
      body: FutureBuilder<List<Article>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading articles'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          final articles = snapshot.data!;
          // ✅ Debug: print how many articles were loaded
          print('Loaded ${articles.length} articles');

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              // ✅ Debug: print each article title as it’s rendered
              print('Rendering article: ${article.title}');

              return InkWell(
                onTap: () {
                  print('[NAV] Tapped article: ${article.title}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(article.title),
                  subtitle: Text(article.summary),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
