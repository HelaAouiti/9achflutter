// lib/services/cart.service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}

class CartService extends ChangeNotifier {
  static const String _boxName = 'cartBox';
  static const String _key = 'cartItems';

  late Box<List> _box;
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity));

  bool _isInitialized = false;

  CartService() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<List>(_boxName);
    await _loadFromHive();
    _isInitialized = true;
  }

  Future<void> _loadFromHive() async {
    final saved = _box.get(_key);
    if (saved != null && saved is List) {
      try {
        _items = saved
            .cast<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map((e) => CartItem.fromJson(e))
            .toList();
      } catch (e) {
        _items = [];
      }
    } else {
      _items = [];
    }
    if (_isInitialized) notifyListeners(); // Évite notify avant init
  }

  Future<void> _saveToHive() async {
    if (!_isInitialized) return;
    final data = _items.map((item) => item.toJson()).toList();
    await _box.put(_key, data);
  }

  // Public methods — tous attendent l'initialisation si besoin
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (!_isInitialized) await _init();

    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveToHive();
    notifyListeners();
  }

  Future<void> updateQuantity(Product product, int newQuantity) async {
    if (!_isInitialized) await _init();

    if (newQuantity <= 0) {
      await removeFromCart(product);
      return;
    }

    final item =
        _items.firstWhereOrNull((item) => item.product.id == product.id);
    if (item != null) {
      item.quantity = newQuantity;
      await _saveToHive();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(Product product) async {
    if (!_isInitialized) await _init();

    _items.removeWhere((item) => item.product.id == product.id);
    await _saveToHive();
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  Future<void> clearCart() async {
    if (!_isInitialized) await _init();

    _items.clear();
    await _saveToHive();
    notifyListeners();
  }
}

// Extension utile pour firstWhereOrNull (Dart 2.19+)
extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
