import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_colors.dart';

class AppUtils {
  static void showSnack(
      BuildContext context,
      String msg, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: AppColors.white)),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        // Top margin added
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> checkRecordPermission() async {
    final micStatus = await Permission.microphone.status;
    return micStatus == PermissionStatus.granted;
  }

  // Function to check storage permission based on Android version
  static Future<bool> checkStoragePermission() async {
    PermissionStatus? storageStatus;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      String release = androidInfo.version.release;

      if (int.parse(release) >= 13) {
        storageStatus = await Permission.audio.status;
      } else {
        storageStatus = await Permission.storage.status;
      }
    } else if (Platform.isIOS) {
      storageStatus = await Permission.storage.status;
    }

    return storageStatus == PermissionStatus.granted;
  }

  // Function to request storage permission based on Android version
  static Future<bool> requestStoragePermission() async {
    PermissionStatus? storageStatus;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      String release = androidInfo.version.release;

      if (int.parse(release) >= 13) {
        storageStatus = await Permission.audio.status;

        if (storageStatus != PermissionStatus.granted) {
          storageStatus = await Permission.audio.request();
        }
      } else {
        storageStatus = await Permission.storage.status;

        if (storageStatus != PermissionStatus.granted) {
          storageStatus = await Permission.storage.request();
        }
      }
    } else {
      storageStatus = await Permission.storage.status;

      if (storageStatus != PermissionStatus.granted) {
        storageStatus = await Permission.storage.request();
      }
    }

    if (storageStatus == PermissionStatus.permanentlyDenied) {
      _openAppSettings();
    }

    return storageStatus == PermissionStatus.granted;
  }

  static _openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      /* ScaffoldMessenger.of(z).showSnackBar(
        SnackBar(
          content: Text('Please manually enable microphone permission in device settings'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );*/
    }
  }

  /// Format ISO date string to a user-friendly format
  static String formatDate(String? isoDateString) {
    if (isoDateString == null || isoDateString.isEmpty) {
      return 'Unknown';
    }

    try {
      final date = DateTime.parse(isoDateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        // Today
        return 'Today';
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Within a week
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        // Within a month
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks == 1 ? '' : 's'} ago';
      } else {
        // More than a month ago
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return 'Unknown';
    }
  }
}
