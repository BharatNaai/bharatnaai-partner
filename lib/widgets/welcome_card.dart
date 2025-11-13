import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';

class WelcomeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const WelcomeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder (since assets might not exist yet)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if image doesn't exist
                return const Icon(
                  Icons.image,
                  size: 80,
                  color: AppColors.textGrey,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
