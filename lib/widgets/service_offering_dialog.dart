import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/models/service_offering.dart';
import 'package:partner_app/widgets/common_text_field.dart';
import 'package:partner_app/widgets/common_button.dart';

Future<ServiceOffering?> showServiceOfferingDialog({
  required BuildContext context,
  ServiceOffering? initialService,
}) {
  final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

  String selectedService = initialService?.name ?? kServiceOptions.first;
  final TextEditingController avgTimeController = TextEditingController(
    text: initialService?.averageTime ?? '',
  );
  final TextEditingController experienceController = TextEditingController(
    text: initialService?.experience ?? '',
  );
  final TextEditingController costController = TextEditingController(
    text: initialService?.cost ?? '',
  );
  final TextEditingController notesController = TextEditingController(
    text: initialService?.notes ?? '',
  );
  
  final FocusNode timeFocus = FocusNode();
  final FocusNode expFocus = FocusNode();
  final FocusNode costFocus = FocusNode();
  final FocusNode notesFocus = FocusNode();

  return showDialog<ServiceOffering?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: screenWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        initialService == null ? 'Add Service' : 'Edit Service',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedService,
                        decoration: InputDecoration(
                          labelText: 'Service',
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: kServiceOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value == null) return;
                          setState(() {
                            selectedService = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CommonTextField(
                        controller: avgTimeController,
                        focusNode: timeFocus,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(dialogContext).requestFocus(expFocus),
                        labelText: 'Average Time (mins)',
                        semanticLabel: "Enter average time in minutes, required",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.timer_outlined,
                        obscureText: false,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CommonTextField(
                        controller: experienceController,
                        focusNode: expFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(dialogContext).requestFocus(costFocus),
                        labelText: 'Experience (years)',
                        semanticLabel: "Enter experience in years, required",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.work_outline,
                        obscureText: false,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CommonTextField(
                        controller: costController,
                        focusNode: costFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(dialogContext).requestFocus(notesFocus),
                        labelText: 'Cost',
                        semanticLabel: "Enter Cost, required",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee_outlined,
                        obscureText: false,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CommonTextField(
                        controller: notesController,
                        focusNode: notesFocus,
                        textInputAction: TextInputAction.done,
                        labelText: 'Notes (optional)',
                        semanticLabel: "Enter Notes, optional",
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.note_outlined,
                        obscureText: false,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(null);
                            },
                            child: Text(
                              'Cancel',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.loginFooterText,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: CommonButton(
                              text: 'Save',
                              onPressed: () {
                                if (avgTimeController.text.isEmpty ||
                                    experienceController.text.isEmpty ||
                                    costController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill all required fields.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final result = ServiceOffering(
                                  id:
                                      initialService?.id ??
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  name: selectedService,
                                  averageTime: avgTimeController.text,
                                  experience: experienceController.text,
                                  cost: costController.text,
                                  notes: notesController.text,
                                );

                                Navigator.of(dialogContext).pop(result);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
