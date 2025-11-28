import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/booking.dart';
import '../../widgets/booking_widgets.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Booking _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  void _startService() {
    setState(() {
      _booking = _booking.copyWith(mainStatus: BookingMainStatus.ongoing);
    });
  }

  void _markCompleted() {
    setState(() {
      _booking = _booking.copyWith(mainStatus: BookingMainStatus.completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 16,
        title: Text(
          'Booking Details',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BookingCard(
          booking: _booking,
          primaryLabel: 'Start Service',
          secondaryLabel: 'Mark As Completed',
          onTap: () {},
          onPrimaryAction: _startService,
          onSecondaryAction: _markCompleted,
        ),
      ),
    );
  }
}

