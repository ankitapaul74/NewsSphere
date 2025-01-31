import 'package:NewsSphere/videonewspage.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'newsdetails.dart';
import 'likedbokmarkedpage.dart';
import 'catagoriespage.dart';
import 'news_model.dart';

class NewsAppHome extends StatefulWidget {
  @override
  _NewsAppHomeState createState() => _NewsAppHomeState();
}

class _NewsAppHomeState extends State<NewsAppHome> {
  final String apiKey = "";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";
  String selectedChannel = "bbc-news";

  final List<Map<String, String>> newsChannels = [
    {"id": "bbc-news", "name": "BBC News"},
    {"id": "cnn", "name": "CNN"},
    {"id": "fox-news", "name": "Fox News"},
    {"id": "al-jazeera-english", "name": "Al Jazeera"},
    {"id": "the-times-of-india", "name": "Times of India"},
    {"id": "reuters", "name": "Reuters"},
    {"id": "abc-news", "name": "ABC News"},
    {"id": "google-news", "name": "Google News"},
    {"id": "usa-today", "name": "USA Today"},
    {"id": "nbc-news", "name": "NBC News"},
  ];

  Future<List<News>> fetchNews(String channel) async {
    final String url = "$baseUrl?sources=$channel&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['articles'] as List;
      return data.map((article) => News.fromJson(article)).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GoRead - ${newsChannels.firstWhere((channel) => channel['id'] == selectedChannel)['name']}",
          style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
          )
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2C3E50),
        elevation: 10,
        shadowColor: Colors.black45,
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(selectedChannel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No news available"));
          } else {
            final articles = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBreakingNewsCarousel(articles),
                  buildChannelChips(),
                  buildRecommendations(articles),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        backgroundColor: Color(0xFF2C3E50),
        child: Icon(Icons.refresh, size: 28, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        selectedItemColor: Color(0xFF2C3E50), // Color for the selected item
        unselectedItemColor: Colors.grey[600], // Color for unselected items
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "Videos",
          ),
        ],
        currentIndex: 0, // Set the initial selected index
        onTap: (index) {
          if (index == 0) {
            setState(() {}); // Refresh for Home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookmarkedPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoriesPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YouTubeNewsPage(),
              ),
            );
          }
        },
      ),

    );
  }

  Widget buildBreakingNewsCarousel(List<News> articles) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: articles.length < 5 ? articles.length : 5,
            itemBuilder: (context, index, _) {
              final article = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(news: article),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article.urlToImage ?? "https://beautyrepublicfdl.com/wp-content/uploads/2020/06/placeholder-image.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network('https://beautyrepublicfdl.com/wp-content/uploads/2020/06/placeholder-image.jpg');
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            article.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: 260,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: Duration(seconds: 4),
              viewportFraction: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChannelChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: newsChannels.map((channel) {
            final isSelected = selectedChannel == channel["id"];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedChannel = channel["id"]!;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [Colors.grey.withOpacity(0.6), Colors.grey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? Colors.black54 : Colors.transparent,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.label_important,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          channel["name"]!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildRecommendations(List<News> articles) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended for You",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(news: article),
                    ),
                  );
                },
                child: Card(
                  elevation: 6,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.tealAccent.withOpacity(0.2),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              article.urlToImage ?? "https://beautyrepublicfdl.com/wp-content/uploads/2020/06/placeholder-image.jpg",
                              fit: BoxFit.cover,
                              width: 100,
                              height: 80,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  article.description ?? "No description available",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
