import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/providers/profile_setup_provider.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';

class ProfileSetupStep2Screen extends StatefulWidget {
  const ProfileSetupStep2Screen({super.key});

  @override
  State<ProfileSetupStep2Screen> createState() => _ProfileSetupStep2ScreenState();
}

class _ProfileSetupStep2ScreenState extends State<ProfileSetupStep2Screen> {
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _ifscController = TextEditingController(text: 'SBIN000000');

  bool get _isFormValid =>
      _accountHolderController.text.trim().isNotEmpty &&
      _bankNameController.text.trim().isNotEmpty &&
      _accountNumberController.text.trim().isNotEmpty &&
      _confirmAccountNumberController.text.trim().isNotEmpty &&
      _confirmAccountNumberController.text.trim() ==
          _accountNumberController.text.trim() &&
      _ifscController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _openBankPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final banks = [
          'State Bank of India',
          'HDFC Bank',
          'ICICI Bank',
          'Axis Bank',
        ];
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final bank = banks[index];
              return ListTile(
                title: Text(
                  bank,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.loginTitleText,
                  ),
                ),
                onTap: () {
                  _bankNameController.text = bank;
                  Navigator.pop(context);
                  setState(() {});
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: banks.length,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
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
              constraints: BoxConstraints(minHeight: screenHeight - 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          // Skip bank setup - save empty/null values and move to documents step
                          context.read<ProfileSetupProvider>().saveStep2Data();
                          Navigator.pushNamed(context, AppRoutes.profileStep3);
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Setup – Step 2',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.loginTitleText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          Color(0xFFE4D9FF),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter your bank details to receive payouts.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: _accountHolderController,
                    labelText: 'Account Holder Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _openBankPicker,
                    child: AbsorbPointer(
                      child: CommonTextField(
                        controller: _bankNameController,
                        labelText: 'Bank Name',
                        prefixIcon: Icons.account_balance_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: _accountNumberController,
                    labelText: 'Account Number',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: _confirmAccountNumberController,
                    labelText: 'Confirm Account Number',
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _ifscController,
                          labelText: 'IFSC Code',
                          prefixIcon: Icons.numbers_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          // TODO: Auto-fetch bank details via IFSC
                        },
                        child: Text(
                          'Auto-Fetch Details',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_clock_outlined,
                        size: 16,
                        color: AppColors.loginSubtitleText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your bank details are safe & encrypted.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.loginSubtitleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CommonButton(
                      text: 'Next →',
                      onPressed: _isFormValid
                          ? () {
                              // Save Step 2 data to provider
                              context.read<ProfileSetupProvider>().saveStep2Data(
                                accountHolderName: _accountHolderController.text.trim(),
                                bankName: _bankNameController.text.trim(),
                                accountNumber: _accountNumberController.text.trim(),
                                ifscCode: _ifscController.text.trim(),
                              );
                              Navigator.pushNamed(context, AppRoutes.profileStep3);
                            }
                          : null,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Back to previous step
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Back',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
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
