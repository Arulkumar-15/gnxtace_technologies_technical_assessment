import 'dart:async';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/gallery_controller.dart';
import '../widgets/error_view.dart';
import '../widgets/gallery_grid.dart';
import '../widgets/shimmer_grid.dart';

/// Search tab: focuses the keyboard on open, waits for input before showing
/// results, and animates in when the tab becomes active.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.isActive = false});

  final bool isActive;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  Timer? _debounce;
  late final AnimationController _appear;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _appear, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _appear, curve: Curves.easeOutCubic));

    _textController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.isActive) {
      _appear.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _activate());
    }
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _appear.forward(from: 0);
      _activate();
    } else if (!widget.isActive && oldWidget.isActive) {
      _deactivate();
    }
  }

  void _activate() {
    _focusNode.requestFocus();
  }

  void _deactivate() {
    _debounce?.cancel();
    _focusNode.unfocus();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    final controller = ref.read(searchControllerProvider.notifier);

    if (trimmed.isEmpty) {
      controller.clearSearch();
      return;
    }

    // Wait for typing to settle before fetching; hide results until then.
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || trimmed.length < 2) return;
      controller.search(trimmed);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    final controller = ref.read(searchControllerProvider.notifier);
    if (trimmed.isEmpty) {
      controller.clearSearch();
      return;
    }
    controller.search(trimmed);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _appear.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? Colors.white12 : AppColors.surfaceMuted;
    final hasQuery = state.query.isNotEmpty;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Search',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 48,
                child: PlatformVersion.shouldUseNativeGlass
                    ? CNSearchBar(
                        placeholder: 'Search photos, people, topics...',
                        expandable: false,
                        initiallyExpanded: true,
                        autofocus: widget.isActive,
                        showCancelButton: false,
                        tint: AppColors.brand,
                        onChanged: _onQueryChanged,
                        onSubmitted: _onSubmitted,
                      )
                    : TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        onChanged: _onQueryChanged,
                        onSubmitted: _onSubmitted,
                        decoration: InputDecoration(
                          hintText: 'Search photos, people, topics...',
                          hintStyle:
                              const TextStyle(color: AppColors.textMuted),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear',
                                  onPressed: () {
                                    _textController.clear();
                                    _onQueryChanged('');
                                    _focusNode.requestFocus();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                          filled: true,
                          fillColor: fill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(child: _buildResults(state, controller, hasQuery)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    GalleryState state,
    GalleryController controller,
    bool hasQuery,
  ) {
    if (!hasQuery) {
      return const EmptyView(
        icon: Icons.search_rounded,
        title: 'Search Pixel Vault',
        subtitle: 'Start typing to find photos, people, and topics.',
        sfSymbol: 'magnifyingglass',
      );
    }

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
            subtitle: 'Try a different search.',
            sfSymbol: 'photo.on.rectangle.angled',
          );
        }

        return GalleryGrid(
          images: state.images,
          crossAxisCount: columns,
          isLoadingMore: state.isLoadingMore,
          hasMore: state.hasMore,
          onLoadMore: controller.loadMore,
        );
      },
    );
  }
}
