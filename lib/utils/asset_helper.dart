import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetHelper {
  // Image asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String logoSmallPath = 'assets/images/logo_small.png';
  static const String splashLogoPath = 'assets/images/splash_logo.png';
  static const String pharmacyIconPath = 'assets/images/pharmacy_icon.png';
  static const String medicineIconPath = 'assets/images/medicine_icon.png';
  static const String receiptIconPath = 'assets/images/receipt_icon.png';

  // Check if asset exists and return appropriate widget
  static Widget getLogoWidget({
    double size = 64,
    Color? fallbackColor,
  }) {
    return FutureBuilder<bool>(
      future: _assetExists(logoPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.asset(
            logoPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _getFallbackIcon(Icons.local_pharmacy, size, fallbackColor);
            },
          );
        }
        return _getFallbackIcon(Icons.local_pharmacy, size, fallbackColor);
      },
    );
  }

  static Widget getSplashLogoWidget({
    double size = 120,
    Color? fallbackColor,
  }) {
    return FutureBuilder<bool>(
      future: _assetExists(splashLogoPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.asset(
            splashLogoPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _getFallbackIcon(Icons.local_pharmacy, size, fallbackColor);
            },
          );
        }
        return _getFallbackIcon(Icons.local_pharmacy, size, fallbackColor);
      },
    );
  }

  static Widget _getFallbackIcon(IconData icon, double size, Color? color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? const Color(0xFF14B8A6),
            (color ?? const Color(0xFF14B8A6)).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFF14B8A6)).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }

  static Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }
}