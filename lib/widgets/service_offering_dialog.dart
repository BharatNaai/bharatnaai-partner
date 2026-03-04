import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:partner_app/providers/auth_provider.dart';
import 'package:partner_app/models/service_offering.dart';
import 'package:partner_app/repositories/service_repository.dart';
import 'package:partner_app/widgets/common_text_field.dart';
import 'package:partner_app/widgets/common_button.dart';

import '../services/user_storage_service.dart';

class ServiceEntry {
  String selectedService;
  final TextEditingController durationController;
  final TextEditingController costController;
  final TextEditingController experienceController;

  ServiceEntry({
    required this.selectedService,
    String duration = '',
    String cost = '',
    String experience = '',
  })  : durationController = TextEditingController(text: duration),
        costController = TextEditingController(text: cost),
        experienceController = TextEditingController(text: experience);

  void dispose() {
    durationController.dispose();
    costController.dispose();
    experienceController.dispose();
  }
}

Future<bool?> showServiceOfferingDialog({
  required BuildContext context,
  int? salonId,
  String? openingTime,
  String? closingTime,
  List<ServiceOffering>? initialServices,
}) {
  final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

  return showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _ServiceOfferingDialogContent(
        textTheme: textTheme,
        salonId: salonId ?? 1,
        openingTime: openingTime ?? "09:00",
        closingTime: closingTime ?? "21:00",
        initialServices: initialServices,
      );
    },
  );
}

class _ServiceOfferingDialogContent extends StatefulWidget {
  final TextTheme textTheme;
  final int salonId;
  final String openingTime;
  final String closingTime;
  final List<ServiceOffering>? initialServices;

  const _ServiceOfferingDialogContent({
    required this.textTheme,
    required this.salonId,
    required this.openingTime,
    required this.closingTime,
    this.initialServices,
  });

  @override
  _ServiceOfferingDialogContentState createState() =>
      _ServiceOfferingDialogContentState();
}

class _ServiceOfferingDialogContentState extends State<_ServiceOfferingDialogContent> {
  final List<ServiceEntry> _entries = [];
  late final TextEditingController _openingController;
  late final TextEditingController _closingController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _openingController = TextEditingController(text: widget.openingTime);
    _closingController = TextEditingController(text: widget.closingTime);
    if (widget.initialServices != null && widget.initialServices!.isNotEmpty) {
      for (var s in widget.initialServices!) {
        _entries.add(ServiceEntry(
          selectedService: s.serviceName,
          duration: s.durationMinutes.toString(),
          cost: s.serviceCost,
          experience: s.experience.toString(),
        ));
      }
    } else {
      _addEntry();
    }
  }

  void _addEntry() {
    setState(() {
      _entries.add(ServiceEntry(selectedService: kServiceOptions.first));
    });
  }

  void _removeEntry(int index) {
    if (_entries.length > 1) {
      setState(() {
        _entries[index].dispose();
        _entries.removeAt(index);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = "$hour:$minute";
      });
    }
  }

  @override
  void dispose() {
    _openingController.dispose();
    _closingController.dispose();
    for (var entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Validation
    for (var entry in _entries) {
      if (entry.durationController.text.isEmpty ||
          entry.costController.text.isEmpty ||
          entry.experienceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields for all services.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    final barberId = await UserStorageService.getBarberId();
    final authToken = await UserStorageService.getAccessToken();

    final services = _entries.map((e) {
      return ServiceOffering(
        serviceName: e.selectedService,
        durationMinutes: int.parse(e.durationController.text),
        experience: e.experienceController.text,
        serviceCost: e.costController.text,
      );
    }).toList();

    final response = await ServiceRepository.instance.generateSlots(
      barberId: barberId!,
      authToken: authToken!,
      salonId: 12,
      openingTime: _openingController.text,
      closingTime: _closingController.text,
      services: services,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.message}\nTotal slots generated: ${response.totalSlots}')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Services',
                    style: widget.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryColor, size: 28),
                    tooltip: 'Add Service Row',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(_openingController),
                      child: AbsorbPointer(
                        child: CommonTextField(
                          controller: _openingController,
                          labelText: 'Opening Time',
                          prefixIcon: Icons.access_time,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(_closingController),
                      child: AbsorbPointer(
                        child: CommonTextField(
                          controller: _closingController,
                          labelText: 'Closing Time',
                          prefixIcon: Icons.access_time_filled,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _entries.asMap().entries.map((entry) {
                      int index = entry.key;
                      ServiceEntry e = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: e.selectedService,
                                    decoration: const InputDecoration(
                                      labelText: 'Service Name',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: kServiceOptions
                                        .map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option, style: const TextStyle(fontSize: 13)),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => e.selectedService = val);
                                    },
                                  ),
                                ),
                                if (_entries.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => _removeEntry(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CommonTextField(
                                    controller: e.durationController,
                                    labelText: 'Duration (m)',
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CommonTextField(
                                    controller: e.costController,
                                    labelText: 'Cost ()',
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CommonTextField(
                                    controller: e.experienceController,
                                    labelText: 'Exp (yrs)',
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(null),
                    child: Text(
                      'Cancel',
                      style: widget.textTheme.bodyMedium?.copyWith(
                        color: AppColors.loginFooterText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: CommonButton(
                      text: _isSaving ? 'Saving...' : 'Save',
                      onPressed: _isSaving ? null : _handleSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

