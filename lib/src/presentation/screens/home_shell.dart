import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/android_floating_tab_bar.dart';
import 'favorites_screen.dart';
import 'gallery_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Root shell: iOS Liquid Glass tabs on Apple, floating pill bar on Android.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// Fresh key each time the native bar is allowed to mount (avoids stale
  /// UiKitView + Flutter fallback stacking after hot restart).
  Key _tabBarKey = UniqueKey();

  void _openProfile() => setState(() => _index = 3);

  bool get _useNativeTabs =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get _nativeGlassReady =>
      PlatformVersion.shouldUseNativeGlass && PlatformViewGuard.isReady;

  @override
  void initState() {
    super.initState();
    if (_useNativeTabs && PlatformVersion.shouldUseNativeGlass) {
      PlatformViewGuard.ensureScheduled();
      PlatformViewGuard.readyNotifier.addListener(_onPlatformViewsReady);
    }
  }

  void _onPlatformViewsReady() {
    if (!mounted) return;
    setState(() => _tabBarKey = UniqueKey());
  }

  @override
  void dispose() {
    PlatformViewGuard.readyNotifier.removeListener(_onPlatformViewsReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only the visible tab may register Heroes — IndexedStack keeps all tabs
    // mounted, so identical image tags would otherwise collide on navigation.
    final pages = [
      for (var i = 0; i < 4; i++)
        HeroMode(
          enabled: _index == i,
          child: switch (i) {
            0 => GalleryScreen(onOpenProfile: _openProfile),
            1 => SearchScreen(isActive: _index == 1),
            2 => const FavoritesScreen(),
            _ => const ProfileScreen(),
          },
        ),
    ];

    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      extendBody: true,
      // Android: keep floating tabs off the keyboard. iOS: allow inset normally.
      resizeToAvoidBottomInset: _useNativeTabs,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: IndexedStack(index: _index, children: pages),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _useNativeTabs
                ? _buildAppleTabBar()
                : IgnorePointer(
                    ignoring: keyboardOpen,
                    child: AnimatedOpacity(
                      opacity: keyboardOpen ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: AndroidFloatingTabBar(
                        currentIndex: _index,
                        onTap: (i) => setState(() => _index = i),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleTabBar() {
    // During the debug hot-restart guard window, skip mounting CNTabBar so we
    // don't flash CupertinoTabBar under a leftover native Liquid Glass bar.
    if (PlatformVersion.shouldUseNativeGlass && !_nativeGlassReady) {
      PlatformViewGuard.ensureScheduled();
      return const SizedBox(height: 50);
    }

    return CNTabBar(
      key: _tabBarKey,
      items: const [
        CNTabBarItem(
          label: 'Explore',
          icon: CNSymbol('square.grid.2x2'),
          activeIcon: CNSymbol('square.grid.2x2.fill'),
          customIcon: Icons.grid_view_outlined,
          activeCustomIcon: Icons.grid_view_rounded,
        ),
        CNTabBarItem(
          label: 'Search',
          icon: CNSymbol('magnifyingglass'),
          customIcon: Icons.search_outlined,
          activeCustomIcon: Icons.search_rounded,
        ),
        CNTabBarItem(
          label: 'Favorites',
          icon: CNSymbol('heart'),
          activeIcon: CNSymbol('heart.fill'),
          customIcon: Icons.favorite_border,
          activeCustomIcon: Icons.favorite_rounded,
        ),
        CNTabBarItem(
          label: 'Profile',
          icon: CNSymbol('person'),
          activeIcon: CNSymbol('person.fill'),
          customIcon: Icons.person_outline,
          activeCustomIcon: Icons.person_rounded,
        ),
      ],
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      tint: AppColors.brand,
    );
  }
}
