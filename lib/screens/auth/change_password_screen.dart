import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/routes/app_routes.dart';

import '../../widgets/app_icon.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _passwordStrengthLabel(String password) {
    if (password.length >= 10) return 'Strong';
    if (password.length >= 6) return 'Medium';
    if (password.isNotEmpty) return 'Weak';
    return '';
  }

  double _passwordStrengthValue(String password) {
    if (password.length >= 10) return 1.0;
    if (password.length >= 6) return 0.6;
    if (password.isNotEmpty) return 0.3;
    return 0.0;
  }

  Future<void> _handleResetPassword() async {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    bool isValid = true;

    if (password.isEmpty) {
      _passwordError = AppStrings.requiredField;
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = AppStrings.passwordTooShort;
      isValid = false;
    }

    if (confirm.isEmpty) {
      _confirmPasswordError = AppStrings.requiredField;
      isValid = false;
    } else if (confirm != password) {
      _confirmPasswordError = AppStrings.passwordsDoNotMatch;
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Integrate with real reset password API
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    AppRoutes.navigateToLogin(context);
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
                  const Center(child: AppIcon(icon: Icons.content_cut_rounded)),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Reset Your Password',
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
                      'Create a new password for your account.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.loginSubtitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  _buildStrengthIndicator(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),
                  Center(
                    child: CommonButton(
                      text: AppStrings.resetPassword,
                      onPressed: _isLoading ? null : _handleResetPassword,
                      isLoading: _isLoading,
                      width: double.infinity,
                      backgroundColor: AppColors.buttonPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => AppRoutes.navigateToLogin(context),
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

  Widget _buildPasswordField() {
    return CommonTextField(
      controller: _passwordController,
      labelText: 'New Password',
      keyboardType: TextInputType.text,
      prefixIcon: Icons.lock_outline,
      suffixIcon:
          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
      obscureText: _obscurePassword,
      errorText: _passwordError,
      validator: (_) => _passwordError,
    );
  }

  Widget _buildConfirmPasswordField() {
    return CommonTextField(
      controller: _confirmPasswordController,
      labelText: 'Confirm New Password',
      keyboardType: TextInputType.text,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureConfirmPassword
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      onSuffixTap:
          () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      obscureText: _obscureConfirmPassword,
      errorText: _confirmPasswordError,
      validator: (_) => _confirmPasswordError,
    );
  }

  Widget _buildStrengthIndicator() {
    final password = _passwordController.text;
    final strengthValue = _passwordStrengthValue(password);
    final strengthLabel = _passwordStrengthLabel(password);

    if (strengthLabel.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strengthValue,
          backgroundColor: AppColors.loginInputBorder,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.loginPrimaryPurple),
          minHeight: 3,
        ),
        const SizedBox(height: 4),
        Text(
          'Strength: $strengthLabel',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.loginSubtitleText,
          ),
        ),
      ],
    );
  }
}
