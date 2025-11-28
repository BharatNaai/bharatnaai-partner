import 'package:flutter/material.dart';

enum PayoutStatus { success, pending, failed }

class PayoutItem {
  final String id;
  final DateTime date;
  final int amount;
  final PayoutStatus status;

  const PayoutItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class EarningsProvider extends ChangeNotifier {
  int _todayEarnings = 2340;
  int _weekEarnings = 8950;
  int _monthEarnings = 32400;
  int _totalEarnings = 240000; // 2.4L
  int _availableForPayout = 6200;

  final List<PayoutItem> _recentPayouts = [
    PayoutItem(
      id: 'p1',
      date: DateTime(2024, 11, 12),
      amount: 1800,
      status: PayoutStatus.success,
    ),
    PayoutItem(
      id: 'p2',
      date: DateTime(2024, 11, 10),
      amount: 2000,
      status: PayoutStatus.pending,
    ),
    PayoutItem(
      id: 'p3',
      date: DateTime(2024, 11, 7),
      amount: 1400,
      status: PayoutStatus.success,
    ),
  ];

  int get todayEarnings => _todayEarnings;
  int get weekEarnings => _weekEarnings;
  int get monthEarnings => _monthEarnings;
  int get totalEarnings => _totalEarnings;
  int get availableForPayout => _availableForPayout;
  List<PayoutItem> get recentPayouts => List.unmodifiable(_recentPayouts);

  Future<void> refreshEarnings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    notifyListeners();
  }

  Future<bool> withdrawAll() async {
    if (_availableForPayout <= 0) return false;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _availableForPayout = 0;
    notifyListeners();
    return true;
  }
}
