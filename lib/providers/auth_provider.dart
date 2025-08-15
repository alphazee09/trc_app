import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/biometric_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      _isLoggedIn = await AuthService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await AuthService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
    }
    
    _setLoading(false);
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      
      if (result.success) {
        _user = result.user;
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );
      
      if (result.success) {
        _user = result.user;
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> authenticateWithBiometric() async {
    if (_user == null || !_user!.fingerprintEnabled) {
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await BiometricService.authenticate(
        localizedReason: 'Authenticate to access your Alphazee09 wallet',
      );
      
      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Biometric authentication failed');
        return false;
      }
    } catch (e) {
      _setError('Biometric authentication failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await AuthService.logout();
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    }
    
    _setLoading(false);
  }
  
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? fingerprintEnabled,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profileImage: profileImage,
        fingerprintEnabled: fingerprintEnabled,
      );
      
      if (result.success) {
        _user = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<void> refreshProfile() async {
    if (!_isLoggedIn) return;
    
    try {
      final result = await AuthService.refreshProfile();
      if (result.success) {
        _user = result.user;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for refresh
    }
  }
  
  Future<bool> enableBiometric() async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        _setError('Biometric authentication is not available on this device');
        return false;
      }
      
      final result = await BiometricService.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      
      if (result.success) {
        final updateResult = await updateProfile(fingerprintEnabled: true);
        if (updateResult) {
          await AuthService.setBiometricEnabled(true);
          return true;
        }
      } else {
        _setError(result.error ?? 'Biometric authentication failed');
      }
      
      return false;
    } catch (e) {
      _setError('Failed to enable biometric authentication: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> disableBiometric() async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final updateResult = await updateProfile(fingerprintEnabled: false);
      if (updateResult) {
        await AuthService.setBiometricEnabled(false);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to disable biometric authentication: ${e.toString()}');
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }
}

