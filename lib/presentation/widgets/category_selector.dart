import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final currentCategory = newsProvider.currentCategory;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: newsProvider.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = newsProvider.categories[index];
          final isSelected = category == currentCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getCategoryDisplayName(category),
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  if (category == 'general') {
                    newsProvider.fetchTopHeadlines(refresh: true);
                  } else {
                    newsProvider.fetchNewsByCategory(category, refresh: true);
                  }
                }
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'general':
        return 'Top Headlines';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
