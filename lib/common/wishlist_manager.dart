import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/home/furniture_model.dart';

class WishlistManager extends ChangeNotifier {
  WishlistManager._();
  static final WishlistManager instance = WishlistManager._();

  static const String _storageKey = 'wishlist_items';

  final List<FurnitureModel> _items = [];

  List<FurnitureModel> get items => List.unmodifiable(_items);

  bool isWishlisted(FurnitureModel item) {
    return _items.any((e) => e.name == item.name);
  }

  Future<void> toggle(FurnitureModel item) async {
    if (isWishlisted(item)) {
      _items.removeWhere((e) => e.name == item.name);
    } else {
      _items.add(item);
    }
    await _saveToStorage();
    notifyListeners();
  }

  /// 🔥 LOAD wishlist on app start
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return;

    final List decoded = json.decode(jsonString);
    _items
      ..clear()
      ..addAll(decoded.map((e) => FurnitureModel.fromJson(e)));

    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
