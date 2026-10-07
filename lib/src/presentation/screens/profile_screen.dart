import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/favorites_controller.dart';
import '../providers/theme_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _themeModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final favoritesCount =
        ref.watch(favoritesControllerProvider).images.length;
    final theme = Theme.of(context);
    final selectedIndex = _themeModes.indexOf(themeMode).clamp(0, 2);
    final useNative = PlatformVersion.shouldUseNativeGlass;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.brand,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              if (useNative)
                const CNIcon(
                  symbol: CNSymbol('person.crop.circle.fill', size: 72),
                  customIcon: Icons.person_rounded,
                  size: 72,
                  color: AppColors.brand,
                )
              else
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.brandSoft,
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppColors.brand,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Pixel Vault Guest',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$favoritesCount favorites saved',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Appearance',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (useNative)
          CNSegmentedControl(
            labels: const ['System', 'Light', 'Dark'],
            selectedIndex: selectedIndex,
            color: AppColors.brand,
            height: 36,
            onValueChanged: (index) {
              ref
                  .read(themeControllerProvider.notifier)
                  .setThemeMode(_themeModes[index]);
            },
          )
        else
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (value) {
              ref
                  .read(themeControllerProvider.notifier)
                  .setThemeMode(value.first);
            },
          ),
        const SizedBox(height: 28),
        Text(
          'About',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.surfaceMuted,
          child: ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.brand),
            title: const Text('Pixel Vault'),
            subtitle: const Text('Photos powered by Pixabay'),
          ),
        ),
      ],
    );
  }
}
