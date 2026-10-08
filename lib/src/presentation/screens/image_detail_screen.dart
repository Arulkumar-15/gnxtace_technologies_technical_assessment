import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pixabay_image.dart';
import '../providers/favorites_controller.dart';
import '../providers/providers.dart';
import '../widgets/app_toast.dart';

/// Pops to the root shell and selects the Explore tab.
void _navigateHome(WidgetRef ref, BuildContext context) {
  ref.read(shellTabIndexProvider.notifier).state = 0;
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.popUntil((route) => route.isFirst);
  }
}

class ImageDetailScreen extends ConsumerStatefulWidget {
  const ImageDetailScreen({super.key, required this.image});

  final PixabayImage image;

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  bool _downloading = false;
  double? _progress;
  bool _showAllTags = false;

  PixabayImage get image => widget.image;

  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      await ref.read(downloadServiceProvider).saveToGallery(
        image,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _progress = total > 0 ? received / total : null;
          });
        },
      );
      if (!mounted) return;
      AppToast.success(context, 'Saved to photo library');
    } on AppException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _share() async {
    try {
      await ref.read(downloadServiceProvider).share(image);
    } on AppException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    }
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        // Avoid Hero flights — detail already owns `image-${id}`.
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullscreenImage(
              image: image,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.contains(image.id);
    final topPad = MediaQuery.paddingOf(context).top;
    final tags = image.tagList;
    final visibleTags = _showAllTags ? tags : tags.take(12).toList();

    return PopScope(
      // Let the system back gesture complete, then route to Explore.
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        ref.read(shellTabIndexProvider.notifier).state = 0;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Photo plane — tap opens fullscreen
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openFullscreen,
                child: Hero(
                  tag: 'image-${image.id}',
                  child: CachedNetworkImage(
                    imageUrl: image.largeImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: 1400,
                    placeholder: (context, url) => CachedNetworkImage(
                      imageUrl: image.webformatUrl,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: Color(0xFF1A1A1A),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top chrome
            Positioned(
              top: topPad + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _GlassCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => _navigateHome(ref, context),
                  ),
                const Spacer(),
                _GlassCircleButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFavorite ? const Color(0xFFFF5252) : Colors.white,
                  onTap: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .toggle(image),
                ),
                const SizedBox(width: 10),
                _GlassCircleButton(
                  icon: Icons.ios_share_rounded,
                  onTap: _share,
                ),
              ],
            ),
          ),

          // Info sheet
          DraggableScrollableSheet(
            initialChildSize: 0.52,
            minChildSize: 0.48,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8D8D8),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Author row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.brandSoft,
                                backgroundImage: image.userImageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        image.userImageUrl,
                                      )
                                    : null,
                                child: image.userImageUrl.isEmpty
                                    ? Text(
                                        image.user.isNotEmpty
                                            ? image.user[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.brand,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      image.user,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatDim(image.imageWidth)} × '
                                      '${_formatDim(image.imageHeight)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppToast.info(
                                    context,
                                    'Follow ${image.user} on Pixabay',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.brandSoft,
                                  foregroundColor: AppColors.brand,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                child: const Text('Follow'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            image.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Color(0xFF6B7280),
                            ),
                          ),

                          const SizedBox(height: 22),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Tags',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                              if (tags.length > 12)
                                TextButton(
                                  onPressed: () => setState(
                                    () => _showAllTags = !_showAllTags,
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.surfaceMuted,
                                    foregroundColor: const Color(0xFF4B5563),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: Text(
                                    _showAllTags ? 'Show less' : 'View all >',
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag in visibleTags)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF374151),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Bottom actions
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_downloading) ...[
                              LinearProgressIndicator(
                                value: _progress,
                                color: AppColors.brand,
                                backgroundColor: AppColors.brandSoft,
                              ),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _SecondaryAction(
                                    icon: isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    label: isFavorite
                                        ? 'Favorited'
                                        : 'Add to Favorites',
                                    iconColor: isFavorite
                                        ? const Color(0xFFFF5252)
                                        : null,
                                    onTap: () => ref
                                        .read(
                                          favoritesControllerProvider.notifier,
                                        )
                                        .toggle(image),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: _SecondaryAction(
                                    icon: Icons.ios_share_rounded,
                                    label: 'Share',
                                    onTap: _share,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: _PrimaryDownload(
                                    busy: _downloading,
                                    onTap: _downloading ? null : _download,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  String _formatDim(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor ?? const Color(0xFF111111)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
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

class _PrimaryDownload extends StatelessWidget {
  const _PrimaryDownload({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.download_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                busy ? 'Saving…' : 'Download',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.image, required this.onClose});

  final PixabayImage image;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: image.largeImageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            child: _GlassCircleButton(
              icon: Icons.close_rounded,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
