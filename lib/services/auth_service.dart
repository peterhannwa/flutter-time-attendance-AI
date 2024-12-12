import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      // TODO: Implement actual authentication
      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: '1',
          name: 'John Doe',
          email: email,
          role: 'Employee',
          department: 'Engineering',
          employeeId: 'EMP001',
          phone: '+1234567890',
          joinDate: DateTime(2023, 1, 1),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      // TODO: Implement actual registration
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      // TODO: Implement password reset
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  bool isAuthenticated() {
    return _currentUser != null;
  }
}
