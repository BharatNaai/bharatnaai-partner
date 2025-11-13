import 'package:flutter/material.dart';

class WelcomeProvider extends ChangeNotifier {
  int _currentPage = 0;
  int _currentIndex = 0;
  bool _isFirstTime = true;

  // Getters
  int get currentPage => _currentPage;
  int get currentIndex => _currentIndex;
  bool get isFirstTime => _isFirstTime;

  // Set current page
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Set current index (for carousel)
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Mark as not first time
  void markAsNotFirstTime() {
    _isFirstTime = false;
    notifyListeners();
  }

  // Reset welcome state
  void reset() {
    _currentPage = 0;
    _currentIndex = 0;
    _isFirstTime = true;
    notifyListeners();
  }
}
