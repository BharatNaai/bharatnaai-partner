import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/booking.dart';
import '../../routes/app_routes.dart';
import '../../widgets/booking_widgets.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  late List<Booking> _bookings;
  BookingMainStatus _selectedMainStatus = BookingMainStatus.upcoming;

  @override
  void initState() {
    super.initState();
    _bookings = List<Booking>.from(kMockBookings);
  }

  List<Booking> get _filteredBookings {
    return _bookings
        .where((b) => b.mainStatus == _selectedMainStatus)
        .toList();
  }

  void _updateBooking(Booking updated) {
    setState(() {
      _bookings = _bookings
          .map((b) => b.id == updated.id ? updated : b)
          .toList(growable: false);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookings',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage all your customer appointments.',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.loginSubtitleText,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: AppColors.textPrimary),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    BookingPillTab(
                      label: 'Upcoming',
                      isSelected: _selectedMainStatus == BookingMainStatus.upcoming,
                      icon: Icons.calendar_today_outlined,
                      onTap: () {
                        setState(() {
                          _selectedMainStatus = BookingMainStatus.upcoming;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    BookingPillTab(
                      label: 'Ongoing',
                      isSelected: _selectedMainStatus == BookingMainStatus.ongoing,
                      icon: Icons.play_circle_outline,
                      onTap: () {
                        setState(() {
                          _selectedMainStatus = BookingMainStatus.ongoing;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    BookingPillTab(
                      label: 'Completed',
                      isSelected: _selectedMainStatus == BookingMainStatus.completed,
                      icon: Icons.check_circle_outline,
                      onTap: () {
                        setState(() {
                          _selectedMainStatus = BookingMainStatus.completed;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: _filteredBookings.map((booking) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: 12,
                  ),

                  child: BookingCard(
                    booking: booking,
                    primaryLabel: booking.mainStatus == BookingMainStatus.ongoing
                        ? 'Start Service'
                        : booking.mainStatus == BookingMainStatus.completed
                        ? 'View Details'
                        : 'Accept',
                    secondaryLabel: booking.mainStatus == BookingMainStatus.ongoing
                        ? 'Mark As Completed'
                        : booking.mainStatus == BookingMainStatus.upcoming
                        ? 'Reject'
                        : null,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.booking,
                        arguments: booking,
                      );
                    },
                    onPrimaryAction: () {
                      if (booking.mainStatus == BookingMainStatus.upcoming) {
                        _updateBooking(
                          booking.copyWith(
                            actionStatus: BookingActionStatus.confirmed,
                          ),
                        );
                      } else if (booking.mainStatus == BookingMainStatus.ongoing) {
                        _updateBooking(
                          booking.copyWith(
                            mainStatus: BookingMainStatus.completed,
                          ),
                        );
                      }
                    },
                    onSecondaryAction: booking.mainStatus == BookingMainStatus.upcoming
                        ? () {
                            _updateBooking(
                              booking.copyWith(
                                actionStatus: BookingActionStatus.rejected,
                              ),
                            );
                          }
                        : booking.mainStatus == BookingMainStatus.ongoing
                            ? () {
                                _updateBooking(
                                  booking.copyWith(
                                    mainStatus: BookingMainStatus.completed,
                                  ),
                                );
                              }
                            : null,
                    onPhoneTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling customer...'),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
