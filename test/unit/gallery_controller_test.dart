import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_vault/src/core/app_exception.dart';
import 'package:pixel_vault/src/data/models/pixabay_image.dart';
import 'package:pixel_vault/src/data/repositories/image_repository.dart';
import 'package:pixel_vault/src/presentation/providers/gallery_controller.dart';

class _MockRepo extends Mock implements ImageRepository {}

PixabayImage _img(int id) => PixabayImage(
      id: id,
      pageUrl: '',
      tags: 'nature',
      previewUrl: '',
      webformatUrl: 'https://cdn.example/$id.jpg',
      largeImageUrl: 'https://cdn.example/$id-lg.jpg',
      imageWidth: 100,
      imageHeight: 100,
      views: 0,
      downloads: 0,
      likes: 0,
      comments: 0,
      user: 'u',
      userImageUrl: '',
    );

void main() {
  late _MockRepo repo;
  late GalleryController controller;

  setUp(() {
    repo = _MockRepo();
  });

  tearDown(() => controller.dispose());

  test('loadInitial populates images', () async {
    when(() => repo.fetchImages(
          page: any(named: 'page'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer(
      (_) async => ImagePage(images: [_img(1), _img(2)], totalHits: 2),
    );

    controller = GalleryController(repo);
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    expect(controller.state.images, hasLength(2));
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasMore, isFalse);
    expect(controller.state.error, isNull);
  });

  test('loadMore appends pages', () async {
    when(() => repo.fetchImages(
          page: 1,
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer(
      (_) async => ImagePage(images: [_img(1)], totalHits: 60),
    );
    when(() => repo.fetchImages(
          page: 2,
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer(
      (_) async => ImagePage(images: [_img(2)], totalHits: 60),
    );

    controller = GalleryController(repo);
    await pumpEventQueue();
    await controller.loadMore();

    expect(controller.state.images.map((i) => i.id), [1, 2]);
    expect(controller.state.page, 2);
  });

  test('search updates query and reloads', () async {
    when(() => repo.fetchImages(
          page: any(named: 'page'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer(
      (_) async => const ImagePage(images: [], totalHits: 0),
    );

    controller = GalleryController(repo);
    await pumpEventQueue();
    await controller.search('cats');

    verify(() => repo.fetchImages(page: 1, query: 'cats', category: null))
        .called(greaterThanOrEqualTo(1));
    expect(controller.state.query, 'cats');
  });

  test('maps AppException into state.error', () async {
    when(() => repo.fetchImages(
          page: any(named: 'page'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenThrow(const AppException('offline'));

    controller = GalleryController(repo);
    await pumpEventQueue();

    expect(controller.state.error?.message, 'offline');
    expect(controller.state.images, isEmpty);
  });
}
