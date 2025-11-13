import 'package:flutter/material.dart';
import 'package:partner_app/core/constants/app_colors.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isConnected = true; // TODO: Implement actual connectivity checking

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: AppColors.errorColor,
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
