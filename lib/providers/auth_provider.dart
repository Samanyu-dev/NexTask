import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _initializing = true;
  bool _busy = false;
  String? _token;

  bool get initializing => _initializing;
  bool get busy => _busy;
  bool get isAuthenticated => (_token ?? '').isNotEmpty;
  String? get token => _token;

  Future<void> initialize() async {
    _token = await _authService.readToken();
    _initializing = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _setBusy(true);
    try {
      _token = await _authService.login(email: email, password: password);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      await _authService.register(name: name, email: email, password: password);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setBusy(true);
    try {
      await _authService.clearToken();
      _token = null;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
