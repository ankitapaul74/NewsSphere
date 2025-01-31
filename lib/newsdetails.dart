import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'news_model.dart';
import 'news_state.dart';

import 'package:share_plus/share_plus.dart';

class NewsDetailPage extends StatelessWidget {
  final News news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsState = Provider.of<NewsState>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Image Section
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              image: news.urlToImage != null
                  ? DecorationImage(
                image: NetworkImage(news.urlToImage!),
                fit: BoxFit.cover,
              )
                  : null,
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),

                // Like, Bookmark, and Share Buttons
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16, // Adjusts position based on device's status bar
                  right: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Bookmark Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                        onPressed: () {
                          newsState.toggleBookmark(news);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newsState.bookmarkedArticles.contains(news)
                                    ? "Article bookmarked!"
                                    : "Bookmark removed!",
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          newsState.bookmarkedArticles.contains(news)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 12),

                      // Like Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                        onPressed: () {
                          newsState.toggleLike(news);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newsState.likedArticles.contains(news)
                                    ? "You liked the article!"
                                    : "Like removed!",
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          newsState.likedArticles.contains(news)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: newsState.likedArticles.contains(news)
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),

                      SizedBox(height: 12),

                      // Share Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Share.share(
                            '${news.title}\n\n${news.description}\n\nRead more: ${news.url}',
                            subject: "Check out this article!",
                          );
                        },
                        child: Icon(Icons.share, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Headline
                Positioned(
                  bottom: 50,
                  left: 16,
                  right: 16,
                  child: Text(
                    news.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Published At
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Published: ${news.publishedAt.split('T')[0]}", // Extract only the date part
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        news.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Read Full Article Button
                  ElevatedButton(
                    onPressed: () {
                      if (news.url != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewPage(url: news.url!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "URL not available for this article")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color(0xFF2C3E50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Read Full Article",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Article'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
