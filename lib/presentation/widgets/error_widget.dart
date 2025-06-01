import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForError(message),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _getUserFriendlyMessage(message),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForError(String message) {
    if (message.contains('No internet') || message.contains('Failed to connect')) {
      return Icons.wifi_off;
    } else if (message.contains('API limit') || message.contains('rate')) {
      return Icons.timer_off;
    } else if (message.contains('API key')) {
      return Icons.key_off;
    } else {
      return Icons.error_outline;
    }
  }

  String _getUserFriendlyMessage(String message) {
    if (message.contains('No internet')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (message.contains('API limit') || message.contains('rate')) {
      return 'API request limit reached. Please try again later.';
    } else if (message.contains('API key')) {
      return 'There\'s an issue with the API key. Please check your configuration.';
    } else if (message.contains('Empty')) {
      return 'No articles found. Try a different category or search term.';
    } else {
      return 'Something went wrong. Please try again later.\n\n$message';
    }
  }
}
