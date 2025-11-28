import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_button.dart';

class BarbersProfileScreen extends StatelessWidget {
  const BarbersProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    final menuItems = _profileMenuItems;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundEnd,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Profile',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeaderCard(
              name: 'Royal Salon',
              rating: 4.8,
              onEditProfile: () {
                Navigator.pushNamed(context, AppRoutes.profileStep1);
              },
            ),
            const SizedBox(height: 16),
            _EarningsQuickCard(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.earning);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Main options',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.loginSubtitleText,
              ),
            ),
            const SizedBox(height: 12),
            _ProfileMenuGrid(items: menuItems),
            const SizedBox(height: 24),
            CommonButton(
              text: 'Logout',
              height: 50,
              width: double.infinity,
              backgroundColor: AppColors.errorRed,
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                AppRoutes.navigateToLogin(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final double rating;
  final VoidCallback onEditProfile;

  const _ProfileHeaderCard({
    required this.name,
    required this.rating,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  size: 18, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppColors.loginSubtitleText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF4E5),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'Edit Profile',
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsQuickCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EarningsQuickCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10182840),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings & Payouts',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Quick view',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.loginSubtitleText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  final String label;
  final IconData icon;
  final String routeName;

  const _ProfileMenuItem({
    required this.label,
    required this.icon,
    required this.routeName,
  });
}

const List<_ProfileMenuItem> _profileMenuItems = [
  _ProfileMenuItem(
    label: 'Personal Info',
    icon: Icons.person_outline,
    routeName: AppRoutes.profileStep1,
  ),
  _ProfileMenuItem(
    label: 'Salon Info',
    icon: Icons.storefront_outlined,
    routeName: AppRoutes.profileStep2,
  ),
  _ProfileMenuItem(
    label: 'My Services',
    icon: Icons.cut,
    routeName: AppRoutes.manageServices,
  ),
  _ProfileMenuItem(
    label: 'Bank Info',
    icon: Icons.account_balance_outlined,
    routeName: AppRoutes.payouts,
  ),
  _ProfileMenuItem(
    label: 'KYC Docs',
    icon: Icons.verified_user_outlined,
    routeName: AppRoutes.profileStep3,
  ),
  _ProfileMenuItem(
    label: 'Reviews',
    icon: Icons.star_border_rounded,
    routeName: AppRoutes.reviews,
  ),
  _ProfileMenuItem(
    label: 'Help & Support',
    icon: Icons.help_outline,
    routeName: AppRoutes.settings,
  ),
  _ProfileMenuItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    routeName: AppRoutes.settings,
  ),
];

class _ProfileMenuGrid extends StatelessWidget {
  final List<_ProfileMenuItem> items;

  const _ProfileMenuGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _ProfileMenuItemCard(item: items[index]);
      },
    );
  }
}

class _ProfileMenuItemCard extends StatelessWidget {
  final _ProfileMenuItem item;

  const _ProfileMenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, item.routeName);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10182840),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

