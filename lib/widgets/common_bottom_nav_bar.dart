import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class BottomNavItemConfig {
  final IconData icon;
  final String label;

  const BottomNavItemConfig({required this.icon, required this.label});
}

const List<BottomNavItemConfig> kBottomNavItems = [
  BottomNavItemConfig(icon: Icons.home_outlined, label: 'Home'),
  BottomNavItemConfig(icon: Icons.event_note_outlined, label: 'Booking'),
  BottomNavItemConfig(icon: Icons.account_balance_wallet_outlined, label: 'Earning'),
  BottomNavItemConfig(icon: Icons.person_outline, label: 'Profile'),
];

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          color: Colors.white,
          elevation: 10,
          shadowColor: const Color(0x10182840),
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(kBottomNavItems.length, (index) {
              final item = kBottomNavItems[index];
              final bool isSelected = index == currentIndex;

              return _BottomNavItem(
                config: item,
                isSelected: isSelected,
                textTheme: textTheme,
                onTap: () {
                  if (!isSelected) {
                    onTabSelected(index);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final BottomNavItemConfig config;
  final bool isSelected;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.config,
    required this.isSelected,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primaryColor
        : AppColors.loginSubtitleText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              config.label,
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
