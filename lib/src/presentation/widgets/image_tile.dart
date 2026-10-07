import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pixabay_image.dart';
import '../providers/favorites_controller.dart';
import '../screens/image_detail_screen.dart';

/// Masonry tile with rounded corners and a tappable favorite overlay.
class ImageTile extends ConsumerWidget {
  const ImageTile({super.key, required this.image});

  final PixabayImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoritesControllerProvider).contains(image.id);
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageDetailScreen(image: image),
        ),
      ),
      child: Hero(
        tag: 'image-${image.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              AspectRatio(
                aspectRatio: image.aspectRatio,
                child: CachedNetworkImage(
                  imageUrl: image.webformatUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (context, url) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: scheme.errorContainer,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => ref
                        .read(favoritesControllerProvider.notifier)
                        .toggle(image),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite
                            ? const Color(0xFFFF5252)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
