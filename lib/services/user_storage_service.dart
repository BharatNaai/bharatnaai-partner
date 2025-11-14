import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:partner_app/models/user_model.dart';

class UserStorageService {
  static const String _userKey = 'user_data';
  static const String _accessTokenKey = 'access_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _refreshTokenKey = 'refresh_token';

  // Callback for when user data is cleared
  static VoidCallback? _onDataCleared;

  // Save user data to shared preferences
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    // Save user data as JSON string
    final userWithDefaults = user.copyWith(
      ehrSoftware: user.ehrSoftware ?? '',
      fhirBaseUrl: user.fhirBaseUrl ?? '',
    );
    final userJson = jsonEncode(userWithDefaults.toJson());
    debugPrint('User JSON: $userJson');
    await prefs.setString(_userKey, userJson);

    // Save access token separately for easy access
    if (userWithDefaults.accessToken != null) {
      await prefs.setString(_accessTokenKey, userWithDefaults.accessToken!);
      debugPrint('Access token saved separately');
    }
    // Save refresh token separately for easy access
    if (userWithDefaults.refreshToken != null) {
      await prefs.setString(_refreshTokenKey, userWithDefaults.refreshToken!);
      debugPrint('Refresh token saved separately');
    }

    // Mark user as logged in
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get user data from shared preferences
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        return user;
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    debugPrint('No user data found in shared preferences');
    return null;
  }

  // Get access token from shared preferences
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  // Get refresh token from shared preferences
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Update user data (partial update)
  static Future<void> updateUser(UserModel updatedUser) async {
    final currentUser = await getUser();
    if (currentUser != null) {
      // Merge current user data with updated data
      final mergedUser = currentUser.copyWith(
        userSub: updatedUser.userSub ?? currentUser.userSub,
        email: updatedUser.email ?? currentUser.email,
        stripeCustomerId: updatedUser.stripeCustomerId ?? currentUser.stripeCustomerId,
        emailVerified: updatedUser.emailVerified ?? currentUser.emailVerified,
        phoneVerified: updatedUser.phoneVerified ?? currentUser.phoneVerified,
        groupType: updatedUser.groupType ?? currentUser.groupType,
        groupId: updatedUser.groupId ?? currentUser.groupId,
        accessToken: updatedUser.accessToken ?? currentUser.accessToken,
        refreshToken: updatedUser.refreshToken ?? currentUser.refreshToken,
        firstName: updatedUser.firstName ?? currentUser.firstName,
        lastName: updatedUser.lastName ?? currentUser.lastName,
        phoneNumber: updatedUser.phoneNumber ?? currentUser.phoneNumber,
        profession: updatedUser.profession ?? currentUser.profession,
        ehrSoftware: updatedUser.ehrSoftware ?? currentUser.ehrSoftware,
        practiceName: updatedUser.practiceName ?? currentUser.practiceName,
        practicePhoneNumber: updatedUser.practicePhoneNumber ?? currentUser.practicePhoneNumber,
        onboardingCompleted: updatedUser.onboardingCompleted ?? currentUser.onboardingCompleted,
        isMfaEnabled: updatedUser.isMfaEnabled ?? currentUser.isMfaEnabled,
      );
      await saveUser(mergedUser);
    } else {
      // If no current user, save the new user data
      await saveUser(updatedUser);
    }
  }

  // Update access token only
  static Future<void> updateAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);

    // Also update in user data
    final currentUser = await getUser();
    if (currentUser != null) {
      await updateUser(currentUser.copyWith(accessToken: accessToken));
    }
  }
  // Update access token only
  static Future<void> updateRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);

    // Also update in user data
    final currentUser = await getUser();
    if (currentUser != null) {
      await updateUser(currentUser.copyWith(refreshToken: refreshToken));
    }
  }

  // Clear all user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);
    debugPrint('UserStorageService: All user data cleared');

    // Notify callback if set
    _onDataCleared?.call();
  }

  // Set callback for when user data is cleared
  static void setOnDataClearedCallback(VoidCallback? callback) {
    _onDataCleared = callback;
  }

  // Get user ID (userSub)
  static Future<String?> getUserId() async {
    final user = await getUser();
    return user?.userSub;
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final user = await getUser();
    return user?.email;
  }

  // Check if email is verified
  static Future<bool> isEmailVerified() async {
    final user = await getUser();
    return user?.emailVerified ?? false;
  }

  // Check if phone is verified
  static Future<bool> isPhoneVerified() async {
    final user = await getUser();
    return user?.phoneVerified ?? false;
  }

  // Get user group type
  static Future<String?> getUserGroupType() async {
    final user = await getUser();
    return user?.groupType;
  }

  // Get Stripe customer ID
  static Future<String?> getStripeCustomerId() async {
    final user = await getUser();
    return user?.stripeCustomerId;
  }

  // Get group ID
  static Future<String?> getGroupId() async {
    debugPrint('=== UserStorageService.getGroupId Debug ===');
    final user = await getUser();
    debugPrint('Retrieved user for groupId: $user');
    debugPrint('User groupId: ${user?.groupId}');
    debugPrint('User groupType: ${user?.groupType}');
    return user?.groupId;
  }

  // Get onboarding status
  static Future<bool> getOnboardingStatus() async {
    final user = await getUser();
    return user?.onboardingCompleted ?? false;
  }

  // Update onboarding status
  static Future<void> updateOnboardingStatus(bool completed) async {
    final currentUser = await getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(onboardingCompleted: completed);
      await saveUser(updatedUser);
      debugPrint('Onboarding status updated to: $completed');
    } else {
      debugPrint('No current user found, cannot update onboarding status');
    }
  }

  // Get MFA status
  static Future<bool> getMfaStatus() async {
    final user = await getUser();
    return user?.isMfaEnabled ?? false;
  }

  // Update MFA status
  static Future<void> updateMfaStatus(bool isEnabled) async {
    final currentUser = await getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(isMfaEnabled: isEnabled);
      await saveUser(updatedUser);
      debugPrint('MFA status updated to: $isEnabled');
    } else {
      debugPrint('No current user found, cannot update MFA status');
    }
  }
}