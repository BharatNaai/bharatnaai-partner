import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_bottom_nav_bar.dart';
import '../../widgets/common_button.dart';

class BarbersProfileScreen extends StatelessWidget {
  const BarbersProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

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
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeaderSection(
                  onEditProfile: () {
                    Navigator.pushNamed(context, AppRoutes.profileStep1);
                  },
                ),
                const SizedBox(height: 20),
                _ProfileMenuSection(
                  onLogout: () async {
                    final auth =
                        Provider.of<AuthProvider>(context, listen: false);
                    await auth.logout();
                    AppRoutes.navigateToLogin(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderSection extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _ProfileHeaderSection({required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10182840),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage:
                    AssetImage('assets/images/_barber_profile_image.jpg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Royal Salon',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.white,
                              ),
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
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppColors.loginSubtitleText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _EarningsQuickCard(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.earning);
          },
        ),
      ],
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
    routeName: '/personal-info',
  ),
  _ProfileMenuItem(
    label: 'Salon Info',
    icon: Icons.storefront_outlined,
    routeName: '/salon-info',
  ),
  _ProfileMenuItem(
    label: 'Bank Info',
    icon: Icons.account_balance_outlined,
    routeName: '/bank-info',
  ),
  _ProfileMenuItem(
    label: 'Earnings & Payouts',
    icon: Icons.account_balance_wallet_outlined,
    routeName: '/earnings',
  ),
  _ProfileMenuItem(
    label: 'Help & Support',
    icon: Icons.help_outline,
    routeName: '/help',
  ),
  _ProfileMenuItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    routeName: '/settings',
  ),
  _ProfileMenuItem(
    label: 'Privacy Policy',
    icon: Icons.privacy_tip_outlined,
    routeName: '/privacy',
  ),
  _ProfileMenuItem(
    label: 'Terms & Conditions',
    icon: Icons.article_outlined,
    routeName: '/terms',
  ),
  _ProfileMenuItem(
    label: 'FAQs',
    icon: Icons.help_center_outlined,
    routeName: '/faqs',
  ),
  _ProfileMenuItem(
    label: 'How It Works',
    icon: Icons.info_outline,
    routeName: '/how-it-works',
  ),
];

class _ProfileMenuSection extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileMenuSection({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main options',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.loginSubtitleText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              ..._profileMenuItems.map((item) {
                final isLast =
                    item == _profileMenuItems[_profileMenuItems.length - 1];
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item.label,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textGrey),
                      onTap: () {
                        Navigator.pushNamed(context, item.routeName);
                      },
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: AppColors.borderGrey,
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CommonButton(
          text: 'Logout',
          height: 50,
          width: double.infinity,
          backgroundColor: AppColors.errorRed,
          onPressed: onLogout,
        ),
      ],
    );
  }
}

