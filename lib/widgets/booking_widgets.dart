import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/booking.dart';
import 'common_button.dart';

class BookingStatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const BookingStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory BookingStatusChip.fromBooking(Booking booking) {
    switch (booking.actionStatus) {
      case BookingActionStatus.newRequest:
        return const BookingStatusChip(
          label: 'New',
          backgroundColor: Color(0xFFE3F2FD),
          textColor: AppColors.primaryColor,
        );
      case BookingActionStatus.confirmed:
        return const BookingStatusChip(
          label: 'Confirmed',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: AppColors.successColor,
        );
      case BookingActionStatus.pending:
        return const BookingStatusChip(
          label: 'Pending',
          backgroundColor: Color(0xFFFFF3E0),
          textColor: AppColors.warningColor,
        );
      case BookingActionStatus.rejected:
        return const BookingStatusChip(
          label: 'Rejected',
          backgroundColor: Color(0xFFFFEBEE),
          textColor: AppColors.errorColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class BookingPillTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const BookingPillTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: isSelected ? 1.03 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      AppColors.loginPrimaryPurple,
                      AppColors.primaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : Colors.white.withOpacity(0.9),
            boxShadow: [
              if (isSelected)
                const BoxShadow(
                  color: Color(0x33185785),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                  spreadRadius: 1,
                )
              else
                const BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textGrey,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Container(
                  height: 3,
                  width: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BookingFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const BookingFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.loginPrimaryPurple,
                    AppColors.primaryBlue,
                  ],
                )
              : null,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x22185785),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isSelected
                ? Colors.white.withOpacity(0.95)
                : AppColors.loginBackgroundEnd.withOpacity(0.9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    isSelected ? AppColors.primaryBlue : AppColors.textGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.loginSubtitleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPhoneTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onPrimaryAction,
    this.onSecondaryAction,
    required this.primaryLabel,
    this.secondaryLabel,
    this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightGreyBackground,
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10182840),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.loginBackgroundStart,
                  backgroundImage:
                      booking.avatarUrl.isNotEmpty ? NetworkImage(booking.avatarUrl) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.customerName,
                              style: textTheme.titleSmall?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          BookingStatusChip.fromBooking(booking),
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: onPhoneTap,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.phone_in_talk_outlined,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceName,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.loginSubtitleText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            booking.priceDisplay,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${booking.durationMinutes} mins',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: AppColors.loginSubtitleText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        booking.timeDisplay,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (booking.mainStatus == BookingMainStatus.upcoming)
                        BookingStatusChip.fromBooking(booking),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.locationLabel,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.locationDetail,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.loginSubtitleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: primaryLabel,
                    height: 44,
                    onPressed: onPrimaryAction,
                  ),
                ),
                if (secondaryLabel != null && onSecondaryAction != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: secondaryLabel!,
                      height: 44,
                      backgroundColor: Colors.white,
                      textColor: AppColors.textSecondary,
                      onPressed: onSecondaryAction,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
