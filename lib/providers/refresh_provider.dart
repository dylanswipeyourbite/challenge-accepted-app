// lib/providers/refresh_provider.dart

import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  void refreshHomePage() {
    notifyListeners();
  }
}