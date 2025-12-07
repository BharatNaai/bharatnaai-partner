import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/providers/location_provider.dart';
import 'package:partner_app/routes/app_routes.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  bool _isEditing = false;
  String _selectedGender = 'Male';

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() {
      _profileImage = file;
    });
  }

  Future<void> _handleUseCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    final placemark = await locationProvider.fetchCurrentPlacemark();
    if (!mounted) return;

    if (placemark != null) {
      setState(() {
        _addressController.text = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
        ].where((e) => (e ?? '').isNotEmpty).join(', ');
      });
    } else if (locationProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locationProvider.errorMessage!)),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _handleSave() async {
    if (!_isFormValid) return;

    setState(() {
      _isEditing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal details saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Personal Info',
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
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
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
                children: [
                  const SizedBox(height: 24),
                  _buildCard(context, textTheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182840),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildProfilePhoto(textTheme)),
          const SizedBox(height: 20),
          ..._buildFormFields(textTheme),
          const SizedBox(height: 16),
          _buildGenderSection(textTheme),
          const SizedBox(height: 16),
          _buildAddressSection(textTheme),
          const SizedBox(height: 24),
          _buildFooter(textTheme),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(TextTheme textTheme) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _pickProfileImage : null,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(
                      File(_profileImage!.path),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        'Add Profile\nPhoto',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.loginSubtitleText,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to upload',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.loginSubtitleText,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields(TextTheme textTheme) {
    final isEditing = _isEditing;

    final fields = [
      _FieldConfig(
        controller: _fullNameController,
        label: 'Full Name',
        hint: 'Enter your full name',
        keyboardType: TextInputType.text,
        enabled: isEditing,
      ),
      _FieldConfig(
        controller: _phoneController,
        label: 'Phone Number',
        hint: '+91 98765 43210',
        keyboardType: TextInputType.phone,
        enabled: false,
        helperText: 'Use your WhatsApp number',
      ),
      _FieldConfig(
        controller: _emailController,
        label: 'Email Address (optional)',
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        enabled: isEditing,
      ),
      _FieldConfig(
        controller: _dobController,
        label: 'Date of Birth (optional)',
        hint: 'DD / MM / YYYY',
        keyboardType: TextInputType.datetime,
        enabled: isEditing,
      ),
    ];

    return fields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  controller: field.controller,
                  labelText: field.label,
                  keyboardType: field.keyboardType,
                  maxLines: 1,
                  enabled: field.enabled,
                ),
                if (field.helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    field.helperText!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildGenderSection(TextTheme textTheme) {
    final genders = ['Male', 'Female', 'Other'];
    final isEditing = _isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.loginTitleText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: genders.map((gender) {
            final bool isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    gender,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.loginSubtitleText,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isEditing
                      ? (value) {
                          if (!value) return;
                          setState(() {
                            _selectedGender = gender;
                          });
                        }
                      : null,
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFEDE9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.borderGrey,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressSection(TextTheme textTheme) {
    final isEditing = _isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: _addressController,
          labelText: 'Address',
          keyboardType: TextInputType.streetAddress,
          maxLines: 3,
          enabled: isEditing,
        ),
        const SizedBox(height: 8),
        Consumer<LocationProvider>(
          builder: (context, locationProvider, _) {
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: isEditing && !locationProvider.isLoading
                    ? _handleUseCurrentLocation
                    : null,
                child: Text(
                  locationProvider.isLoading
                      ? 'Detecting location...'
                      : 'Use current location',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isEditing
                        ? AppColors.primaryColor
                        : AppColors.loginSubtitleText,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Your details help us verify your profile.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.loginSubtitleText,
          ),
        ),
        const SizedBox(height: 16),
        CommonButton(
          text: 'Save Details',
          width: double.infinity,
          onPressed: _isEditing && _isFormValid ? _handleSave : null,
        ),
      ],
    );
  }
}

class _FieldConfig {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String? helperText;

  const _FieldConfig({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    this.helperText,
  });
}
