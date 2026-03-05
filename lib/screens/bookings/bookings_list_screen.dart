import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../services/user_storage_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/booking_widgets.dart';
import '../../providers/booking_provider.dart';
import 'package:provider/provider.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BookingMainStatus _selectedMainStatus = BookingMainStatus.upcoming;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
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

  Future<void> _updateBookingStatus(Booking booking, BookingMainStatus newStatus) async {
    final success = await context.read<BookingProvider>().updateStatus(booking, newStatus);
    if (!mounted) return;
    
    if (success) {
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
    final bookingProvider = context.watch<BookingProvider>();

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
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
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
    final bookings = context.read<BookingProvider>().getBookingsByStatus(status);
    
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
            primaryLabel: booking.mainStatus == BookingMainStatus.upcoming
                ? 'Start'
                : booking.mainStatus == BookingMainStatus.ongoing
                    ? 'Completed'
                    : 'Order Details',
            secondaryLabel: null,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.booking,
                arguments: booking,
              );
            },
            onPrimaryAction: () {
              final next = booking.nextStatus;
              if (next != null) {
                _updateBookingStatus(booking, next);
              } else if (booking.mainStatus == BookingMainStatus.completed) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.booking,
                  arguments: booking,
                );
              }
            },
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
