import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }
  
  static Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }
  
  static Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: json.encode(user.toJson()),
    );
  }
  
  static Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await ApiService.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    
    if (response.success) {
      final user = UserModel.fromJson(response.data['user']);
      await saveUser(user);
      return AuthResult.success(user);
    } else {
      return AuthResult.error(response.error ?? 'Registration failed');
    }
  }
  
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.login(
      username: username,
      password: password,
    );
    
    if (response.success) {
      final user = UserModel.fromJson(response.data['user']);
      await saveUser(user);
      return AuthResult.success(user);
    } else {
      return AuthResult.error(response.error ?? 'Login failed');
    }
  }
  
  static Future<void> logout() async {
    await ApiService.logout();
    await _storage.deleteAll();
  }
  
  static Future<AuthResult> refreshProfile() async {
    final response = await ApiService.getProfile();
    
    if (response.success) {
      final user = UserModel.fromJson(response.data);
      await saveUser(user);
      return AuthResult.success(user);
    } else {
      return AuthResult.error(response.error ?? 'Failed to refresh profile');
    }
  }
  
  static Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? fingerprintEnabled,
  }) async {
    final response = await ApiService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      profileImage: profileImage,
      fingerprintEnabled: fingerprintEnabled,
    );
    
    if (response.success) {
      final user = UserModel.fromJson(response.data['user']);
      await saveUser(user);
      return AuthResult.success(user);
    } else {
      return AuthResult.error(response.error ?? 'Failed to update profile');
    }
  }
  
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: AppConstants.biometricKey);
    return enabled == 'true';
  }
  
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricKey,
      value: enabled.toString(),
    );
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? error;
  
  AuthResult.success(this.user) : success = true, error = null;
  AuthResult.error(this.error) : success = false, user = null;
}

