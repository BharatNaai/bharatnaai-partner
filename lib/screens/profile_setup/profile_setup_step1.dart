import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/providers/location_provider.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';

class ProfileSetupStep1Screen extends StatefulWidget {
  const ProfileSetupStep1Screen({super.key});

  @override
  State<ProfileSetupStep1Screen> createState() => _ProfileSetupStep1ScreenState();
}

class _ProfileSetupStep1ScreenState extends State<ProfileSetupStep1Screen> {
  final _salonNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool get _isFormValid =>
      _salonNameController.text.trim().isNotEmpty &&
      _businessTypeController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _pincodeController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty &&
      _stateController.text.trim().isNotEmpty &&
      _countryController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _salonNameController.dispose();
    _businessTypeController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _openBusinessTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final types = [
          'Salon',
          'Spa',
          'Barber Shop',
          'Makeup Studio',
        ];
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final type = types[index];
              return ListTile(
                title: Text(
                  type,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.loginTitleText,
                  ),
                ),
                onTap: () {
                  _businessTypeController.text = type;
                  Navigator.pop(context);
                  setState(() {});
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: types.length,
          ),
        );
      },
    );
  }

  Future<void> _handleUseCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    final placemark = await locationProvider.fetchCurrentPlacemark();
    if (!mounted) return;

    if (placemark != null) {
      final position = locationProvider.lastPosition;

      setState(() {
        _pincodeController.text = placemark.postalCode ?? '';
        _cityController.text = placemark.locality ??
            placemark.subAdministrativeArea ??
            '';
        _stateController.text = placemark.administrativeArea ?? '';
        _countryController.text = placemark.country ?? '';
        _addressController.text = [
          placemark.street,
          placemark.subLocality,
        ].where((e) => (e ?? '').isNotEmpty).join(', ');

        if (position != null) {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
        }
      });
    } else if (locationProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locationProvider.errorMessage!)),
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
                  const SizedBox(height: 16),
                  Text(
                    'Profile Setup – Step 1',
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
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 18, color: AppColors.loginTitleText),
                      const SizedBox(width: 8),
                      Text(
                        'Salon Details',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.loginTitleText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: _salonNameController,
                    labelText: 'Salon Name',
                    prefixIcon: Icons.storefront_outlined,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _openBusinessTypePicker,
                    child: AbsorbPointer(
                      child: CommonTextField(
                        controller: _businessTypeController,
                        labelText: 'Business Type',
                        prefixIcon: Icons.expand_more,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: _addressController,
                    labelText: 'Address',
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _pincodeController,
                          labelText: 'Pincode',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonTextField(
                          controller: _cityController,
                          labelText: 'City',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 220,
                          child: CommonButton(
                            text: locationProvider.isLoading
                                ? 'Detecting location...'
                                : 'Use Current Location',
                            icon: Icons.my_location,
                            height: 40,
                            backgroundColor: AppColors.primaryColor,
                            textColor: Colors.white,
                            onPressed: locationProvider.isLoading
                                ? null
                                : _handleUseCurrentLocation,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _stateController,
                          labelText: 'State',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonTextField(
                          controller: _countryController,
                          labelText: 'Country',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _latitudeController,
                          labelText: 'Latitude',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonTextField(
                          controller: _longitudeController,
                          labelText: 'Longitude',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CommonButton(
                      text: 'Next →',
                      onPressed: _isFormValid
                          ? () => Navigator.pushNamed(
                                context,
                                AppRoutes.profileStep2,
                              )
                          : null,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement save & continue later persistence
                        AppRoutes.navigateToDashboard(context);
                      },
                      child: Text(
                        'Save & Continue Later',
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
