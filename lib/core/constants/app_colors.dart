import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────
  static const primary      = Color(0xFFB8001F);  // Merah tua khas Nomad
  static const primaryDark  = Color(0xFF8B0015);
  static const primaryLight = Color(0xFFD4213A);

  static const teal         = Color(0xFF1A6B5A);
  static const tealMedium   = Color(0xFF00897B);
  static const tealLight    = Color(0xFFE0F2F0);

  static const background   = Color(0xFFFAF8F5); // krem hangat
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceGrey  = Color(0xFFF5F3F0);
  static const dark         = Color(0xFF1A1A1A);
  static const darkCard     = Color(0xFF2A2A2A);

  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textHint      = Color(0xFFAAAAAA);

  static const success = Color(0xFF1A6B5A);
  static const error   = Color(0xFFB8001F);
  static const warning = Color(0xFFFF9800);
  static const info    = Color(0xFF1976D2);

  static const bronze   = Color(0xFFCD7F32);
  static const silver   = Color(0xFF9E9E9E);
  static const gold     = Color(0xFFFFB300);
  static const platinum = Color(0xFF1A6B5A);

  static const divider    = Color(0xFFEEEBE6);
  static const cardBorder = Color(0xFFE8E4DE);

  // Header & AppBar utama
  static const gradientHeader = LinearGradient(
    colors: [Color(0xFF8B0015), Color(0xFFB8001F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Queue card: merah gelap → teal gelap (sesuai referensi UI halaman 1)
  static const gradientQueue = LinearGradient(
    colors: [Color(0xFF6B1A0F), Color(0xFF1A6B5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Loyalty header: merah → teal
  static const gradientLoyalty = LinearGradient(
    colors: [Color(0xFFB8001F), Color(0xFF1A6B5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Membership card per tier
  static LinearGradient tierGradient(String tier) {
    switch (tier) {
      case 'platinum':
        return const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00897B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'gold':
        return const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'silver':
        return const LinearGradient(
          colors: [Color(0xFF607D8B), Color(0xFFB0BEC5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      default: // bronze
        return const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFCD7F32)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  // Helper warna solid per tier
  static Color tierColor(String tier) {
    switch (tier) {
      case 'platinum': return platinum;
      case 'gold':     return gold;
      case 'silver':   return silver;
      default:         return bronze;
    }
  }
}
