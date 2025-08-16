import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static const String _userTokenKey = 'user_token';
  static const String _adminTokenKey = 'admin_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _fingerprintEnabledKey = 'fingerprint_enabled';

  // User Token Management
  static Future<void> storeUserToken(String token) async {
    try {
      await _storage.write(key: _userTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store user token: $e');
    }
  }

  static Future<String?> getUserToken() async {
    try {
      return await _storage.read(key: _userTokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUserToken() async {
    try {
      await _storage.delete(key: _userTokenKey);
    } catch (e) {
      throw Exception('Failed to clear user token: $e');
    }
  }

  // Admin Token Management
  static Future<void> storeAdminToken(String token) async {
    try {
      await _storage.write(key: _adminTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store admin token: $e');
    }
  }

  static Future<String?> getAdminToken() async {
    try {
      return await _storage.read(key: _adminTokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearAdminToken() async {
    try {
      await _storage.delete(key: _adminTokenKey);
    } catch (e) {
      throw Exception('Failed to clear admin token: $e');
    }
  }

  // Refresh Token Management
  static Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store refresh token: $e');
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to clear refresh token: $e');
    }
  }

  // Fingerprint Settings
  static Future<void> setFingerprintEnabled(bool enabled) async {
    try {
      await _storage.write(key: _fingerprintEnabledKey, value: enabled.toString());
    } catch (e) {
      throw Exception('Failed to store fingerprint setting: $e');
    }
  }

  static Future<bool> isFingerprintEnabled() async {
    try {
      final value = await _storage.read(key: _fingerprintEnabledKey);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  // Clear All Tokens
  static Future<void> clearAllTokens() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all tokens: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // Check if admin is logged in
  static Future<bool> isAdminLoggedIn() async {
    final token = await getAdminToken();
    return token != null && token.isNotEmpty;
  }

  // Get token for API requests
  static Future<String?> getActiveToken() async {
    // First try user token, then admin token
    String? token = await getUserToken();
    token ??= await getAdminToken();
    return token;
  }

  // Store multiple values at once
  static Future<void> storeLoginData({
    required String userToken,
    String? refreshToken,
    bool? fingerprintEnabled,
  }) async {
    try {
      await storeUserToken(userToken);
      
      if (refreshToken != null) {
        await storeRefreshToken(refreshToken);
      }
      
      if (fingerprintEnabled != null) {
        await setFingerprintEnabled(fingerprintEnabled);
      }
    } catch (e) {
      throw Exception('Failed to store login data: $e');
    }
  }

  // Validate token format (basic JWT validation)
  static bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    
    // Basic JWT format check (header.payload.signature)
    final parts = token.split('.');
    return parts.length == 3;
  }

  // Get all stored keys (for debugging)
  static Future<Map<String, String>> getAllStoredData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }
}