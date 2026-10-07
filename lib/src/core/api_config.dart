import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for the Pixabay REST API.
///
/// The API key is loaded from `.env` (see `.env.example`).
/// Optionally override at build time via `--dart-define=PIXABAY_API_KEY=...`.
/// Get a free key at https://pixabay.com/api/docs/ (requires a free account).
abstract final class ApiConfig {
  static const String baseUrl = 'https://pixabay.com/api/';

  static const String _dartDefineKey =
      String.fromEnvironment('PIXABAY_API_KEY');

  /// Prefer compile-time `--dart-define`, then fall back to `.env`.
  static String get apiKey {
    if (_dartDefineKey.isNotEmpty) return _dartDefineKey;
    return dotenv.maybeGet('PIXABAY_API_KEY')?.trim() ?? '';
  }

  /// Pixabay caps `per_page` at 200; 30 keeps pages light.
  static const int perPage = 30;

  /// Pixabay only exposes the first 500 results of any query.
  static const int maxAccessibleResults = 500;

  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Categories supported by the Pixabay `category` parameter.
  static const List<String> categories = [
    'backgrounds',
    'nature',
    'people',
    'animals',
    'food',
    'travel',
    'places',
    'buildings',
    'science',
    'education',
    'health',
    'sports',
    'transportation',
    'computer',
    'business',
    'music',
    'fashion',
    'feelings',
    'industry',
    'religion',
  ];
}
