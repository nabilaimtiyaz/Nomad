import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const display = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w900,
    color: AppColors.textPrimary, letterSpacing: -0.5);

  static const heading1 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const heading2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static const body = TextStyle(
    fontSize: 14, color: AppColors.textPrimary, height: 1.5);

  static const bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.5);

  static const bodySecondary = TextStyle(
    fontSize: 14, color: AppColors.textSecondary, height: 1.5);

  static const caption = TextStyle(
    fontSize: 12, color: AppColors.textSecondary);

  static const captionBold = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary);

  static const price = TextStyle(
    fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary);

  static const priceLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary);

  static const button = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: 0.3);

  static const label = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.8);
}
