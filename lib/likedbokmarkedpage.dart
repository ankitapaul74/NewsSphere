
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'news_model.dart';
import 'news_state.dart';
import 'newsdetails.dart';

class BookmarkedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Bookmarks & Likes",
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF2C3E50),
          elevation: 6,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bookmark_add_outlined),
                    SizedBox(width: 8),
                    Text("Bookmarked"),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.favorite_outline_rounded),
                    SizedBox(width: 8),
                    Text("Liked"),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            _buildArticlesList(context, isBookmarked: true),
            _buildArticlesList(context, isBookmarked: false),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context, {required bool isBookmarked}) {
    final newsState = Provider.of<NewsState>(context);
    final articles = isBookmarked
        ? newsState.bookmarkedArticles
        : newsState.likedArticles;

    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBookmarked ? Icons.bookmark_border : Icons.favorite_border,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isBookmarked
                    ? "No articles bookmarked yet."
                    : "No articles liked yet.",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(context, articles[index], isBookmarked);
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, News news, bool isBookmarked) {
    final newsState = Provider.of<NewsState>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade100, width: 2), // Colorful border
      ),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(opacity: animation, child: NewsDetailPage(news: news)),
            ),
          );
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: news.urlToImage != null
                    ? Image.network(
                  news.urlToImage!,
                  width: 120,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 120,
                  height: 100,
                  color: const Color(0xFFF8F8F8),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.orange, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.description ?? "No description available.",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  _showConfirmDialog(context, news, isBookmarked);
                },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: 1.2,
                  child: Icon(
                    isBookmarked
                        ? (newsState.bookmarkedArticles.contains(news)
                        ? Icons.bookmark_added
                        : Icons.bookmark_add)
                        : (newsState.likedArticles.contains(news)
                        ? Icons.favorite
                        : Icons.favorite_border),
                    color: isBookmarked
                        ? (newsState.bookmarkedArticles.contains(news)
                        ? Colors.teal
                        : Colors.grey)
                        : (newsState.likedArticles.contains(news)
                        ? Colors.redAccent
                        : Colors.grey),
                    size: 24, // Reduced icon size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, News news, bool isBookmarked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
          isBookmarked
              ? 'Are you sure you want to remove this bookmark?'
              : 'Are you sure you want to remove this like?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isBookmarked) {
                Provider.of<NewsState>(context, listen: false)
                    .toggleBookmark(news);
              } else {
                Provider.of<NewsState>(context, listen: false)
                    .toggleLike(news);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
