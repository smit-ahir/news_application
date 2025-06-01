import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/data/datasources/news_api_service.dart';
import 'package:news_app/data/models/article_model.dart';

import 'news_api_service_test.mocks.dart';

// Generate a MockClient using the Mockito package
@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late NewsApiService newsApiService;

  setUp(() async {
    // Setup dotenv mock
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: 'NEWS_API_KEY=test_api_key');
    
    mockHttpClient = MockClient();
    newsApiService = NewsApiService(client: mockHttpClient);
  });

  group('getTopHeadlines', () {
    final topHeadlinesJson = '''
    {
      "status": "ok",
      "totalResults": 2,
      "articles": [
        {
          "source": {
            "id": "bbc-news",
            "name": "BBC News"
          },
          "author": "BBC News",
          "title": "Test Article 1",
          "description": "This is a test article description",
          "url": "https://www.bbc.com/news/test-article-1",
          "urlToImage": "https://example.com/image1.jpg",
          "publishedAt": "2025-06-01T12:00:00Z",
          "content": "Test article content 1"
        },
        {
          "source": {
            "id": "cnn",
            "name": "CNN"
          },
          "author": "CNN",
          "title": "Test Article 2",
          "description": "This is another test article description",
          "url": "https://www.cnn.com/news/test-article-2",
          "urlToImage": "https://example.com/image2.jpg",
          "publishedAt": "2025-06-01T11:00:00Z",
          "content": "Test article content 2"
        }
      ]
    }
    ''';

    test('returns a list of articles if the http call completes successfully', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(topHeadlinesJson, 200),
      );

      // Act
      final articles = await newsApiService.getTopHeadlines();

      // Assert
      expect(articles.length, 2);
      expect(articles[0].title, 'Test Article 1');
      expect(articles[1].title, 'Test Article 2');
    });

    test('throws an exception if the http call completes with an error', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('{"status": "error", "message": "API limit reached"}', 429),
      );

      // Act & Assert
      expect(
        () => newsApiService.getTopHeadlines(),
        throwsException,
      );
    });
  });

  group('getNewsByCategory', () {
    final categoryNewsJson = '''
    {
      "status": "ok",
      "totalResults": 1,
      "articles": [
        {
          "source": {
            "id": "techcrunch",
            "name": "TechCrunch"
          },
          "author": "TechCrunch",
          "title": "Technology News",
          "description": "Latest in technology",
          "url": "https://techcrunch.com/news/tech-news",
          "urlToImage": "https://example.com/tech.jpg",
          "publishedAt": "2025-06-01T10:00:00Z",
          "content": "Technology news content"
        }
      ]
    }
    ''';

    test('returns articles for a specific category', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(categoryNewsJson, 200),
      );

      // Act
      final articles = await newsApiService.getNewsByCategory(category: 'technology');

      // Assert
      expect(articles.length, 1);
      expect(articles[0].title, 'Technology News');
    });
  });

  group('searchNews', () {
    final searchNewsJson = '''
    {
      "status": "ok",
      "totalResults": 1,
      "articles": [
        {
          "source": {
            "id": "the-verge",
            "name": "The Verge"
          },
          "author": "The Verge",
          "title": "Search Result",
          "description": "This is a search result",
          "url": "https://www.theverge.com/search-result",
          "urlToImage": "https://example.com/search.jpg",
          "publishedAt": "2025-06-01T09:00:00Z",
          "content": "Search result content"
        }
      ]
    }
    ''';

    test('returns articles matching the search query', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(searchNewsJson, 200),
      );

      // Act
      final articles = await newsApiService.searchNews(query: 'flutter');

      // Assert
      expect(articles.length, 1);
      expect(articles[0].title, 'Search Result');
    });
  });
}
