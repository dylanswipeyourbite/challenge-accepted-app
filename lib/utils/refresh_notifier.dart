// lib/utils/refresh_notifier.dart

import 'package:flutter/material.dart';

class RefreshNotifier extends ChangeNotifier {
  static final RefreshNotifier _instance = RefreshNotifier._internal();
  
  factory RefreshNotifier() => _instance;
  
  RefreshNotifier._internal();
  
  void notifyHomePageRefresh() {
    notifyListeners();
  }
}