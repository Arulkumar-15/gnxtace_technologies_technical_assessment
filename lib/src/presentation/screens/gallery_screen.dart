import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/gallery_controller.dart';
import '../widgets/app_toast.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/explore_header.dart';
import '../widgets/gallery_grid.dart';
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

  /// 0 = fully expanded (title visible), 1 = collapsed (search at top).
  double _collapse = 0;
  bool _showBackToTop = false;

  static const _collapseRange = 72.0;
  static const _backToTopThreshold = 420.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final nextCollapse = widget.showHeader
        ? (offset / _collapseRange).clamp(0.0, 1.0)
        : 0.0;
    final nextBackToTop = offset > _backToTopThreshold;

    final collapseChanged = (nextCollapse - _collapse).abs() > 0.015 ||
        nextCollapse == 0 ||
        nextCollapse == 1;
    final backChanged = nextBackToTop != _showBackToTop;

    if (collapseChanged || backChanged) {
      setState(() {
        if (collapseChanged) _collapse = nextCollapse;
        if (backChanged) _showBackToTop = nextBackToTop;
      });
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
    final collapsed = _collapse > 0.85;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showHeader)
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - _collapse,
                  child: Opacity(
                    opacity: (1 - _collapse).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: _collapse > 0.6,
                      child: ExploreHeader(
                        onNotificationTap: () {
                          AppToast.info(context, 'No new notifications');
                        },
                        onProfileTap: widget.onOpenProfile,
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.showSearchRow)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.fromLTRB(
                  20,
                  4 + (1 - _collapse) * 8,
                  20,
                  4 + (1 - _collapse) * 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: collapsed
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ExploreSearchRow(
                  compact: collapsed,
                  onSubmitted: controller.search,
                  onFilterTap: () => _showFilterSheet(state, controller),
                ),
              ),
            if (widget.showCategories) ...[
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: widget.showHeader ? (1 - _collapse * 0.35) : 1,
                  child: Opacity(
                    opacity: widget.showHeader
                        ? (1 - _collapse * 0.5).clamp(0.35, 1.0)
                        : 1,
                    child: CategoryChips(
                      selected: state.category,
                      onSelected: controller.setCategory,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(child: _buildBody(state, controller)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 110,
          child: IgnorePointer(
            ignoring: !_showBackToTop,
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
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Top',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  Widget _buildBody(GalleryState state, GalleryController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = galleryCrossAxisCount(constraints.maxWidth);

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
      },
    );
  }
}
