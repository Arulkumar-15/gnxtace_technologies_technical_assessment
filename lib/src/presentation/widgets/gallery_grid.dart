import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/pixabay_image.dart';
import 'image_tile.dart';

/// Responsive masonry grid that triggers [onLoadMore] near the bottom.
class GalleryGrid extends StatelessWidget {
  const GalleryGrid({
    super.key,
    required this.images,
    required this.crossAxisCount,
    required this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.controller,
  });

  final List<PixabayImage> images;
  final int crossAxisCount;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final itemCount = images.length + (hasMore || isLoadingMore ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 400) {
          onLoadMore();
        }
        return false;
      },
      child: MasonryGridView.count(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= images.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }
          return ImageTile(image: images[index]);
        },
      ),
    );
  }
}

/// Picks a column count based on available width.
int galleryCrossAxisCount(double width) {
  if (width >= 1200) return 5;
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}
