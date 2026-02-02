import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/providers/auth_provider.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/utils/validation_utils.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final _firstNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _firstNameController.text.trim(),
      _phoneNumberController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.welcomeSuccess);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Name Field
                CommonTextField(
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  labelText: AppStrings.name,
                  semanticLabel: "Enter your name, required",
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),

                const SizedBox(height: 16),

                // Phone Number Field
                CommonTextField(
                  controller: _phoneNumberController,
                  focusNode: _phoneFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                  labelText: AppStrings.phoneNumber,
                  semanticLabel: "Enter your phone number, required",
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),

                const SizedBox(height: 16),

                // Email Field
                CommonTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                  labelText: AppStrings.email,
                  semanticLabel: "Enter your email address, required",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (!ValidationUtils.isValidEmail(value)) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                CommonTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                  labelText: AppStrings.password,
                  semanticLabel: "Enter a password",
                  prefixIcon: Icons.lock_outlined,

                  // password visibility toggle
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  suffixTooltip: _obscurePassword ? "Show password" : "Hide password",

                  // validator
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    final errors = ValidationUtils.getPasswordErrors(value);
                    if (errors.isNotEmpty) {
                      return errors.first;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                CommonTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                     // Since handleRegister doesn't take args, we just call it.
                     // But ideally we might want to close keyboard.
                     _handleRegister();
                  },
                  labelText: AppStrings.confirmPassword,
                  semanticLabel: "Confirm your password, required",
                  prefixIcon: Icons.lock_outlined,

                  // visibility toggle
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  suffixTooltip: _obscureConfirmPassword ? "Show password" : "Hide password",

                  // validator
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CommonButton(
                      text: AppStrings.register,
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      isLoading: authProvider.isLoading,
                      width: double.infinity,
                      height: 56,
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                      disabledBackgroundColor: AppColors.borderGrey,
                      disabledTextColor: Colors.white70,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
