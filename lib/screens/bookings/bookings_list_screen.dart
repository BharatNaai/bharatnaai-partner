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

class _BookingsListScreenState extends State<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late List<Booking> _bookings;
  late TabController _tabController;
  BookingMainStatus _selectedMainStatus = BookingMainStatus.upcoming;

  @override
  void initState() {
    super.initState();
    _bookings = List<Booking>.from(kMockBookings);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedMainStatus = BookingMainStatus.values[_tabController.index];
    });
  }

  void _updateBooking(Booking updated) {
    setState(() {
      _bookings = _bookings
          .map((b) => b.id == updated.id ? updated : b)
          .toList(growable: false);
    });
  }

  List<Booking> _getBookingsByStatus(BookingMainStatus status) {
    return _bookings.where((b) => b.mainStatus == status).toList();
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pills Tab Bar
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
                    onTap: () => _tabController.animateTo(0),
                  ),
                  const SizedBox(width: 8),
                  BookingPillTab(
                    label: 'Ongoing',
                    isSelected: _selectedMainStatus == BookingMainStatus.ongoing,
                    onTap: () => _tabController.animateTo(1),
                  ),
                  const SizedBox(width: 8),
                  BookingPillTab(
                    label: 'Completed',
                    isSelected: _selectedMainStatus == BookingMainStatus.completed,
                    onTap: () => _tabController.animateTo(2),
                  ),
                ],
              ),
            ),
          ),
          
          // Swipeable List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(BookingMainStatus.upcoming),
                _buildBookingList(BookingMainStatus.ongoing),
                _buildBookingList(BookingMainStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(BookingMainStatus status) {
    final bookings = _getBookingsByStatus(status);
    
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No ${status.name} bookings',
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      },
    );
  }
}
