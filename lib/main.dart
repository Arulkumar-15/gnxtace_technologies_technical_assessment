import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/core/theme/app_theme.dart';
import 'src/data/local/favorites_repository.dart';
import 'src/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await Hive.initFlutter();
  await Hive.openBox<String>(FavoritesRepository.boxName);

  runApp(const ProviderScope(child: PixelVaultApp()));
}

class PixelVaultApp extends StatelessWidget {
  const PixelVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      // Coordinates Liquid Glass tab bar z-order with sheets/modals.
      navigatorObservers: [CNTabBarRouteObserver()],
      home: const SplashScreen(),
    );
  }
}
