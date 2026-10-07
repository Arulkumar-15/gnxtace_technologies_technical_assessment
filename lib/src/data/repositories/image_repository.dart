import 'package:dio/dio.dart';

import '../../core/api_config.dart';
import '../../core/app_exception.dart';
import '../models/pixabay_image.dart';

/// Abstraction over the remote image source so controllers and tests
/// never depend on HTTP details.
abstract interface class ImageRepository {
  /// Fetches one page of images. [page] is 1-based.
  Future<ImagePage> fetchImages({
    required int page,
    String query = '',
    String? category,
  });
}

/// Pixabay-backed implementation of [ImageRepository].
class PixabayImageRepository implements ImageRepository {
  PixabayImageRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;

  @override
  Future<ImagePage> fetchImages({
    required int page,
    String query = '',
    String? category,
  }) async {
    if (!ApiConfig.hasApiKey) {
      throw const MissingApiKeyException();
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '',
        queryParameters: {
          'key': ApiConfig.apiKey,
          'image_type': 'photo',
          'safesearch': 'true',
          'page': page,
          'per_page': ApiConfig.perPage,
          if (query.trim().isNotEmpty) 'q': query.trim(),
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const AppException('Empty response from Pixabay.');
      }
      return ImagePage.fromJson(data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
