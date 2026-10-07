import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../core/theme/app_theme.dart';

/// Centered error message with an optional native retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is AppException
        ? (error as AppException).message
        : error.toString();
    final retryable =
        error is! AppException || (error as AppException).isRetryable;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (PlatformVersion.shouldUseNativeGlass)
              const CNIcon(
                symbol: CNSymbol('wifi.slash', size: 48),
                customIcon: Icons.cloud_off_outlined,
                size: 48,
                color: Color(0xFFE53935),
              )
            else
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Color(0xFFE53935),
              ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (retryable && onRetry != null) ...[
              const SizedBox(height: 24),
              if (PlatformVersion.shouldUseNativeGlass)
                CNButton(
                  label: 'Try again',
                  tint: AppColors.brand,
                  onPressed: onRetry,
                  config: const CNButtonConfig(
                    style: CNButtonStyle.filled,
                    shrinkWrap: true,
                    minHeight: 44,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              else
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                  ),
                  child: const Text('Try again'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty-state placeholder used by gallery and favorites.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.sfSymbol,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? sfSymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sfSymbol != null && PlatformVersion.shouldUseNativeGlass)
              CNIcon(
                symbol: CNSymbol(sfSymbol!, size: 48),
                customIcon: icon,
                size: 48,
                color: theme.colorScheme.outline,
              )
            else
              Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
