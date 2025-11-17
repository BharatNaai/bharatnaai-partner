import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class UploadCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDoubleSlot; // For Aadhaar front/back layout
  final VoidCallback? onTapPrimary;
  final VoidCallback? onTapSecondary;
  final Widget? primaryPreview;
  final Widget? secondaryPreview;
  final bool isOptional;

  const UploadCard({
    super.key,
    required this.title,
    this.subtitle,
    this.isDoubleSlot = false,
    this.onTapPrimary,
    this.onTapSecondary,
    this.primaryPreview,
    this.secondaryPreview,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.loginInputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                size: 18,
                color: AppColors.loginTitleText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.loginTitleText,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.loginSubtitleText,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (isDoubleSlot)
            Row(
              children: [
                Expanded(child: _buildSlot(context, label: 'Front', onTap: onTapPrimary, preview: primaryPreview)),
                const SizedBox(width: 12),
                Expanded(child: _buildSlot(context, label: 'Back', onTap: onTapSecondary, preview: secondaryPreview)),
              ],
            )
          else
            _buildSlot(
              context,
              label: 'Tap to upload',
              onTap: onTapPrimary,
              preview: primaryPreview,
            ),
        ],
      ),
    );
  }

  Widget _buildSlot(
    BuildContext context, {
    required String label,
    VoidCallback? onTap,
    Widget? preview,
  }) {
    final hasPreview = preview != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.loginInputBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  hasPreview ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 18,
                  color: hasPreview
                      ? AppColors.successColor
                      : AppColors.loginInputPlaceholder,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.loginSubtitleText,
                  ),
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.loginInputBorder),
                color: hasPreview ? AppColors.veryLightBlue : Colors.white,
              ),
              child: hasPreview
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: preview,
                    )
                  : const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.loginInputPlaceholder,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
