import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/booking.dart';
import '../../widgets/booking_widgets.dart';
import '../../providers/booking_provider.dart';
import 'package:provider/provider.dart';

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

  Future<void> _updateStatus(BookingMainStatus newStatus) async {
    final success = await context.read<BookingProvider>().updateStatus(_booking, newStatus);
    if (!mounted) return;

    if (success) {
      setState(() {
        _booking = _booking.copyWith(mainStatus: newStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = context.read<BookingProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        child: Consumer<BookingProvider>(
          builder: (context, provider, child) {
            String? primaryLabel;
            VoidCallback? onPrimary;

            if (_booking.mainStatus == BookingMainStatus.upcoming) {
              primaryLabel = 'Start Service';
              onPrimary = () => _updateStatus(BookingMainStatus.ongoing);
            } else if (_booking.mainStatus == BookingMainStatus.ongoing) {
              primaryLabel = 'Mark As Completed';
              onPrimary = () => _updateStatus(BookingMainStatus.completed);
            }

            return Column(
              children: [
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                BookingCard(
                  booking: _booking,
                  primaryLabel: primaryLabel,
                  onTap: () {},
                  onPrimaryAction: onPrimary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

