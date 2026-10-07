import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One chip in the horizontal category strip.
class CategoryOption {
  const CategoryOption({
    required this.label,
    required this.icon,
    required this.accent,
    this.value,
  });

  /// Pixabay `category` value, or null for "All".
  final String? value;
  final String label;
  final IconData icon;
  final Color accent;
}

/// Curated chips matching the Explore mockup.
const List<CategoryOption> kExploreCategories = [
  CategoryOption(
    label: 'All',
    icon: Icons.grid_view_rounded,
    accent: AppColors.brand,
  ),
  CategoryOption(
    label: 'Backgrounds',
    value: 'backgrounds',
    icon: Icons.image_outlined,
    accent: Color(0xFFFFA726),
  ),
  CategoryOption(
    label: 'Nature',
    value: 'nature',
    icon: Icons.eco_rounded,
    accent: Color(0xFF4CAF50),
  ),
  CategoryOption(
    label: 'People',
    value: 'people',
    icon: Icons.person_rounded,
    accent: Color(0xFF42A5F5),
  ),
  CategoryOption(
    label: 'Animals',
    value: 'animals',
    icon: Icons.pets_rounded,
    accent: Color(0xFFAB47BC),
  ),
  CategoryOption(
    label: 'Food',
    value: 'food',
    icon: Icons.restaurant_rounded,
    accent: Color(0xFFFF7043),
  ),
  CategoryOption(
    label: 'Travel',
    value: 'travel',
    icon: Icons.flight_rounded,
    accent: Color(0xFF26A69A),
  ),
  CategoryOption(
    label: 'Sports',
    value: 'sports',
    icon: Icons.sports_soccer_rounded,
    accent: Color(0xFF5C6BC0),
  ),
];

/// Horizontally scrolling category chips (single-line, intrinsic width).
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: kExploreCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = kExploreCategories[index];
          final isSelected = selected == option.value;
          return _CategoryChip(
            option: option,
            selected: isSelected,
            onTap: () => onSelected(option.value),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.brand
        : (isDark ? Colors.white12 : AppColors.surfaceMuted);
    final fg = selected
        ? Colors.white
        : (isDark ? Colors.white70 : const Color(0xFF2C2F36));
    final iconColor = selected ? Colors.white : option.accent;

    final pill = Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                option.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Soft glass shell on iOS 26+ for unselected chips only (selected stays solid brand).
    if (!selected && PlatformVersion.supportsLiquidGlass) {
      return LiquidGlassContainer(
        config: const LiquidGlassConfig(
          effect: CNGlassEffect.regular,
          shape: CNGlassEffectShape.capsule,
        ),
        child: pill,
      );
    }

    return pill;
  }
}
