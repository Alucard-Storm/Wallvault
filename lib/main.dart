import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallpaper_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/downloads_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_navigation.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WallVaultApp());
}

class WallVaultApp extends StatelessWidget {
  const WallVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => DownloadsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          // Load settings asynchronously if not loaded
          if (!settings.isLoaded) {
            Future.microtask(() => settings.loadSettings());
          }
          
          // Use default colors if settings not loaded yet
          final primaryColor = settings.isLoaded ? settings.primaryColor : AppConstants.primaryColor;
          final accentColor = settings.isLoaded ? settings.accentColor : AppConstants.accentColor;
          final isDark = settings.isLoaded ? settings.isDarkTheme : true;
          
          return MaterialApp(
            key: ValueKey('${settings.isLoaded ? settings.themeColor : "default"}_$isDark'),
            title: 'WallVault',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            
            // Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                secondary: accentColor,
                surface: AppConstants.surfaceColor,
              ),
              scaffoldBackgroundColor: AppConstants.backgroundColor,
              cardTheme: const CardThemeData(
                color: AppConstants.cardColor,
                elevation: 4,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppConstants.surfaceColor,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: AppConstants.surfaceColor,
                indicatorColor: primaryColor.withValues(alpha: 0.3),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppConstants.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            
            // Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                secondary: accentColor,
                surface: Colors.grey[100]!,
              ),
              scaffoldBackgroundColor: Colors.grey[50],
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: primaryColor.withValues(alpha: 0.2),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
