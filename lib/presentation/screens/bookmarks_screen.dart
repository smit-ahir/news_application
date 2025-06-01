import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/article_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Articles'),
        actions: [
          if (bookmarkProvider.bookmarkedArticles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all bookmarks',
              onPressed: () {
                _showClearBookmarksDialog(context, bookmarkProvider);
              },
            ),
        ],
      ),
      body: _buildBookmarksList(context, bookmarkProvider),
    );
  }
  
  Widget _buildBookmarksList(BuildContext context, BookmarkProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (provider.bookmarkedArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookmarked Articles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Articles you bookmark will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: provider.bookmarkedArticles.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final article = provider.bookmarkedArticles[index];
        return Dismissible(
          key: Key(article.url ?? '$index'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            provider.removeBookmark(article);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Article removed from bookmarks'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    provider.toggleBookmark(article);
                  },
                ),
              ),
            );
          },
          child: ArticleCard(
            article: article,
            showBookmarkButton: false,
          ),
        );
      },
    );
  }
  
  void _showClearBookmarksDialog(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Bookmarks'),
        content: const Text('Are you sure you want to remove all bookmarked articles?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllBookmarks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All bookmarks cleared')),
              );
            },
            child: const Text('CLEAR'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
