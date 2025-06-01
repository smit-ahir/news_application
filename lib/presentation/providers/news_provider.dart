import 'package:flutter/material.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/news_repository.dart';

enum LoadingStatus { initial, loading, loaded, error }

class NewsProvider extends ChangeNotifier {
  final NewsRepository _repository;
  
  LoadingStatus _status = LoadingStatus.initial;
  String _errorMessage = '';
  List<ArticleModel> _articles = [];
  String _currentCategory = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  // Getters
  LoadingStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<ArticleModel> get articles => _articles;
  String get currentCategory => _currentCategory;
  bool get hasMoreData => _hasMoreData;
  
  // Categories for news
  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];
  
  NewsProvider({NewsRepository? repository})
      : _repository = repository ?? NewsRepository();
  
  // Fetch top headlines
  Future<void> fetchTopHeadlines({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }
    
    if (!_hasMoreData && !refresh) return;
    
    try {
      if (_currentPage == 1) {
        _status = LoadingStatus.loading;
        _articles = [];
        notifyListeners();
      }
      
      final newArticles = await _repository.getTopHeadlines(
        page: _currentPage,
      );
      
      if (newArticles.isEmpty) {
        _hasMoreData = false;
      } else {
        if (_currentPage == 1) {
          _articles = newArticles;
        } else {
          _articles.addAll(newArticles);
        }
        _currentPage++;
      }
      
      _status = LoadingStatus.loaded;
      _currentCategory = 'general';
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  // Fetch news by category
  Future<void> fetchNewsByCategory(String category, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }
    
    if (!_hasMoreData && !refresh) return;
    
    try {
      if (_currentPage == 1) {
        _status = LoadingStatus.loading;
        _articles = [];
        notifyListeners();
      }
      
      final newArticles = await _repository.getNewsByCategory(
        category: category,
        page: _currentPage,
      );
      
      if (newArticles.isEmpty) {
        _hasMoreData = false;
      } else {
        if (_currentPage == 1) {
          _articles = newArticles;
        } else {
          _articles.addAll(newArticles);
        }
        _currentPage++;
      }
      
      _status = LoadingStatus.loaded;
      _currentCategory = category;
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  // Search news
  Future<List<ArticleModel>> searchNews(String query) async {
    try {
      return await _repository.searchNews(query: query);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
  
  void resetState() {
    _status = LoadingStatus.initial;
    _errorMessage = '';
    _articles = [];
    _currentCategory = '';
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}
