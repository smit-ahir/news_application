import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/article_model.dart';
import '../providers/bookmark_provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final isBookmarked = bookmarkProvider.isBookmarked(article);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.source?.name ?? 'Article Details'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.white : null,
            ),
            onPressed: () {
              bookmarkProvider.toggleBookmark(article);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality could be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            _buildImage(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title ?? 'No Title',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author and date
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.author ?? 'Unknown Author',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(article.publishedAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Content
                  Text(
                    article.content ?? article.description ?? 'No content available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Read more button
                  if (article.url != null && article.url!.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(context, article.url!),
                        icon: const Icon(Icons.launch),
                        label: const Text('Read Full Article'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: article.urlToImage!,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.error, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown date';
    }

    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat.yMMMMd().format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      // Make sure the URL is properly formatted
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      // Always use in-app web view for reading articles within the app
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (!launched) {
        throw Exception('Could not launch $formattedUrl');
      }
    } catch (e) {
      // Show a more user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the article in-app. Please try again later.')),
      );
      print('URL launch error: $e'); // Log the actual error for debugging
    }
  }
}
