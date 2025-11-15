import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/providers/auth_provider.dart';
import 'package:partner_app/routes/app_routes.dart';

import '../../widgets/app_icon.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/common_button.dart';
import '../../widgets/divider_or.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();


  String? _phoneError;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length >= 8 && digitsOnly.length <= 15;
  }

  Future<void> _handleSendOtp() async {
    setState(() {
      _phoneError = null;
    });

    final trimmed = _phoneController.text.trim();
    bool isValid = true;

    if (trimmed.isEmpty) {
      _phoneError = AppStrings.requiredField;
      isValid = false;
    } else if (!_isValidPhone(trimmed)) {
      _phoneError = AppStrings.invalidPhone;
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.forgotPassword(trimmed);

      if (!mounted) return;

      if (success) {
        Navigator.pushNamed(context, AppRoutes.otpVerification);
      } else {
        setState(() {
          _isLoading = false;
        });
        final message = authProvider.errorMessage ?? 'Failed to send OTP';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),

                  const SizedBox(height: 32),

                  Center(child: const AppIcon(icon: Icons.content_cut_rounded)),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      AppStrings.forgotPassword,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.loginTitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppStrings.forgotPasswordSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.loginSubtitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CommonTextField(
                    controller: _phoneController,
                    labelText: AppStrings.phoneNumber,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    errorText: _phoneError,
                    validator: (_) => _phoneError,
                  ),

                  const SizedBox(height: 16),

                  const DividerOr(text: "OR"),

                  const SizedBox(height: 16),

                  CommonTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.phone_outlined,
                    errorText: _phoneError,
                    validator: (_) => _phoneError,
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: CommonButton(
                      text: AppStrings.sendOtp,
                      onPressed: _isLoading ? null : _handleSendOtp,
                      isLoading: _isLoading,
                      width: double.infinity,
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      child: Text(
                        AppStrings.backToLogin,
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
