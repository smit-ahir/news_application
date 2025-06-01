import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/article_model.dart';

class BookmarkProvider extends ChangeNotifier {
  List<ArticleModel> _bookmarkedArticles = [];
  bool _isLoading = false;
  
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  
  static const String _bookmarksKey = 'bookmarked_articles';
  
  BookmarkProvider() {
    _loadBookmarks();
  }
  
  Future<void> _loadBookmarks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      _bookmarkedArticles = bookmarksJson
          .map((json) => ArticleModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = _bookmarkedArticles
          .map((article) => jsonEncode(article.toJson()))
          .toList();
      
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }
  
  bool isBookmarked(ArticleModel article) {
    return _bookmarkedArticles.any((bookmarked) => bookmarked.url == article.url);
  }
  
  Future<void> toggleBookmark(ArticleModel article) async {
    if (isBookmarked(article)) {
      _bookmarkedArticles.removeWhere((bookmarked) => bookmarked.url == article.url);
    } else {
      _bookmarkedArticles.add(article);
    }
    
    notifyListeners();
    await _saveBookmarks();
  }
  
  Future<void> removeBookmark(ArticleModel article) async {
    _bookmarkedArticles.removeWhere((bookmarked) => bookmarked.url == article.url);
    notifyListeners();
    await _saveBookmarks();
  }
  
  Future<void> clearAllBookmarks() async {
    _bookmarkedArticles = [];
    notifyListeners();
    await _saveBookmarks();
  }
}
