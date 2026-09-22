import 'package:flutter/material.dart';

enum ToastType { success, warning, error, info }

class ToastItem {
  final String id;
  final ToastType type;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final DateTime createdAt;

  ToastItem({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(milliseconds: 3500),
  }) : createdAt = DateTime.now();
}

class ToastService extends ChangeNotifier {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  final List<ToastItem> _toasts = [];
  List<ToastItem> get toasts => List.unmodifiable(_toasts);

  void show({
    required ToastType type,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    final item = ToastItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );

    _toasts.add(item);
    notifyListeners();

    Future.delayed(duration, () {
      remove(item.id);
    });
  }

  void success(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.success,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void warning(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.warning,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void error(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.error,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void info(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.info,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void remove(String id) {
    final index = _toasts.indexWhere((t) => t.id == id);
    if (index != -1) {
      _toasts.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    _toasts.clear();
    notifyListeners();
  }
}
