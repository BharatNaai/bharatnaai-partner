import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../widgets/no_internet_dialog.dart';
import '../utils/navigator_key.dart';


class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isDialogShowing = false;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // Initial check
    checkCurrentStatus();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> checkCurrentStatus() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If any result is not 'none', we assume we have connection
    final hasConnection = results.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      _showNoInternetDialog();
    } else {
      _hideNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;

    final context = NavigatorService.context;
    if (context == null) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NoInternetDialog(),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _hideNoInternetDialog() {
    if (!_isDialogShowing) return;

    final context = NavigatorService.context;
    if (context == null) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _isDialogShowing = false;
  }
}
