import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/favorites_repository.dart';
import '../../data/models/pixabay_image.dart';
import 'providers.dart';

@immutable
class FavoritesState {
  const FavoritesState({
    this.images = const [],
    this.ids = const {},
  });

  final List<PixabayImage> images;
  final Set<int> ids;

  bool contains(int id) => ids.contains(id);

  FavoritesState copyWith({
    List<PixabayImage>? images,
    Set<int>? ids,
  }) {
    return FavoritesState(
      images: images ?? this.images,
      ids: ids ?? this.ids,
    );
  }
}

class FavoritesController extends StateNotifier<FavoritesState> {
  FavoritesController(this._repository)
      : super(const FavoritesState()) {
    _reload();
  }

  final FavoritesRepository _repository;

  void _reload() {
    final images = _repository.loadAll();
    state = FavoritesState(
      images: images,
      ids: images.map((i) => i.id).toSet(),
    );
  }

  Future<void> toggle(PixabayImage image) async {
    if (_repository.contains(image.id)) {
      await _repository.remove(image.id);
    } else {
      await _repository.add(image);
    }
    _reload();
  }

  Future<void> remove(int id) async {
    await _repository.remove(id);
    _reload();
  }
}

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>(
  (ref) => FavoritesController(ref.watch(favoritesRepositoryProvider)),
);
