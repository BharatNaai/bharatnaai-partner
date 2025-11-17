import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/routes/app_routes.dart';

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

  bool get _canComplete => _panFile != null && _aadhaarFrontFile != null && _aadhaarBackFile != null;

  Future<void> _showCompletionDialog() async {
    await AppDialogs.showPrimaryDialog(
      context: context,
      title: 'Document Verification',
      message:
          'Document verification is in progress, and once approved you can start adding services and will begin receiving successful bookings.',
      onOk: () {
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
                          AppColors.loginPrimaryPurple,
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
                    title: 'Upload GST Certificate (optional)',
                    isDoubleSlot: false,
                    onTapPrimary: _pickGst,
                    primaryPreview: _gstFile != null
                        ? Image.file(
                            File(_gstFile!.path),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  UploadCard(
                    title: 'Upload PAN Card',
                    isDoubleSlot: false,
                    onTapPrimary: _pickPan,
                    primaryPreview: _panFile != null
                        ? Image.file(
                            File(_panFile!.path),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  UploadCard(
                    title: 'Upload Aadhaar Card',
                    isDoubleSlot: true,
                    onTapPrimary: _pickAadhaarFront,
                    onTapSecondary: _pickAadhaarBack,
                    primaryPreview: _aadhaarFrontFile != null
                        ? Image.file(
                            File(_aadhaarFrontFile!.path),
                            fit: BoxFit.cover,
                          )
                        : null,
                    secondaryPreview: _aadhaarBackFile != null
                        ? Image.file(
                            File(_aadhaarBackFile!.path),
                            fit: BoxFit.cover,
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
                  Center(
                    child: CommonButton(
                      text: 'Complete Setup',
                      onPressed: _canComplete ? _showCompletionDialog : null,
                      width: double.infinity,
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
