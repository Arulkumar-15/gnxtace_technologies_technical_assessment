import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/theme/app_theme.dart';
import '../providers/gallery_controller.dart';
import '../widgets/app_toast.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/explore_header.dart';
import '../widgets/gallery_grid.dart';
import '../widgets/image_tile.dart';
import '../widgets/shimmer_grid.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    super.key,
    this.onOpenProfile,
    this.showHeader = true,
    this.showSearchRow = true,
    this.showCategories = true,
  });

  final VoidCallback? onOpenProfile;
  final bool showHeader;
  final bool showSearchRow;
  final bool showCategories;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;

  static const _backToTopThreshold = 420.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final next = _scrollController.offset > _backToTopThreshold;
    if (next != _showBackToTop) {
      setState(() => _showBackToTop = next);
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet(GalleryState state, GalleryController controller) {
    CNBottomSheet.show(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                CategoryChips(
                  selected: state.category,
                  onSelected: (value) {
                    controller.setCategory(value);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryControllerProvider);
    final controller = ref.read(galleryControllerProvider.notifier);
    final useCollapsingChrome = widget.showHeader && widget.showSearchRow;
    // Clear floating tab bar: safe inset + pad(12) + pill(~60) + gap.
    final backToTopBottom = MediaQuery.paddingOf(context).bottom + 100;

    return Stack(
      children: [
        useCollapsingChrome
            ? _buildCollapsingExplore(state, controller)
            : _buildSimpleColumn(state, controller),
        Positioned(
          left: 0,
          right: 0,
          bottom: backToTopBottom,
          child: IgnorePointer(
            ignoring: !_showBackToTop,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedScale(
                scale: _showBackToTop ? 1 : 0.6,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showBackToTop ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: AppColors.brand,
                    elevation: 4,
                    shadowColor: AppColors.brand.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _scrollToTop,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Explore: title + categories scroll away; search sticks to the top.
  Widget _buildCollapsingExplore(
    GalleryState state,
    GalleryController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = galleryCrossAxisCount(constraints.maxWidth);
        final bg = Theme.of(context).scaffoldBackgroundColor;

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 400) {
                controller.loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ExploreHeader(
                    onNotificationTap: () {
                      AppToast.info(context, 'No new notifications');
                    },
                    onProfileTap: widget.onOpenProfile,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedSearchHeader(
                    background: bg,
                    onSubmitted: controller.search,
                    onFilterTap: () => _showFilterSheet(state, controller),
                  ),
                ),
                if (widget.showCategories)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CategoryChips(
                        selected: state.category,
                        onSelected: controller.setCategory,
                      ),
                    ),
                  ),
                ..._buildResultSlivers(state, controller, columns),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleColumn(
    GalleryState state,
    GalleryController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSearchRow)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: ExploreSearchRow(
              onSubmitted: controller.search,
              onFilterTap: () => _showFilterSheet(state, controller),
            ),
          ),
        if (widget.showCategories) ...[
          CategoryChips(
            selected: state.category,
            onSelected: controller.setCategory,
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = galleryCrossAxisCount(constraints.maxWidth);
              return _buildBody(state, controller, columns);
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildResultSlivers(
    GalleryState state,
    GalleryController controller,
    int columns,
  ) {
    // Never nest a scrollable (e.g. ShimmerGrid/MasonryGridView) inside
    // SliverFillRemaining — it asks for intrinsic height and crashes.
    if (state.isLoading && state.images.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childCount: 12,
            itemBuilder: (context, index) =>
                ShimmerTile(index: index),
          ),
        ),
      ];
    }

    if (state.error != null && state.images.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            error: state.error!,
            onRetry: controller.loadInitial,
          ),
        ),
      ];
    }

    if (state.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.image_search_outlined,
            title: 'No images found',
            subtitle: 'Try a different search or category.',
          ),
        ),
      ];
    }

    final itemCount =
        state.images.length + (state.hasMore || state.isLoadingMore ? 1 : 0);

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= state.images.length) {
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
            return ImageTile(image: state.images[index]);
          },
        ),
      ),
    ];
  }

  Widget _buildBody(
    GalleryState state,
    GalleryController controller,
    int columns,
  ) {
    if (state.isLoading && state.images.isEmpty) {
      return ShimmerGrid(crossAxisCount: columns);
    }

    if (state.error != null && state.images.isEmpty) {
      return ErrorView(
        error: state.error!,
        onRetry: controller.loadInitial,
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        icon: Icons.image_search_outlined,
        title: 'No images found',
        subtitle: 'Try a different search or category.',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: GalleryGrid(
        controller: _scrollController,
        images: state.images,
        crossAxisCount: columns,
        isLoadingMore: state.isLoadingMore,
        hasMore: state.hasMore,
        onLoadMore: controller.loadMore,
      ),
    );
  }
}

class _PinnedSearchHeader extends SliverPersistentHeaderDelegate {
  _PinnedSearchHeader({
    required this.background,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  final Color background;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  // Padding 8 + search row 48 + padding 8. Must equal painted child height.
  static const double _extent = 64;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final elevated = shrinkOffset > 0.5 || overlapsContent;
    return SizedBox(
      height: _extent,
      child: Material(
        color: background,
        elevation: elevated ? 2 : 0,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: ExploreSearchRow(
            onSubmitted: onSubmitted,
            onFilterTap: onFilterTap,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeader oldDelegate) {
    return background != oldDelegate.background ||
        onSubmitted != oldDelegate.onSubmitted ||
        onFilterTap != oldDelegate.onFilterTap;
  }
}
