import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SyncListApp());
}

/// SyncList - Kontrol Listesi Uygulaması
///
/// Bu uygulama kullanıcıların günlük işlerini, alışveriş listelerini
/// ve seyahat planlarını organize etmelerini sağlar.
class SyncListApp extends StatelessWidget {
  const SyncListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulama başlığı
      title: 'SyncList',
      debugShowCheckedModeBanner: false,

      // Tema ayarları
      theme: ThemeData(
        // Renk şeması
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),

        // AppBar teması
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

        // Kart teması
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Floating Action Button teması
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 6,
        ),

        // Dialog teması
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Input dekorasyonu
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),

        // Elevated Button teması
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Snackbar teması
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // Material 3 kullan
        useMaterial3: true,
      ),

      // Koyu tema (opsiyonel)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Sistem temasını takip et
      themeMode: ThemeMode.system,

      // Ana sayfa
      home: const HomeScreen(),
    );
  }
}
