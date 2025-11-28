import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';

class WithdrawScreen extends StatelessWidget {
  final int availableAmount;

  const WithdrawScreen({super.key, required this.availableAmount});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 16,
        title: Text(
          'Withdraw',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available balance',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.loginSubtitleText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹$availableAmount',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            CommonButton(
              text: 'Confirm Withdraw',
              height: 50,
              width: double.infinity,
              onPressed: availableAmount > 0
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
