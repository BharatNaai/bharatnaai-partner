import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/providers/location_provider.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/upload_card.dart';
import '../../widgets/booking_widgets.dart';

class SalonInfoScreen extends StatefulWidget {
  const SalonInfoScreen({super.key});

  @override
  State<SalonInfoScreen> createState() => _SalonInfoScreenState();
}

class _SalonInfoScreenState extends State<SalonInfoScreen> {
  final _salonNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _coverPhoto;

  bool _isEditing = false;

  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  final Set<String> _selectedAmenities = <String>{};

  bool get _isFormValid =>
      _salonNameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _salonNameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() {
      _coverPhoto = file;
    });
  }

  Future<void> _handleUseCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    final placemark = await locationProvider.fetchCurrentPlacemark();
    if (!mounted) return;

    if (placemark != null) {
      setState(() {
        _pincodeController.text = placemark.postalCode ?? '';
        _cityController.text = placemark.locality ??
            placemark.subAdministrativeArea ??
            '';
        _addressController.text = [
          placemark.street,
          placemark.subLocality,
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

  Future<void> _pickTime({required bool isOpen}) async {
    final now = TimeOfDay.now();
    final initialTime = isOpen ? (_openTime ?? now) : (_closeTime ?? now);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) return;

    setState(() {
      if (isOpen) {
        _openTime = picked;
      } else {
        _closeTime = picked;
      }
    });
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveSalonInfo() async {
    if (!_isFormValid || !_isEditing) return;

    // TODO: integrate with real saveSalonInfo service when available.

    setState(() {
      _isEditing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salon info saved')),
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
          'Salon Info',
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
                  _buildCard(textTheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(TextTheme textTheme) {
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
          _buildUploadSection(textTheme),
          const SizedBox(height: 16),
          ..._buildFormFields(textTheme),
          const SizedBox(height: 16),
          _buildTimeRow(textTheme),
          const SizedBox(height: 16),
          _buildAmenitiesSection(textTheme),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildUploadSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UploadCard(
          title: 'Salon Cover Photo',
          subtitle: 'Upload a clear photo of your salon front',
          onTapPrimary: _isEditing ? _pickCoverPhoto : null,
          primaryPreview: _coverPhoto != null
              ? Image.file(
                  File(_coverPhoto!.path),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isEditing ? _pickCoverPhoto : null,
            child: Text(
              _coverPhoto == null ? 'Upload Photo' : 'Change Photo',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields(TextTheme textTheme) {
    final isEditing = _isEditing;

    final fields = [
      _SalonFieldConfig(
        controller: _salonNameController,
        label: 'Salon Name',
        keyboardType: TextInputType.text,
      ),
      _SalonFieldConfig(
        controller: _taglineController,
        label: 'Tagline (optional)',
        keyboardType: TextInputType.text,
      ),
      _SalonFieldConfig(
        controller: _addressController,
        label: 'Address',
        keyboardType: TextInputType.streetAddress,
        maxLines: 2,
      ),
      _SalonFieldConfig(
        controller: _cityController,
        label: 'City',
        keyboardType: TextInputType.text,
      ),
      _SalonFieldConfig(
        controller: _pincodeController,
        label: 'Pincode',
        keyboardType: TextInputType.number,
      ),
    ];

    return fields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CommonTextField(
              controller: field.controller,
              labelText: field.label,
              keyboardType: field.keyboardType,
              maxLines: field.maxLines,
              enabled: isEditing,
            ),
          ),
        )
        .toList();
  }

  Widget _buildTimeRow(TextTheme textTheme) {
    final isEditing = _isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Hours',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.loginTitleText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeChip(
                label: 'Open',
                value: _formatTime(_openTime),
                onTap: isEditing
                    ? () => _pickTime(isOpen: true)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeChip(
                label: 'Close',
                value: _formatTime(_closeTime),
                onTap: isEditing
                    ? () => _pickTime(isOpen: false)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.loginInputBorder),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.loginSubtitleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.schedule,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection(TextTheme textTheme) {
    final isEditing = _isEditing;
    const amenities = <String>[
      'AC',
      'Wi-Fi',
      'Parking',
      'Music',
      'Online Payments',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.loginTitleText,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((label) {
            final isSelected = _selectedAmenities.contains(label);
            return BookingFilterChip(
              label: label,
              icon: Icons.check_circle_outline,
              isSelected: isSelected,
              onTap: isEditing
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedAmenities.remove(label);
                        } else {
                          _selectedAmenities.add(label);
                        }
                      });
                    }
                  : () {},
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return CommonButton(
      text: 'Save Salon Info',
      width: double.infinity,
      onPressed: _isEditing && _isFormValid ? _saveSalonInfo : null,
    );
  }
}

class _SalonFieldConfig {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final int maxLines;

  const _SalonFieldConfig({
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.maxLines = 1,
  });
}
