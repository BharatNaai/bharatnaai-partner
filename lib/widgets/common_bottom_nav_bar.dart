import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../routes/app_routes.dart';

class BottomNavItemConfig {
  final IconData icon;
  final String label;
  final String route;

  const BottomNavItemConfig({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<BottomNavItemConfig> kBottomNavItems = [
  BottomNavItemConfig(
    icon: Icons.home_outlined,
    label: 'Home',
    route: AppRoutes.home,
  ),
  BottomNavItemConfig(
    icon: Icons.search,
    label: 'Search',
    route: AppRoutes.booking,
  ),
  BottomNavItemConfig(
    icon: Icons.history,
    label: 'History',
    route: AppRoutes.earning,
  ),
  BottomNavItemConfig(
    icon: Icons.person_outline,
    label: 'Profile',
    route: AppRoutes.profile,
  ),
];

class CommonBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const CommonBottomNavBar({super.key, required this.currentRoute});

  int get _currentIndex {
    final index = kBottomNavItems.indexWhere((e) => e.route == currentRoute);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(
                color: Colors.white,
                elevation: 10,
                shadowColor: const Color(0x10182840),
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(kBottomNavItems.length, (index) {
                    final item = kBottomNavItems[index];
                    final bool isSelected = index == _currentIndex;

                    return _BottomNavItem(
                      config: item,
                      isSelected: isSelected,
                      textTheme: textTheme,
                      onTap: () {
                        if (!isSelected) {
                          AppRoutes.navigateTo(context, item.route);
                        }
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _FloatingAddButton(
              onTap: () => AppRoutes.navigateTo(context, AppRoutes.add),
            ),
          ),
        ],
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
    final color = isSelected ? AppColors.primaryColor : AppColors.loginSubtitleText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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

class _FloatingAddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingAddButton({required this.onTap});

  @override
  State<_FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<_FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 - _controller.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Material(
          elevation: 10,
          shape: const CircleBorder(),
          shadowColor: const Color(0x30182840),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.buttonPrimary,
            ),
            child: Center(
              child: Text(
                '+',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
