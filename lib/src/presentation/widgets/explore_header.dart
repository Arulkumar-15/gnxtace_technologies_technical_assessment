import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Large title + subtitle + notification / profile actions.
class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useNative = PlatformVersion.shouldUseNativeGlass;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover amazing photos from around the world',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (useNative)
                CNButton.icon(
                  icon: const CNSymbol('bell', size: 18),
                  customIcon: Icons.notifications_outlined,
                  onPressed: onNotificationTap,
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'explore-header',
                    width: 44,
                    minHeight: 44,
                  ),
                )
              else
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: onNotificationTap,
                  icon: const Icon(Icons.notifications_outlined),
                ),
              Positioned(
                right: useNative ? 6 : 10,
                top: useNative ? 6 : 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          if (useNative)
            CNButton.icon(
              icon: const CNSymbol('person.fill', size: 18),
              customIcon: Icons.person_rounded,
              onPressed: onProfileTap,
              tint: AppColors.brand,
              config: const CNButtonConfig(
                style: CNButtonStyle.glass,
                glassEffectUnionId: 'explore-header',
                width: 44,
                minHeight: 44,
              ),
            )
          else
            IconButton(
              tooltip: 'Profile',
              onPressed: onProfileTap,
              icon: const Icon(Icons.person_rounded, color: AppColors.brand),
            ),
        ],
      ),
    );
  }
}

/// Search field + filter button.
class ExploreSearchRow extends StatelessWidget {
  const ExploreSearchRow({
    super.key,
    required this.onSubmitted,
    this.onChanged,
    this.onFilterTap,
    this.placeholder = 'Search photos, people, topics...',
    this.compact = false,
  });

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String placeholder;

  /// Tighter layout when the Explore title is collapsed on scroll.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? Colors.white12 : AppColors.surfaceMuted;
    final useNative = PlatformVersion.shouldUseNativeGlass;
    final fieldHeight = compact ? 44.0 : 48.0;
    final filterSize = compact ? 44.0 : 48.0;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: fieldHeight,
            child: useNative
                ? CNSearchBar(
                    placeholder: placeholder,
                    expandable: false,
                    initiallyExpanded: true,
                    showCancelButton: false,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    tint: AppColors.brand,
                  )
                : TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSubmitted,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: fill,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        if (useNative)
          CNButton.icon(
            icon: const CNSymbol('line.3.horizontal.decrease.circle', size: 20),
            customIcon: Icons.tune_rounded,
            onPressed: onFilterTap,
            config: CNButtonConfig(
              style: CNButtonStyle.glass,
              width: filterSize,
              minHeight: filterSize,
            ),
          )
        else
          Material(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: filterSize,
                height: filterSize,
                child: const Icon(Icons.tune_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
      ],
    );
  }
}
