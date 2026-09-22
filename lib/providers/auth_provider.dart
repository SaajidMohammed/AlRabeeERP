import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/mock/mock_erp_database.dart';

class AuthProvider extends ChangeNotifier {
  final MockErpDatabase _db = MockErpDatabase();

  UserModel? _currentUser;
  bool _isAuthenticated = true; // Auto-logged in for prototype demo

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  UserRole get currentRole => _currentUser?.role ?? UserRole.superAdmin;

  AuthProvider() {
    // Default to Super Admin demo persona
    _currentUser = _db.getUsers().first;
  }

  void switchDemoRole(UserRole role) {
    final users = _db.getUsers();
    final matchedUser = users.firstWhere(
      (u) => u.role == role,
      orElse: () => users.first,
    );
    _currentUser = matchedUser;
    _isAuthenticated = true;
    _db.logAudit(
      _currentUser!.name,
      _currentUser!.role.label,
      'ROLE_SWITCH',
      'Auth',
      'Switched demo persona to ${role.label}',
    );
    notifyListeners();
  }

  void login(String email, String password) {
    final users = _db.getUsers();
    final matched = users.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => users.first,
    );
    _currentUser = matched;
    _isAuthenticated = true;
    _db.logAudit(
      _currentUser!.name,
      _currentUser!.role.label,
      'LOGIN_SUCCESS',
      'Auth',
      'Logged in via email $email',
    );
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  bool hasPermission(String moduleName, {bool requiresEdit = false, bool requiresApprove = false}) {
    if (_currentUser == null) return false;
    final permissions = UserModel.getPermissionsForRole(_currentUser!.role);
    final perm = permissions.firstWhere(
      (p) => p.module.toLowerCase() == moduleName.toLowerCase(),
      orElse: () => const UserPermission(module: ''),
    );
    if (!perm.view) return false;
    if (requiresEdit && !perm.edit && !perm.create) return false;
    if (requiresApprove && !perm.approve) return false;
    return true;
  }
}
