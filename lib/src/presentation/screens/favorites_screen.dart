import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/favorites_controller.dart';
import '../widgets/error_view.dart';
import '../widgets/gallery_grid.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesControllerProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorites',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.images.isEmpty
                    ? 'Images you love will appear here'
                    : '${state.images.length} saved photos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.images.isEmpty
              ? const EmptyView(
                  icon: Icons.favorite_border,
                  sfSymbol: 'heart',
                  title: 'No favorites yet',
                  subtitle: 'Tap the heart on any image to save it here.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GalleryGrid(
                      images: state.images,
                      crossAxisCount:
                          galleryCrossAxisCount(constraints.maxWidth),
                      hasMore: false,
                      onLoadMore: () {},
                    );
                  },
                ),
        ),
      ],
    );
  }
}
