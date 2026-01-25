import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// 🔔 NOTIFICATION MODEL
/// ============================================================
class AppNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime time;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.time,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      data: data,
      time: time,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'data': data,
    'time': time.toIso8601String(),
    'read': read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      read: json['read'] ?? false,
    );
  }
}

/// ============================================================
/// 🔔 NOTIFICATION MANAGER (SINGLE SOURCE OF TRUTH)
/// ============================================================
class NotificationManager extends ChangeNotifier {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();

  static const _storageKey = 'stored_notifications';
  static const _enabledKey = 'notifications_enabled';

  /// Prevent unlimited growth
  static const int _maxNotifications = 100;

  final List<AppNotification> _notifications = [];
  bool _enabled = true;

  /* ================= GETTERS ================= */

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  bool get hasNotifications => _notifications.isNotEmpty;

  int get count => _notifications.length;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  bool get enabled => _enabled;

  /* ================= LOAD FROM STORAGE ================= */

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    _enabled = prefs.getBool(_enabledKey) ?? true;

    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List;
        _notifications
          ..clear()
          ..addAll(
            decoded
                .map(
                  (e) => AppNotification.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(),
          );
      } catch (_) {
        _notifications.clear();
      }
    }

    notifyListeners();
  }

  /* ================= ADD NOTIFICATION ================= */

  Future<void> add({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    if (!_enabled) return;

    final id = data['id'] ?? '${DateTime.now().millisecondsSinceEpoch}';

    // 🔁 Deduplication
    if (_notifications.any((n) => n.id == id)) return;

    final notification = AppNotification(
      id: id,
      title: title,
      body: body,
      data: data,
      time: DateTime.now(),
    );

    _notifications.insert(0, notification);

    // 🧹 Limit storage size
    if (_notifications.length > _maxNotifications) {
      _notifications.removeLast();
    }

    await _save();
    notifyListeners();
  }

  /* ================= MARK AS READ ================= */

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(read: true);

    await _save();
    notifyListeners();
  }

  /* ================= CLEAR ALL ================= */

  Future<void> clear() async {
    _notifications.clear();
    await _save();
    notifyListeners();
  }

  /* ================= ENABLE / DISABLE ================= */

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    notifyListeners();
  }

  /* ================= LOGOUT RESET ================= */

  /// 🔥 MUST be called on logout
  Future<void> resetOnLogout() async {
    _notifications.clear();
    _enabled = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.setBool(_enabledKey, true);

    notifyListeners();
  }

  /* ================= SAVE ================= */

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_notifications.map((e) => e.toJson()).toList()),
    );
  }
}
