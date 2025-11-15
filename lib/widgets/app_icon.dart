import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Gradient? gradient;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = 80,
    this.iconSize = 28,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient:
            gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.backgroundColor],
            ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
