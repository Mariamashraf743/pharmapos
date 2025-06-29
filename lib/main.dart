import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  // Window settings
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720), // Default size
    minimumSize: Size(900, 600), // Optional
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
    title: 'PharmaPOS - Pharmacy Point of Sale System',
    fullScreen: false, // ✅ لا تبدأ بوضع ملء الشاشة
  );

  // Wait until the window is ready
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();       // ✅ يعرض النافذة بحجمها الطبيعي
    await windowManager.focus();      // يركز عليها
    // ❌ لا تجعلها fullscreen إجباريًا
  });

  runApp(const PharmaPOSApp());
}

class PharmaPOSApp extends StatelessWidget {
  const PharmaPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PharmaPOS',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
