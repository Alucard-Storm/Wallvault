import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
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
          
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              // Use Material You colors if available AND user wants them
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;
              
              if (settings.useSystemColors && lightDynamic != null && darkDynamic != null) {
                // Material You colors available and enabled
                lightColorScheme = lightDynamic.harmonized();
                darkColorScheme = darkDynamic.harmonized();
              } else {
                // Use custom preset colors
                lightColorScheme = ColorScheme.light(
                  primary: primaryColor,
                  secondary: accentColor,
                  surface: Colors.grey[100]!,
                );
                darkColorScheme = ColorScheme.dark(
                  primary: primaryColor,
                  secondary: accentColor,
                  surface: AppConstants.surfaceColor,
                );
              }
              
              return MaterialApp(
                key: ValueKey('${settings.isLoaded ? settings.themeColor : "default"}_$isDark'),
                title: 'WallVault',
                debugShowCheckedModeBanner: false,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                
                // Dark Theme
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorScheme: darkColorScheme,
                  scaffoldBackgroundColor: AppConstants.backgroundColor,
                  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
                  cardTheme: CardThemeData(
                    color: AppConstants.cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppConstants.surfaceColor,
                    elevation: 0,
                    centerTitle: true,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: AppConstants.surfaceColor,
                    elevation: 8,
                    height: 70,
                    labelTextStyle: WidgetStateProperty.all(
                      GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppConstants.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                  colorScheme: lightColorScheme,
                  scaffoldBackgroundColor: Colors.grey[50],
                  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
                  cardTheme: CardThemeData(
                    color: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    centerTitle: true,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: Colors.white,
                    elevation: 8,
                    height: 70,
                    labelTextStyle: WidgetStateProperty.all(
                      GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
          );
        },
      ),
    );
  }
}
