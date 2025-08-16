import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/bazari_api_service.dart';
import '../core/services/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      _isLoggedIn = await TokenManager.isUserLoggedIn();
      if (_isLoggedIn) {
        // Try to get user profile if token exists
        final isAuthenticated = await BazariApiService.isAuthenticated();
        if (isAuthenticated) {
          _user = await BazariApiService.getUserProfile();
          _isLoggedIn = true;
        } else {
          _isLoggedIn = false;
          await TokenManager.clearAllTokens();
        }
      }
    } catch (e) {
      _isLoggedIn = false;
      _setError('Failed to initialize authentication');
    }
    
    _setLoading(false);
  }

  void setUser(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    _isLoggedIn = true;
    _clearError();
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    _isLoggedIn = true;
    _clearError();
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await BazariApiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    _user = null;
    _isLoggedIn = false;
    _clearError();
    _setLoading(false);
  }

  Future<void> refreshUserProfile() async {
    try {
      if (_isLoggedIn) {
        _user = await BazariApiService.getUserProfile();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh user profile');
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    bool? fingerprintEnabled,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await BazariApiService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        fingerprintEnabled: fingerprintEnabled,
      );
      
      _user = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  void clearData() {
    _user = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
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
  }

  // Helper getters for UI
  String get userDisplayName {
    if (_user != null) {
      return _user!.fullName;
    }
    return 'User';
  }

  String get userInitials {
    if (_user != null) {
      if (_user!.firstName != null && _user!.lastName != null) {
        return '${_user!.firstName![0]}${_user!.lastName![0]}'.toUpperCase();
      } else if (_user!.firstName != null) {
        return _user!.firstName![0].toUpperCase();
      } else {
        return _user!.username[0].toUpperCase();
      }
    }
    return 'U';
  }

  bool get isFingerprintEnabled {
    return _user?.fingerprintEnabled ?? false;
  }

  bool get isVerified {
    return _user?.isVerified ?? false;
  }

  bool get isBlocked {
    return _user?.isBlocked ?? false;
  }
}

