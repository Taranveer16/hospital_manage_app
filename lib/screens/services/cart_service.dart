// lib/services/cart_service.dart
// GLOBAL CART SERVICE - Allows selecting tests from multiple categories
import 'package:flutter/foundation.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<Map<String, dynamic>> _selectedTests = [];

  List<Map<String, dynamic>> get selectedTests => _selectedTests;

  int get itemCount => _selectedTests.length;

  bool get isEmpty => _selectedTests.isEmpty;

  double get totalPrice {
    return _selectedTests.fold(0.0, (sum, test) => sum + (test['price'] as num? ?? 0));
  }

  int get totalDuration {
    return _selectedTests.fold(0, (sum, test) => sum + (test['avg_duration_minutes'] as int? ?? 0));
  }

  bool isTestSelected(String testId) {
    return _selectedTests.any((test) => test['id'] == testId);
  }

  void addTest(Map<String, dynamic> test) {
    if (!isTestSelected(test['id'])) {
      _selectedTests.add(test);
      notifyListeners();
      print('✅ Test added to cart: ${test['name']} (Total: $_selectedTests.length)');
    }
  }

  void removeTest(String testId) {
    _selectedTests.removeWhere((test) => test['id'] == testId);
    notifyListeners();
    print('❌ Test removed from cart (Remaining: $_selectedTests.length)');
  }

  void toggleTest(Map<String, dynamic> test) {
    if (isTestSelected(test['id'])) {
      removeTest(test['id']);
    } else {
      addTest(test);
    }
  }

  void clear() {
    _selectedTests.clear();
    notifyListeners();
    print('🗑️ Cart cleared');
  }

  List<String> getTestIds() {
    return _selectedTests.map((test) => test['id'] as String).toList();
  }
}