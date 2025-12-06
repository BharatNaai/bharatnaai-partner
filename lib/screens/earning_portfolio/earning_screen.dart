import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/earnings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_button.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 16,
        title: Text(
          'Earnings',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const [
          Icon(Icons.calendar_today_outlined, color: AppColors.textPrimary),
          SizedBox(width: 16),
          Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
          SizedBox(width: 16),
        ],
      ),
      body: Consumer<EarningsProvider>(
        builder: (context, earnings, child) {
          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MainEarningsCard(todayAmount: earnings.todayEarnings),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryEarningCard(
                        icon: Icons.calendar_month_outlined,
                        label: 'Week',
                        amount: earnings.weekEarnings,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryEarningCard(
                        icon: Icons.calendar_view_month_outlined,
                        label: 'Month',
                        amount: earnings.monthEarnings,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryEarningCard(
                        icon: Icons.show_chart_rounded,
                        label: 'Total',
                        amountLabel: '₹2.4L',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _PayoutCard(
                  availableAmount: earnings.availableForPayout,
                  onWithdraw: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.payouts,
                      arguments: earnings.availableForPayout,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Recent Payouts',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: earnings.recentPayouts.map((payout) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _PayoutListItem(payout: payout),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainEarningsCard extends StatelessWidget {
  final int todayAmount;

  const _MainEarningsCard({required this.todayAmount});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182840),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Earnings",
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.loginSubtitleText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$todayAmount',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated live',
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
    );
  }
}

class _SummaryEarningCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? amount;
  final String? amountLabel;

  const _SummaryEarningCard({
    required this.icon,
    required this.label,
    this.amount,
    this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    final String displayAmount = amountLabel ?? '₹${amount ?? 0}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182840),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            displayAmount,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppColors.loginSubtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final int availableAmount;
  final VoidCallback onWithdraw;

  const _PayoutCard({
    required this.availableAmount,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tealGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available for Payout',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.loginSubtitleText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹$availableAmount',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonButton(
            text: 'Withdraw',
            height: 48,
            width: double.infinity,
            backgroundColor: AppColors.lightGreen,
            onPressed: availableAmount > 0 ? onWithdraw : null,
          ),
        ],
      ),
    );
  }
}

class _PayoutListItem extends StatelessWidget {
  final PayoutItem payout;

  const _PayoutListItem({required this.payout});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    Color statusColor;
    String statusLabel;
    switch (payout.status) {
      case PayoutStatus.success:
        statusColor = AppColors.successColor;
        statusLabel = 'Success';
        break;
      case PayoutStatus.pending:
        statusColor = AppColors.warningColor;
        statusLabel = 'Pending';
        break;
      case PayoutStatus.failed:
        statusColor = AppColors.errorColor;
        statusLabel = 'Failed';
        break;
    }

    final dateLabel = '${payout.date.day.toString().padLeft(2, '0')} '
        '${_monthShortName(payout.date.month)}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Placeholder for detailed transaction sheet/screen
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payout Details',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Amount: ₹${payout.amount}'),
                  Text('Date: $dateLabel'),
                  Text('Status: $statusLabel'),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10182840),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.loginBackgroundStart,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payout Sent',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${payout.amount}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthShortName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

