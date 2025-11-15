import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;
  final bool isEnabled;
  final String disableText;
  final IconData? icon; // Added icon parameter

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.isLoading = false,
    this.isEnabled = true,
    this.disableText = "",
    this.icon, // Added icon parameter
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading || !isEnabled;

    return SizedBox(
      width: width ?? MediaQuery.sizeOf(context).width * 0.9,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? (disabledBackgroundColor ?? AppColors.borderGrey)
              : (backgroundColor ?? AppColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor ?? AppColors.white),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      disableText.isNotEmpty ? disableText : "Verifying...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: textColor ?? AppColors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: isDisabled
                          ? (disabledTextColor ?? AppColors.textGrey)
                          : (textColor ?? AppColors.white),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: isDisabled
                            ? (disabledTextColor ?? AppColors.textGrey)
                            : (textColor ?? AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
