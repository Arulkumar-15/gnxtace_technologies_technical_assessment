import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
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
  /// Fresh key each time the native bar is allowed to mount (avoids stale
  /// UiKitView + Flutter fallback stacking after hot restart).
  Key _tabBarKey = UniqueKey();

  DateTime? _lastBackAt;

  int get _index => ref.watch(shellTabIndexProvider);

  void _setIndex(int i) {
    _lastBackAt = null;
    ref.read(shellTabIndexProvider.notifier).state = i;
  }

  void _openProfile() => _setIndex(3);

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

  Future<void> _handleRootBack() async {
    // Only dismiss the soft keyboard — don't treat random focus as "back used".
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardOpen) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    final tab = ref.read(shellTabIndexProvider);

    // Other tabs → Explore. Never re-navigate when already on Explore.
    if (tab != 0) {
      _setIndex(0);
      return;
    }

    // Explore: double-back within 2s exits via SystemNavigator (do NOT pop the
    // root route — that leaves a black screen instead of closing the app).
    final now = DateTime.now();
    if (_lastBackAt != null &&
        now.difference(_lastBackAt!) < const Duration(seconds: 2)) {
      _lastBackAt = null;
      await SystemNavigator.pop();
      return;
    }

    _lastBackAt = now;
    if (!mounted) return;
    // Use ScaffoldMessenger — CNToast overlays can interfere with back handling.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final index = _index;

    final pages = [
      for (var i = 0; i < 4; i++)
        HeroMode(
          enabled: index == i,
          child: switch (i) {
            0 => GalleryScreen(onOpenProfile: _openProfile),
            1 => SearchScreen(isActive: index == 1),
            2 => const FavoritesScreen(),
            _ => const ProfileScreen(),
          },
        ),
    ];

    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        // Always false on the root route. Exit with SystemNavigator.pop().
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleRootBack();
        },
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: _useNativeTabs,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: IndexedStack(index: index, children: pages),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _useNativeTabs
                    ? _buildAppleTabBar(index)
                    : IgnorePointer(
                        ignoring: keyboardOpen,
                        child: AnimatedOpacity(
                          opacity: keyboardOpen ? 0 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: AndroidFloatingTabBar(
                            currentIndex: index,
                            onTap: _setIndex,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleTabBar(int index) {
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
      currentIndex: index,
      onTap: _setIndex,
      tint: AppColors.brand,
    );
  }
}
