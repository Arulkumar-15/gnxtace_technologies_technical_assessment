import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/pixabay_image.dart';

/// Persists favorited images in a Hive box as JSON strings keyed by image id,
/// so favorites render with full metadata even without re-fetching the API.
class FavoritesRepository {
  FavoritesRepository(this._box);

  static const String boxName = 'favorites';

  final Box<String> _box;

  List<PixabayImage> loadAll() {
    final images = _box.values
        .map((raw) =>
            PixabayImage.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
    // Newest favorite first (Hive preserves insertion order).
    return images.reversed.toList();
  }

  bool contains(int id) => _box.containsKey(id.toString());

  Future<void> add(PixabayImage image) =>
      _box.put(image.id.toString(), jsonEncode(image.toJson()));

  Future<void> remove(int id) => _box.delete(id.toString());
}
