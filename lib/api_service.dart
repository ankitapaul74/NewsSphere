import 'dart:convert';
import 'package:http/http.dart' as http;
import 'news_model.dart';

class ApiService {
  static const String _baseUrl = "https://newsapi.org/v2";
  static const String _apiKey = "55954b55665e4d628723a4790f4b466e"; // Replace with your NewsAPI key

  // Fetch trending news
  static Future<List<News>> fetchTrendingNews() async {
    try {
      final url = Uri.parse("$_baseUrl/top-headlines?country=us&apiKey=$_apiKey");
      final response = await http.get(url);

      // Log the response to see the raw data
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'ok') {
          throw Exception("API Error: ${data['message']}");
        }
        final List articles = data['articles'];
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load trending news with status: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching trending news: $e');
      throw Exception("Failed to load trending news");
    }
  }

  // Fetch news by channel
  static Future<List<News>> fetchNewsByChannel(String channelId) async {
    try {
      final url = Uri.parse("$_baseUrl/top-headlines?sources=$channelId&apiKey=$_apiKey");
      final response = await http.get(url);

      // Log the response to see the raw data
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'ok') {
          throw Exception("API Error: ${data['message']}");
        }
        final List articles = data['articles'];
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load news for channel: $channelId with status: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching news for channel $channelId: $e');
      throw Exception("Failed to load news for channel: $channelId");
    }
  }
}
