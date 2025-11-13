import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _currentRoute = '/';

  // Getters
  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;

  // Set current tab index
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Set current route
  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  // Navigate to specific tab
  void navigateToTab(int index) {
    setCurrentIndex(index);
  }

  // Reset navigation state
  void reset() {
    _currentIndex = 0;
    _currentRoute = '/';
    notifyListeners();
  }
}
