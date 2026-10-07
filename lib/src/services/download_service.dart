import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_exception.dart';
import '../data/models/pixabay_image.dart';

/// Progress callback: [received] / [total] bytes. [total] may be -1 if unknown.
typedef DownloadProgress = void Function(int received, int total);

/// Downloads images to the device gallery and supports sharing.
class DownloadService {
  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Saves [image] to the device photo library with optional progress.
  Future<void> saveToGallery(
    PixabayImage image, {
    DownloadProgress? onProgress,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw const AppException(
            'Photo library permission denied. Enable it in Settings to save images.',
            isRetryable: false,
          );
        }
      }

      final bytes = await _downloadBytes(image.largeImageUrl, onProgress);
      await Gal.putImageBytes(bytes, name: 'pixel_vault_${image.id}');
    } on AppException {
      rethrow;
    } on GalException catch (e) {
      throw AppException(_galMessage(e.type), isRetryable: false);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    } catch (e) {
      throw AppException('Failed to save image: $e');
    }
  }

  /// Shares the image URL (and optional subject) via the platform share sheet.
  Future<void> share(PixabayImage image) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '${image.description}\n\n${image.pageUrl}',
        subject: 'Image by ${image.user} on Pixabay',
      ),
    );
  }

  /// Shares the actual image file after downloading it to a temp directory.
  Future<void> shareFile(
    PixabayImage image, {
    DownloadProgress? onProgress,
  }) async {
    try {
      final bytes = await _downloadBytes(image.largeImageUrl, onProgress);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pixel_vault_${image.id}.jpg');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: image.description,
          subject: 'Image by ${image.user}',
        ),
      );
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Uint8List> _downloadBytes(
    String url,
    DownloadProgress? onProgress,
  ) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw const AppException('Downloaded image was empty.');
    }
    return Uint8List.fromList(data);
  }

  String _galMessage(GalExceptionType type) => switch (type) {
        GalExceptionType.accessDenied =>
          'Photo library access denied. Enable it in Settings.',
        GalExceptionType.notEnoughSpace =>
          'Not enough storage space to save the image.',
        GalExceptionType.notSupportedFormat =>
          'This image format is not supported by the photo library.',
        GalExceptionType.unexpected =>
          'Could not save the image. Please try again.',
      };
}
