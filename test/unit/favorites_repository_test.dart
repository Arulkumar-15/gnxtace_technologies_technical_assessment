import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pixel_vault/src/data/local/favorites_repository.dart';
import 'package:pixel_vault/src/data/models/pixabay_image.dart';

void main() {
  late Box<String> box;
  late FavoritesRepository repo;

  const image = PixabayImage(
    id: 7,
    pageUrl: 'https://pixabay.com/7',
    tags: 'dog',
    previewUrl: '',
    webformatUrl: 'https://cdn.example/7.jpg',
    largeImageUrl: 'https://cdn.example/7-lg.jpg',
    imageWidth: 800,
    imageHeight: 600,
    views: 10,
    downloads: 2,
    likes: 1,
    comments: 0,
    user: 'bob',
    userImageUrl: '',
  );

  setUp(() async {
    Hive.init('./.hive_test_favorites');
    box = await Hive.openBox<String>('favorites_test_${DateTime.now().microsecondsSinceEpoch}');
    repo = FavoritesRepository(box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  test('add / contains / remove', () async {
    expect(repo.contains(7), isFalse);

    await repo.add(image);
    expect(repo.contains(7), isTrue);
    expect(repo.loadAll().single.id, 7);
    expect(repo.loadAll().single.user, 'bob');

    await repo.remove(7);
    expect(repo.contains(7), isFalse);
    expect(repo.loadAll(), isEmpty);
  });
}
