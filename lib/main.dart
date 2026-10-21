import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dashboard_data.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard/dashboard_screen.dart';

class AppConstants {
  // Pagsanjan, Laguna (default farm coordinates)
  static const double defaultLat = 14.2717;
  static const double defaultLon = 121.4553;
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String timezone = 'Asia/Manila';

  /// Save your logo here and list it under `assets:` in pubspec.yaml
  static const String logoAsset = 'assets/images/pagri_logo.png';
}

/// Magaan na berde (light green) na tema ng PAGRI - malambot na "glass" na itsura.
/// Ang mga lumang pangalan (leaf, fern, mint, paddy, ink...) ay pinanatili para
/// hindi masira ang ibang screen - ang mga kulay lang ang nagbago.
class AppColors {
  // Background (gradient mula taas pababa)
  static const bg1 = Color(0xFFF1F9EE); // taas: napakaputlang berde
  static const bg0 = Color(0xFFD3E9C9); // baba: malambot na berde

  // Mga card
  static const surface = Color(0xFFF9FCF7); // dialog / sheet (hindi transparent)
  static const surfaceHi = Color(0xFFFFFFFF);
  static const glass = Color(0xB3FFFFFF); // card (70% puti)
  static const glassHi = Color(0xE6FFFFFF); // card (90% puti)
  static const glassBorder = Color(0xCCFFFFFF);
  static const navBg = Color(0xE6FFFFFF); // bottom navigation
  static const border = Color(0xFFCFE3C8); // manipis na guhit / divider

  // Accent
  static const leaf = Color(0xFF2E7D32); // malalim na berde - icon at highlight
  static const accentDark = Color(0xFF388E3C); // pindutan na may puting teksto
  static const fern = Color(0xFF4CAF50); // pangalawang berde
  static const lime = Color(0xFF8BC34A); // logo light green

  // Mga lumang pangalan
  static const mint = Color(0xFFE3F2DF); // panloob na kahon / tint
  static const paddy = Color(0xFFF1F9EE); // background
  static const soil = Color(0xFF8D6E63); // accent (kayumanggi)
  static const ink = Color(0xFF1B3A22); // pangunahing teksto (madilim na berde)
  static const muted = Color(0xFF5F7A66); // pangalawang teksto
  static const sun = Color(0xFFFFB300);
  static const rain = Color(0xFF1E88E5);

  // Pagtaas / pagbaba
  static const up = Color(0xFF2E7D32);
  static const down = Color(0xFFD32F2F);

  static Color forCrop(String crop) {
    switch (crop) {
      case 'Rice':
      case 'Palay':
        return const Color(0xFFC0A02B);
      case 'Eggplant':
      case 'Talong':
        return const Color(0xFF7B4FA3);
      case 'Tomato':
      case 'Kamatis':
        return const Color(0xFFE5533D);
      case 'String beans':
      case 'Sitaw':
        return const Color(0xFF2E9E5B);
      case 'Banana':
      case 'Saging':
        return const Color(0xFFE6A700);
      case 'Coconut':
      case 'Niyog':
        return const Color(0xFF8D6E63);
      case 'Ampalaya':
        return const Color(0xFF43A047);
      case 'Squash':
      case 'Kalabasa':
        return const Color(0xFFEF8F00);
      case 'Sweet potato':
      case 'Kamote':
        return const Color(0xFFB8567F);
      case 'Taro':
      case 'Gabi':
        return const Color(0xFF6A5FB5);
      case 'Calamansi':
        return const Color(0xFF8FA800);
      default:
        return fern;
    }
  }
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentDark,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.leaf,
      onPrimary: Colors.white,
      secondary: AppColors.fern,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg0,
      canvasColor: AppColors.surface,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navBg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.leaf.withValues(alpha: 0.14),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
          color: states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.muted,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          size: 26,
          color: states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.muted,
        )),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.leaf, textColor: AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.ink),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.leaf,
        linearTrackColor: AppColors.mint,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.leaf,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.leaf),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected) ? AppColors.accentDark : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.muted),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.mint,
        labelStyle: TextStyle(color: AppColors.ink),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mint,
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.leaf,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.leaf, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Shows the PAGRI logo; falls back to a leaf icon if the asset is missing.
class PagriLogo extends StatelessWidget {
  final double height;
  const PagriLogo({super.key, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.logoAsset,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => CircleAvatar(
        radius: height / 2,
        backgroundColor: AppColors.fern,
        child: Icon(Icons.eco, color: Colors.white, size: height * 0.6),
      ),
    );
  }
}

void main() => runApp(const PagriApp());

class PagriApp extends StatelessWidget {
  const PagriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()..start(),
      child: Consumer<DashboardProvider>(
        builder: (_, p, __) => MaterialApp(
          title: 'PAGRI - Pagsanjan Agriculture',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: Locale(p.isTagalog ? 'tl' : 'en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Laki ng teksto (Settings > Itsura ng App)
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(p.textScale)),
            child: child!,
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}