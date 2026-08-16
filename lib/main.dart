import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'localization/app_strings.dart';
import 'services/app_controller.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const DigitalHabitGardenApp());
}

class DigitalHabitGardenApp extends StatefulWidget {
  const DigitalHabitGardenApp({super.key});

  @override
  State<DigitalHabitGardenApp> createState() => _DigitalHabitGardenAppState();
}

class _DigitalHabitGardenAppState extends State<DigitalHabitGardenApp> {
  final AppController _appController = AppController.instance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    await _appController.loadSettings();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AnimatedBuilder(
      animation: _appController,
      builder: (context, child) {
        final strings = AppStrings(_appController.locale);

        final isArabic = _appController.locale.languageCode == 'ar';

        return AppStringsScope(
          strings: strings,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'Digital Habit Garden',

            // ==================================================
            // THEMES
            // ==================================================
            theme: AppTheme.lightTheme,

            darkTheme: AppTheme.darkTheme,

            themeMode: _appController.themeMode,

            // ==================================================
            // LANGUAGE
            // ==================================================
            locale: _appController.locale,

            supportedLocales: const [Locale('en'), Locale('ar')],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ==================================================
            // RTL / LTR
            // ==================================================
            builder: (context, child) {
              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },

            // ==================================================
            // HOME
            // ==================================================
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
