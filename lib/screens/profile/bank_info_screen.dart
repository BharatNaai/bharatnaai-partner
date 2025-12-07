import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:partner_app/core/constants/app_colors.dart';

import '../../widgets/common_button.dart';

class BankInfoScreen extends StatelessWidget {
  const BankInfoScreen({super.key});

  // TODO: replace this with real bank account data source
  bool get _hasBankAccount => true;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Bank Info',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.loginBackgroundStart,
              AppColors.loginBackgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight - 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Manage your payout bank account.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _hasBankAccount
                      ? _SavedBankAccountCard(textTheme: textTheme)
                      : const _EmptyBankAccountCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Your bank details are encrypted and used only for processing payouts.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CommonButton(
                      text: _hasBankAccount ? 'Edit Bank Account' : 'Add Bank Account',
                      width: double.infinity,
                      onPressed: () {
                        Navigator.pushNamed(context, '/bank/edit');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedBankAccountCard extends StatelessWidget {
  final TextTheme textTheme;

  const _SavedBankAccountCard({required this.textTheme});

  String _maskAccount(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    final last4 = accountNumber.substring(accountNumber.length - 4);
    return '•••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: pull real data instead of hard-coded sample
    const holder = 'Rahul Sharma';
    const bankName = 'State Bank of India';
    const accountNumber = '123456789012';
    const ifsc = 'SBIN000000';

    final fields = <_BankFieldConfig>[
      const _BankFieldConfig(label: 'Account Holder', value: holder),
      const _BankFieldConfig(label: 'Bank Name', value: bankName),
      _BankFieldConfig(label: 'Account Number', value: _maskAccount(accountNumber)),
      const _BankFieldConfig(label: 'IFSC Code', value: ifsc),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: Colors.white,
                  size: 22,
                ),
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
                            holder,
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tealGreen,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Primary',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bankName,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.loginSubtitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...fields.map((field) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        field.label,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.loginSubtitleText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field.value,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _EmptyBankAccountCard extends StatelessWidget {
  const _EmptyBankAccountCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: AppColors.loginBackgroundStart,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No bank account added yet',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your bank account to receive payouts directly to your account.',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
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

class _BankFieldConfig {
  final String label;
  final String value;

  const _BankFieldConfig({required this.label, required this.value});
}
