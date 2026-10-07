import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_vault/src/data/models/pixabay_image.dart';

void main() {
  group('PixabayImage', () {
    final sample = {
      'id': 42,
      'pageURL': 'https://pixabay.com/photos/42',
      'tags': 'cat, animal, pet',
      'previewURL': 'https://cdn.example/preview.jpg',
      'webformatURL': 'https://cdn.example/web.jpg',
      'largeImageURL': 'https://cdn.example/large.jpg',
      'imageWidth': 4000,
      'imageHeight': 3000,
      'views': 1000,
      'downloads': 200,
      'likes': 50,
      'comments': 3,
      'user': 'alice',
      'userImageURL': 'https://cdn.example/user.jpg',
    };

    test('fromJson parses all fields', () {
      final image = PixabayImage.fromJson(sample);
      expect(image.id, 42);
      expect(image.user, 'alice');
      expect(image.tagList, ['cat', 'animal', 'pet']);
      expect(image.aspectRatio, closeTo(4000 / 3000, 0.001));
    });

    test('description includes tags and author', () {
      final image = PixabayImage.fromJson(sample);
      expect(image.description, contains('cat, animal, pet'));
      expect(image.description, contains('alice'));
      expect(image.description, contains('4000 × 3000'));
    });

    test('toJson round-trips', () {
      final image = PixabayImage.fromJson(sample);
      final again = PixabayImage.fromJson(image.toJson());
      expect(again, image);
      expect(again.largeImageUrl, image.largeImageUrl);
    });

    test('equality is by id', () {
      final a = PixabayImage.fromJson(sample);
      final b = PixabayImage.fromJson({...sample, 'user': 'bob'});
      expect(a, equals(b));
    });

    test('ImagePage.fromJson parses hits', () {
      final page = ImagePage.fromJson({
        'totalHits': 100,
        'hits': [sample],
      });
      expect(page.totalHits, 100);
      expect(page.images, hasLength(1));
      expect(page.images.first.id, 42);
    });
  });
}
