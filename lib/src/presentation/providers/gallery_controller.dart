import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_config.dart';
import '../../core/app_exception.dart';
import '../../data/models/pixabay_image.dart';
import '../../data/repositories/image_repository.dart';
import 'providers.dart';

/// Immutable snapshot of the gallery list + pagination status.
@immutable
class GalleryState {
  const GalleryState({
    this.images = const [],
    this.page = 0,
    this.query = '',
    this.category,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.totalHits = 0,
  });

  final List<PixabayImage> images;
  final int page;
  final String query;
  final String? category;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final AppException? error;
  final int totalHits;

  bool get isEmpty => images.isEmpty && !isLoading && error == null;

  GalleryState copyWith({
    List<PixabayImage>? images,
    int? page,
    String? query,
    String? category,
    bool clearCategory = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    AppException? error,
    bool clearError = false,
    int? totalHits,
  }) {
    return GalleryState(
      images: images ?? this.images,
      page: page ?? this.page,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      totalHits: totalHits ?? this.totalHits,
    );
  }
}

/// Loads and paginates Pixabay images with search + category filters.
class GalleryController extends StateNotifier<GalleryState> {
  GalleryController(
    this._repository, {
    bool autoLoad = true,
  }) : super(const GalleryState()) {
    if (autoLoad) {
      loadInitial();
    }
  }

  final ImageRepository _repository;

  /// Clears results and returns to an idle pre-search state.
  void clearSearch() {
    state = const GalleryState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      images: const [],
      page: 0,
      hasMore: true,
    );
    await _fetchPage(1, replace: true);
  }

  Future<void> refresh() async {
    // Keep current images visible while refreshing (pull-to-refresh).
    state = state.copyWith(clearError: true);
    await _fetchPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _fetchPage(state.page + 1, replace: false);
  }

  Future<void> search(String query) async {
    if (query.trim() == state.query) return;
    state = state.copyWith(query: query.trim());
    await loadInitial();
  }

  Future<void> setCategory(String? category) async {
    if (category == state.category) return;
    state = category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category);
    await loadInitial();
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    try {
      final result = await _repository.fetchImages(
        page: page,
        query: state.query,
        category: state.category,
      );

      final merged = replace
          ? result.images
          : [...state.images, ...result.images];

      // Pixabay only exposes the first 500 hits of any query.
      final reachable = result.totalHits.clamp(0, ApiConfig.maxAccessibleResults);
      final hasMore = merged.length < reachable && result.images.isNotEmpty;

      state = state.copyWith(
        images: merged,
        page: page,
        totalHits: result.totalHits,
        hasMore: hasMore,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: AppException(e.toString()),
      );
    }
  }
}

final galleryControllerProvider =
    StateNotifierProvider<GalleryController, GalleryState>(
  (ref) => GalleryController(ref.watch(imageRepositoryProvider)),
);

/// Search-tab gallery — idle until the user types/submits a query.
final searchControllerProvider =
    StateNotifierProvider<GalleryController, GalleryState>(
  (ref) => GalleryController(
        ref.watch(imageRepositoryProvider),
        autoLoad: false,
      ),
    );
