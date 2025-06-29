import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  // Set smaller window properties for desktop
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700), // Smaller initial size
    minimumSize: Size(900, 600), // Smaller minimum size
    maximumSize: Size(1400, 1000), // Maximum size limit
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
    title: 'PharmaPOS - Pharmacy Point of Sale System',
    alwaysOnTop: false,
    fullScreen: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp( PharmaPOSApp());
}

class PharmaPOSApp extends StatelessWidget {
  const PharmaPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaPOS - Desktop',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      // Optimized scroll behavior for smaller screens
      scrollBehavior: const MaterialScrollBehavior().copyWith(

      ),
    );
  }
}