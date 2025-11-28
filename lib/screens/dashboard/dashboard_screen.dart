import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/widgets/common_bottom_nav_bar.dart';
import 'package:partner_app/screens/bookings/bookings_list_screen.dart';
import 'package:partner_app/models/booking.dart';
import 'package:partner_app/widgets/booking_widgets.dart';
import 'package:partner_app/screens/earning_portfolio/earning_screen.dart';
import 'package:partner_app/screens/profile/barbers_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    _DashboardHomeTab(),
    const BookingsListScreen(),
    const EarningsScreen(),
    const BarbersProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class _DashboardHomeTab extends StatefulWidget {
  @override
  State<_DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<_DashboardHomeTab> {
  late List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = List<Booking>.from(kMockBookings);
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

    final upcomingBookings = _bookings
        .where((b) => b.mainStatus == BookingMainStatus.upcoming)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,

      // ------------------ APP BAR -------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.dashboard,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Welcome back, Rahul\'s Salon',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.loginSubtitleText,
              ),
            ),
          ],
        ),
        actions: const [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryColor,
          ),
          SizedBox(width: 16),
        ],
      ),

      // ------------------ BODY ---------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ----------- STATS ROW 1 ------------
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Today\'s Earnings',
                    value: '\u20b96,540',
                    subtitle: '+12% vs yesterday',
                    icon: Icons.currency_rupee_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Total Bookings',
                    value: '32',
                    subtitle: 'Today',
                    icon: Icons.event_available_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----------- STATS ROW 2 ------------
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Completed Services',
                    value: '24',
                    subtitle: 'Completion 75%',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Upcoming Booking',
                    value: '8',
                    subtitle: 'Next 24 hrs',
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),

            // ----------- UPCOMING BOOKINGS ------------
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Upcoming Bookings',
              child: Column(
                children: upcomingBookings.take(3).map((booking) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BookingCard(
                      booking: booking,
                      primaryLabel: 'Start Service',
                      secondaryLabel: 'Mark As Completed',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.booking,
                          arguments: booking,
                        );
                      },
                      onPrimaryAction: () {
                        _updateBooking(
                          booking.copyWith(
                            mainStatus: BookingMainStatus.ongoing,
                          ),
                        );
                      },
                      onSecondaryAction: () {
                        _updateBooking(
                          booking.copyWith(
                            mainStatus: BookingMainStatus.completed,
                          ),
                        );
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
                }).toList(),
              ),
            ),

            const SizedBox(height: 72), // safe space for bottom nav + FAB
          ],
        ),
      ),
    );
  }
}

class _SimplePlaceholderTab extends StatelessWidget {
  final String title;

  const _SimplePlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      color: AppColors.loginBackgroundEnd,
      child: Center(
        child: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182840),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.loginSubtitleText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppColors.loginSubtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182840),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String customerName;
  final String service;
  final String when;
  final String status;
  final Color statusColor;

  const _AppointmentTile({
    required this.customerName,
    required this.service,
    required this.when,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.loginBackgroundStart,
          child: Icon(
            Icons.person_outline,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$customerName \u00b7 $service',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                when,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.loginSubtitleText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            status,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
