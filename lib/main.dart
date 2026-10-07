import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/core/theme/app_theme.dart';
import 'src/data/local/favorites_repository.dart';
import 'src/data/local/settings_repository.dart';
import 'src/presentation/providers/theme_controller.dart';
import 'src/presentation/screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>(FavoritesRepository.boxName),
    Hive.openBox<String>(SettingsRepository.boxName),
  ]);

  runApp(const ProviderScope(child: PixelVaultApp()));
}

class PixelVaultApp extends ConsumerWidget {
  const PixelVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Pixel Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Coordinates Liquid Glass tab bar z-order with sheets/modals.
      navigatorObservers: [CNTabBarRouteObserver()],
      home: const HomeShell(),
    );
  }
}
