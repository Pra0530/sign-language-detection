import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_gradients.dart';
import 'screens/home_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
    ),
  );
  runApp(const ISLTranslatorApp());
}

class ISLTranslatorApp extends StatelessWidget {
  const ISLTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'ISL Translator',
            debugShowCheckedModeBanner: false,
            theme: provider.isDarkMode
                ? AppTheme.darkTheme()
                : AppTheme.lightTheme(),
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isDark = provider.isDarkMode;

        final screens = const [
          HomeScreen(),
          TranslatorScreen(),
          LearningScreen(),
          AnalyticsScreen(),
          SettingsScreen(),
        ];

        return Scaffold(
          extendBody: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.darkBackground
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bgLight,
                        AppColors.bgLightTertiary,
                      ],
                    ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey(provider.currentIndex),
                child: screens[provider.currentIndex],
              ),
            ),
          ),
          bottomNavigationBar: GlassNavBar(
            currentIndex: provider.currentIndex,
            onTap: (index) => provider.setCurrentIndex(index),
          ),
        );
      },
    );
  }
}
