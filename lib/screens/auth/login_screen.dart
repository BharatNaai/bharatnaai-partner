import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/providers/auth_provider.dart';
import 'package:partner_app/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _phoneError;
  String? _passwordError;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
    _setupFocusListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startEntryAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    
    // Start pulse animation loop
    _pulseController.repeat(reverse: true);
  }

  void _setupFocusListeners() {
    _phoneFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    // Validate form
    bool isValid = true;
    
    if (_phoneController.text.trim().isEmpty) {
      _phoneError = AppStrings.requiredField;
      isValid = false;
    } else if (!_isValidPhone(_phoneController.text.trim())) {
      _phoneError = AppStrings.invalidPhone;
      isValid = false;
    }
    
    if (_passwordController.text.isEmpty) {
      _passwordError = AppStrings.requiredField;
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      _passwordError = AppStrings.passwordTooShort;
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      _shakeCard();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(authProvider.errorMessage ?? 'Login failed');
        _shakeCard();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Network error. Please try again.');
        _shakeCard();
      }
    }
  }

  bool _isValidPhone(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    // Check if it has 8-15 digits (international phone number range)
    return digitsOnly.length >= 8 && digitsOnly.length <= 15;
  }

  void _shakeCard() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.loginErrorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = screenWidth > 480 ? 420.0 : screenWidth - 48;
    
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight - 100),
                child: Column(
                  children: [
                    const SizedBox(height: 72),
                    
                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: _buildLogo(),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      AppStrings.barberPartnerApp,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.loginTitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      AppStrings.empoweringSalonProfessionals,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.loginSubtitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Login Card
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: _buildLoginCard(maxCardWidth),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 18),
                    
                    // Footer
                    _buildFooter(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.loginLightPurpleRing,
          width: 7,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.loginLightPurpleRing.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.content_cut_rounded,
          size: 28,
          color: AppColors.loginPrimaryPurple,
        ),
      ),
    );
  }

  Widget _buildLoginCard(double maxWidth) {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x10182840),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhoneField(),
          const SizedBox(height: 12),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildForgotPasswordLink(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    final isFocused = _phoneFocusNode.hasFocus;
    final hasError = _phoneError != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.loginErrorRed
                  : isFocused
                      ? AppColors.loginPrimaryPurple
                      : AppColors.loginInputBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: hasError
                      ? AppColors.loginErrorRed
                      : isFocused
                          ? AppColors.loginPrimaryPurple
                          : AppColors.loginInputPlaceholder,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.loginTitleText,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.phoneNumber,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.loginInputPlaceholder,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              _phoneError!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.loginErrorRed,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final isFocused = _passwordFocusNode.hasFocus;
    final hasError = _passwordError != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.loginErrorRed
                  : isFocused
                      ? AppColors.loginPrimaryPurple
                      : AppColors.loginInputBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.lock_outlined,
                  size: 20,
                  color: hasError
                      ? AppColors.loginErrorRed
                      : isFocused
                          ? AppColors.loginPrimaryPurple
                          : AppColors.loginInputPlaceholder,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.loginTitleText,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.password,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.loginInputPlaceholder,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.loginInputPlaceholder,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              _passwordError!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.loginErrorRed,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading
              ? AppColors.loginPrimaryPurple.withOpacity(0.4)
              : AppColors.loginPrimaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppStrings.login,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        // Navigate to forgot password screen
        Navigator.pushNamed(context, AppRoutes.forgotPassword);
      },
      child: Text(
        AppStrings.forgotPassword,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.loginPrimaryPurple,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.loginFooterText,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.register,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.loginPrimaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
