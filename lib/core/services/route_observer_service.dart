import 'package:flutter/material.dart';

class RouteObserverService {
  static final RouteObserverService _instance = RouteObserverService._internal();
  factory RouteObserverService() => _instance;
  RouteObserverService._internal();

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
}
