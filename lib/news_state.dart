import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'news_model.dart';

class NewsState extends ChangeNotifier {
  List<News> _bookmarkedArticles = [];
  List<News> _likedArticles = [];

  List<News> get bookmarkedArticles => _bookmarkedArticles;
  List<News> get likedArticles => _likedArticles;

  NewsState() {
    _loadArticles();
  }

  // Load articles from SharedPreferences when the app starts
  void _loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    String? bookmarkedData = prefs.getString('bookmarkedArticles');
    String? likedData = prefs.getString('likedArticles');

    if (bookmarkedData != null) {
      List<dynamic> bookmarkedJson = json.decode(bookmarkedData);
      _bookmarkedArticles = bookmarkedJson.map((e) => News.fromJson(e)).toList();
    }
    if (likedData != null) {
      List<dynamic> likedJson = json.decode(likedData);
      _likedArticles = likedJson.map((e) => News.fromJson(e)).toList();
    }

    notifyListeners();
  }

  // Save articles to SharedPreferences after any changes
  void _saveArticles() async {
    final prefs = await SharedPreferences.getInstance();

    String bookmarkedData = json.encode(_bookmarkedArticles.map((e) => e.toJson()).toList());
    String likedData = json.encode(_likedArticles.map((e) => e.toJson()).toList());

    await prefs.setString('bookmarkedArticles', bookmarkedData);
    await prefs.setString('likedArticles', likedData);
  }

  // Toggle bookmark status and save to SharedPreferences
  void toggleBookmark(News news) {
    if (_bookmarkedArticles.contains(news)) {
      _bookmarkedArticles.remove(news);
    } else {
      _bookmarkedArticles.add(news);
    }
    _saveArticles();
    notifyListeners();
  }

  // Toggle like status and save to SharedPreferences
  void toggleLike(News news) {
    if (_likedArticles.contains(news)) {
      _likedArticles.remove(news);
    } else {
      _likedArticles.add(news);
    }
    _saveArticles();
    notifyListeners();
  }
}
