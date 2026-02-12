import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/providers/profile_setup_provider.dart';
import 'package:partner_app/providers/auth_provider.dart';

import '../../widgets/common_button.dart';
import '../../widgets/upload_card.dart';
import '../../widgets/app_dialogs.dart';

class ProfileSetupStep3Screen extends StatefulWidget {
  const ProfileSetupStep3Screen({super.key});

  @override
  State<ProfileSetupStep3Screen> createState() => _ProfileSetupStep3ScreenState();
}

class _ProfileSetupStep3ScreenState extends State<ProfileSetupStep3Screen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _gstFile;
  XFile? _panFile;
  XFile? _aadhaarFrontFile;
  XFile? _aadhaarBackFile;
  XFile? _profileImageFile; // Added

  bool get _canComplete => 
      _panFile != null && 
      _aadhaarFrontFile != null && 
      _aadhaarBackFile != null &&
      _profileImageFile != null; // Added profile image requirement

  Future<void> _handleCompleteSetup() async {
    final provider = context.read<ProfileSetupProvider>();
    
    // Save Step 3 data (documents) to provider
    provider.saveStep3Data(
      gstCertificate: _gstFile,
      panCard: _panFile,
      aadhaarFront: _aadhaarFrontFile,
      aadhaarBack: _aadhaarBackFile,
      profileImage: _profileImageFile, // Added
    );

    // Submit profile to API
    final success = await provider.submitProfile();

    if (!mounted) return;

    if (success) {
      // Mark profile as completed in AuthProvider
      if (mounted) {
        context.read<AuthProvider>().setProfileCompleted(true);
      }
      await _showCompletionDialog();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showCompletionDialog() async {
    await AppDialogs.showPrimaryDialog(
      context: context,
      title: 'Document Verification',
      message:
          'Document verification is in progress, and once approved you can start adding services and will begin receiving successful bookings.',
      onOk: () {
        // Clear provider data after successful submission
        context.read<ProfileSetupProvider>().clearData();
        AppRoutes.navigateToDashboard(context);
      },
    );
  }

  Future<void> _pickGst() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _gstFile = file;
    });
  }

  Future<void> _pickPan() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _panFile = file;
    });
  }

  Future<void> _pickAadhaarFront() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _aadhaarFrontFile = file;
    });
  }

  Future<void> _pickAadhaarBack() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _aadhaarBackFile = file;
    });
  }

  Future<void> _pickProfileImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _profileImageFile = file;
    });
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
                  const SizedBox(height: 16),
                  Text(
                    'Profile Setup – Step 3',
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
                  const SizedBox(height: 16),
                  Text(
                    'Business Verification',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.loginTitleText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  UploadCard(
                    title: 'Upload Profile Image',
                    isDoubleSlot: false,
                    onTapPrimary: _pickProfileImage,
                    primaryFileName: _profileImageFile?.name,
                    primaryPreview: _profileImageFile != null ? const SizedBox.shrink() : null, // Dummy to trigger 'hasPreview'
                    onRemovePrimary: () => setState(() => _profileImageFile = null),
                    onViewPrimary: _profileImageFile != null 
                      ? () => AppDialogs.showImagePreview(
                          context: context, 
                          image: Image.file(File(_profileImageFile!.path)),
                        )
                      : null,
                  ),
                  const SizedBox(height: 12),
                  UploadCard(
                    title: 'Upload GST Certificate (optional)',
                    isDoubleSlot: false,
                    onTapPrimary: _pickGst,
                    primaryFileName: _gstFile?.name,
                    primaryPreview: _gstFile != null ? const SizedBox.shrink() : null,
                    onRemovePrimary: () => setState(() => _gstFile = null),
                    onViewPrimary: _gstFile != null 
                      ? () => AppDialogs.showImagePreview(
                          context: context, 
                          image: Image.file(File(_gstFile!.path)),
                        )
                      : null,
                  ),
                  const SizedBox(height: 12),
                  UploadCard(
                    title: 'Upload PAN Card',
                    isDoubleSlot: false,
                    onTapPrimary: _pickPan,
                    primaryFileName: _panFile?.name,
                    primaryPreview: _panFile != null ? const SizedBox.shrink() : null,
                    onRemovePrimary: () => setState(() => _panFile = null),
                    onViewPrimary: _panFile != null 
                      ? () => AppDialogs.showImagePreview(
                          context: context, 
                          image: Image.file(File(_panFile!.path)),
                        )
                      : null,
                  ),
                  const SizedBox(height: 12),
                  UploadCard(
                    title: 'Upload Aadhaar Card',
                    isDoubleSlot: true,
                    onTapPrimary: _pickAadhaarFront,
                    onTapSecondary: _pickAadhaarBack,
                    primaryFileName: _aadhaarFrontFile?.name,
                    secondaryFileName: _aadhaarBackFile?.name,
                    primaryPreview: _aadhaarFrontFile != null ? const SizedBox.shrink() : null,
                    secondaryPreview: _aadhaarBackFile != null ? const SizedBox.shrink() : null,
                    onRemovePrimary: () => setState(() => _aadhaarFrontFile = null),
                    onRemoveSecondary: () => setState(() => _aadhaarBackFile = null),
                    onViewPrimary: _aadhaarFrontFile != null 
                      ? () => AppDialogs.showImagePreview(
                          context: context, 
                          image: Image.file(File(_aadhaarFrontFile!.path)),
                        )
                      : null,
                    onViewSecondary: _aadhaarBackFile != null 
                      ? () => AppDialogs.showImagePreview(
                          context: context, 
                          image: Image.file(File(_aadhaarBackFile!.path)),
                        )
                      : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.loginSubtitleText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your documents are encrypted and used only for verification.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.loginSubtitleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Consumer<ProfileSetupProvider>(
                    builder: (context, provider, child) {
                      return Center(
                        child: CommonButton(
                          text: provider.isLoading ? 'Submitting...' : 'Complete Setup',
                          onPressed: (_canComplete && !provider.isLoading) 
                              ? _handleCompleteSetup 
                              : null,
                          width: double.infinity,
                        ),
                      );
                    },
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
