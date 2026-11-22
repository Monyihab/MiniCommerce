import 'package:flutter/material.dart';
import 'product.dart';

const double shippingFee = 50;
const String shippingName = 'AAST Express delivery';
const String discountCode = 'AAST10';
const double discountRate = 0.10;

String egp(double value) => '${value.toStringAsFixed(0)} EGP';

class UserSession {
  static String name = 'Guest';
  static String email = '';
  static String address = '';
  static bool notifications = true;

  static void signIn(String emailInput) {
    email = emailInput.trim();
    name = _nameFromEmail(email);
  }

  static void signOut() {
    name = 'Guest';
    email = '';
    address = '';
    notifications = true;
    orderHistory.clear();
  }

  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local
        .split(RegExp(r'[._\-+]+'))
        .map((p) => p.replaceAll(RegExp(r'[0-9]'), ''))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'Student';
    }

    return parts
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join(' ');
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, {this.quantity = 1});

  double get total => product.price * quantity;
}

class OrderSummary {
  final String number;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final String? code;

  const OrderSummary({
    required this.number,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    this.code,
  });

  int get itemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);
}

final List<OrderSummary> orderHistory = [];

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _appliedCode;

  List<CartItem> get items => List.unmodifiable(_items);

  String? get appliedCode => _appliedCode;

  bool get isEmpty => _items.isEmpty;

  int get itemCount =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);

  double get discount => _appliedCode == null ? 0 : subtotal * discountRate;

  double get shipping => _items.isEmpty ? 0 : shippingFee;

  double get total => subtotal - discount + shipping;

  void add(Product product) {
    final index = _items.indexWhere((i) => i.product.name == product.name);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product));
    }
    notifyListeners();
  }

  void increase(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrease(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  bool applyCode(String input) {
    if (input.trim().toUpperCase() == discountCode) {
      _appliedCode = discountCode;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCode() {
    _appliedCode = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _appliedCode = null;
    notifyListeners();
  }
}

final Cart cart = Cart();