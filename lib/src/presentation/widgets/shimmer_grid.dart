import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder masonry grid shown while the first page loads.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key, required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: 12,
      itemBuilder: (context, index) => ShimmerTile(index: index),
    );
  }
}

/// Single shimmer cell for use inside [SliverMasonryGrid] (no nested scrollables).
class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key, required this.index});

  final int index;

  static const _heights = [180.0, 240.0, 200.0, 260.0, 160.0, 220.0];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: Container(
        height: _heights[index % _heights.length],
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
