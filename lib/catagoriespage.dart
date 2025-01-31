import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'news_model.dart';
import 'newsdetails.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  final String apiKey = "";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";

  late TabController _tabController;

  Map<String, List<News>> categoryArticles = {};
  Map<String, bool> categoryLoading = {};

  Future<void> fetchNewsByCategory(String category) async {
    final String url = "$baseUrl?category=$category&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['articles'] as List;
        setState(() {
          categoryArticles[category] = data.map((article) => News.fromJson(article)).toList();
          categoryLoading[category] = false;
        });
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      setState(() {
        categoryLoading[category] = false;
      });

      print("Error fetching news for category $category: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

    ['business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'].forEach((category) {
      categoryLoading[category] = true;
      fetchNewsByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Discover",
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color(0xFF2C3E50), // Deep Blue for AppBar
        elevation: 4, // Subtle shadow for depth
        centerTitle: true,
      ),
      body: Column(
        children: [

          Container(
            color: Color(0xFF34495E),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Color(0xFF1ABC9C),
                indicatorWeight: 3.0,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.business, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Business"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.movie, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Entertainment"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.public, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("General"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.health_and_safety, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Health"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.science, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Science"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.sports, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Sports"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.computer, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Technology"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // TabBarView to display content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildNewsList('business'),
                buildNewsList('entertainment'),
                buildNewsList('general'),
                buildNewsList('health'),
                buildNewsList('science'),
                buildNewsList('sports'),
                buildNewsList('technology'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildNewsList(String category) {
    if (categoryLoading[category] == true) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1ABC9C))));
    }

    if (categoryArticles.containsKey(category)) {
      final articles = categoryArticles[category]!;

      return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the News Detail Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(news: article),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  article.urlToImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          article.urlToImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    color: Colors.grey[300],
                    height: 200,
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.6), // Border color with transparency
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50), // Dark color for headline
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          article.description ?? 'No description available.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Center(child: Text('No articles available.'));
    }
  }
}
