import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/favorites_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesCount =
        ref.watch(favoritesControllerProvider).images.length;
    final theme = Theme.of(context);
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
