import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerArticleCard extends StatelessWidget {
  const ShimmerArticleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                      Container(
                        width: 80,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  
                  // Description placeholder
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 200,
                    height: 10,
                    color: Colors.white,
                  ),
                  
                  // Bookmark button placeholder
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.white,
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
}
