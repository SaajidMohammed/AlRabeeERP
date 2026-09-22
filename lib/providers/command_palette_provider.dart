import 'package:flutter/material.dart';

enum CommandResultType { navigation, product, customer, invoice, supplier, employee, action }

class CommandResultItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final CommandResultType type;
  final String routeOrId;
  final VoidCallback? onExecute;

  CommandResultItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.routeOrId,
    this.onExecute,
  });
}

class CommandPaletteProvider extends ChangeNotifier {
  bool _isOpen = false;
  String _query = '';

  bool get isOpen => _isOpen;
  String get query => _query;

  void open() {
    _isOpen = true;
    _query = '';
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    _query = '';
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }
}
