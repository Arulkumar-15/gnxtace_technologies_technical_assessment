import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_vault/src/core/theme/app_theme.dart';
import 'package:pixel_vault/src/data/local/favorites_repository.dart';
import 'package:pixel_vault/src/data/local/settings_repository.dart';
import 'package:pixel_vault/src/data/models/pixabay_image.dart';
import 'package:pixel_vault/src/data/repositories/image_repository.dart';
import 'package:pixel_vault/src/presentation/providers/providers.dart';
import 'package:pixel_vault/src/presentation/screens/home_shell.dart';

class _MockRepo extends Mock implements ImageRepository {}

void main() {
  late _MockRepo repo;
  late Box<String> favoritesBox;
  late Box<String> settingsBox;

  setUpAll(() async {
    Hive.init('./.hive_test_widget');
  });

  setUp(() async {
    repo = _MockRepo();
    favoritesBox = await Hive.openBox<String>(
      'fav_${DateTime.now().microsecondsSinceEpoch}',
    );
    settingsBox = await Hive.openBox<String>(
      'set_${DateTime.now().microsecondsSinceEpoch}',
    );

    when(() => repo.fetchImages(
          page: any(named: 'page'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer(
      (_) async => ImagePage(
        images: [
          const PixabayImage(
            id: 1,
            pageUrl: '',
            tags: 'nature, forest',
            previewUrl: '',
            webformatUrl: 'https://cdn.example/1.jpg',
            largeImageUrl: 'https://cdn.example/1-lg.jpg',
            imageWidth: 400,
            imageHeight: 300,
            views: 10,
            downloads: 2,
            likes: 1,
            comments: 0,
            user: 'alice',
            userImageUrl: '',
          ),
        ],
        totalHits: 1,
      ),
    );
  });

  tearDown(() async {
    await favoritesBox.clear();
    await settingsBox.clear();
    await favoritesBox.close();
    await settingsBox.close();
  });

  testWidgets('HomeShell shows Explore mockup destinations', (tester) async {
    // CNButton Material fallback can report layout overflow in test surface;
    // ignore those so we can still assert structure.
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed') || text.contains('A RenderFlex')) {
        return;
      }
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageRepositoryProvider.overrideWithValue(repo),
          favoritesRepositoryProvider.overrideWithValue(
            FavoritesRepository(favoritesBox),
          ),
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(settingsBox),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeShell(),
        ),
      ),
    );

    await tester.pump();
    // Drain PlatformViewGuard timers from cupertino_native_better.
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Discover amazing photos from around the world'),
        findsOneWidget);
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
