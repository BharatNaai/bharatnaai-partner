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
  final String? primaryFileName; // Added
  final String? secondaryFileName; // Added
  final VoidCallback? onRemovePrimary; // Added
  final VoidCallback? onRemoveSecondary; // Added
  final VoidCallback? onViewPrimary; // Added
  final VoidCallback? onViewSecondary; // Added
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
    this.primaryFileName,
    this.secondaryFileName,
    this.onRemovePrimary,
    this.onRemoveSecondary,
    this.onViewPrimary,
    this.onViewSecondary,
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
                Expanded(
                  child: _buildSlot(
                    context,
                    label: primaryFileName ?? 'Front',
                    onTap: onTapPrimary,
                    preview: primaryPreview,
                    onRemove: onRemovePrimary,
                    onView: onViewPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSlot(
                    context,
                    label: secondaryFileName ?? 'Back',
                    onTap: onTapSecondary,
                    preview: secondaryPreview,
                    onRemove: onRemoveSecondary,
                    onView: onViewSecondary,
                  ),
                ),
              ],
            )
          else
            _buildSlot(
              context,
              label: primaryFileName ?? 'Tap to upload',
              onTap: onTapPrimary,
              preview: primaryPreview,
              onRemove: onRemovePrimary,
              onView: onViewPrimary,
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
    VoidCallback? onRemove,
    VoidCallback? onView,
  }) {
    final hasPreview = preview != null;

    return GestureDetector(
      onTap: hasPreview ? null : onTap, // If uploaded, tap doesn't trigger pick again directly on the slot
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.loginInputBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    hasPreview ? Icons.check_circle : Icons.cloud_upload_outlined,
                    size: 18,
                    color: hasPreview ? AppColors.successColor : AppColors.loginInputPlaceholder,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.loginSubtitleText,
                        fontWeight: hasPreview ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (hasPreview && onRemove != null)
                    GestureDetector(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (hasPreview)
              TextButton(
                onPressed: onView,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.loginInputBorder),
                  color: Colors.white,
                ),
                child: const Icon(
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
