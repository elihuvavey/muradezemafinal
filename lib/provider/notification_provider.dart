import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final String time;
  final bool isRead;
  final int? productId;
  final bool isCategory;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
    this.productId,
    this.isCategory = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['body'] ?? '',
      type: json['notification_type'] ?? '',
      time: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
      productId: json['product_id'] is int
          ? json['product_id']
          : (json['product_id'] != null
              ? int.tryParse(json['product_id'].toString())
              : null),
      isCategory: json['is_category'] ?? false,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final Dio _dio = createDio();
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/mynotifications',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      print('notification response ${response.data}');
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['notifications'] ?? []);
        _notifications =
            data.map((json) => NotificationItem.fromJson(json)).toList();
      } else {
        _error = 'Failed to load notifications';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(int notificationId) {
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        time: _notifications[index].time,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }
}
