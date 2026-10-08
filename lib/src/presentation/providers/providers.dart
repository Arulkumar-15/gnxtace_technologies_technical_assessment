import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/favorites_repository.dart';
import '../../data/repositories/image_repository.dart';
import '../../services/download_service.dart';

final imageRepositoryProvider = Provider<ImageRepository>(
    (ref) => PixabayImageRepository(),
);

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => DownloadService(),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final box = Hive.box<String>(FavoritesRepository.boxName);
  return FavoritesRepository(box);
});

/// Bottom-tab index for [HomeShell]. Detail routes can reset this to Explore (0).
final shellTabIndexProvider = StateProvider<int>((ref) => 0);
