import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/error_widget.dart';
import '../widgets/shimmer_article_card.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Fetch top headlines when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchTopHeadlines();
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.status != LoadingStatus.loading && newsProvider.hasMoreData) {
        if (newsProvider.currentCategory == 'general') {
          newsProvider.fetchTopHeadlines();
        } else {
          newsProvider.fetchNewsByCategory(newsProvider.currentCategory);
        }
      }
    }
  }
  
  void _onRefresh() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    if (newsProvider.currentCategory == 'general') {
      await newsProvider.fetchTopHeadlines(refresh: true);
    } else {
      await newsProvider.fetchNewsByCategory(newsProvider.currentCategory, refresh: true);
    }
    _refreshController.refreshCompleted();
  }
  
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          // Bookmarks button
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
          // Theme toggle button
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          const CategorySelector(),
          
          // Articles list
          Expanded(
            child: _buildArticlesList(newsProvider),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArticlesList(NewsProvider newsProvider) {
    switch (newsProvider.status) {
      case LoadingStatus.initial:
      case LoadingStatus.loading:
        if (newsProvider.articles.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerArticleCard(),
          );
        }
        return _buildArticlesListView(newsProvider, showLoading: true);
        
      case LoadingStatus.loaded:
        if (newsProvider.articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No articles found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different category',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return _buildArticlesListView(newsProvider);
        
      case LoadingStatus.error:
        return CustomErrorWidget(
          message: newsProvider.errorMessage,
          onRetry: () {
            if (newsProvider.currentCategory == 'general') {
              newsProvider.fetchTopHeadlines(refresh: true);
            } else {
              newsProvider.fetchNewsByCategory(newsProvider.currentCategory, refresh: true);
            }
          },
        );
    }
  }
  
  Widget _buildArticlesListView(NewsProvider newsProvider, {bool showLoading = false}) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: const WaterDropHeader(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: newsProvider.articles.length + (showLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < newsProvider.articles.length) {
            return ArticleCard(article: newsProvider.articles[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
