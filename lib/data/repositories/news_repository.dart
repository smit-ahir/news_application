import '../datasources/news_api_service.dart';
import '../models/article_model.dart';

class NewsRepository {
  final NewsApiService _apiService;

  NewsRepository({NewsApiService? apiService})
      : _apiService = apiService ?? NewsApiService();

  Future<List<ArticleModel>> getTopHeadlines({
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _apiService.getTopHeadlines(
      country: country,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<List<ArticleModel>> getNewsByCategory({
    required String category,
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _apiService.getNewsByCategory(
      category: category,
      country: country,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<List<ArticleModel>> searchNews({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _apiService.searchNews(
      query: query,
      sortBy: sortBy,
      page: page,
      pageSize: pageSize,
    );
  }
}
