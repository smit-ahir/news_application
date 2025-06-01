import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  late final String _apiKey;
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client() {
    _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('API key not found. Please add your NewsAPI key to the .env file.');
    }
  }

  Future<List<ArticleModel>> getTopHeadlines({
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/top-headlines?country=$country&page=$page&pageSize=$pageSize&apiKey=$_apiKey'),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to load top headlines: $e');
    }
  }

  Future<List<ArticleModel>> getNewsByCategory({
    required String category,
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/top-headlines?country=$country&category=$category&page=$page&pageSize=$pageSize&apiKey=$_apiKey'),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to load $category news: $e');
    }
  }

  Future<List<ArticleModel>> searchNews({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/everything?q=$query&sortBy=$sortBy&page=$page&pageSize=$pageSize&apiKey=$_apiKey'),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }

  List<ArticleModel> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['status'] == 'ok') {
        final List<dynamic> articles = data['articles'];
        return articles.map((article) => ArticleModel.fromJson(article)).toList();
      } else if (data['status'] == 'error') {
        if (data['code'] == 'rateLimited' || data['code'] == 'apiKeyExhausted') {
          throw Exception('API limit reached. Please try again later.');
        }
        throw Exception(data['message']);
      }
      
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your NewsAPI key.');
    } else if (response.statusCode == 429) {
      throw Exception('API limit reached. Please try again later.');
    } else {
      throw Exception('Failed to load news. Status code: ${response.statusCode}');
    }
  }
}
