import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = AppConstants.baseUrl;
  
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  static Future<ApiResponse> _handleResponse(http.Response response) async {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(data);
      } else {
        final message = data['message'] ?? 'Unknown error occurred';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response', response.statusCode);
    }
  }
  
  // Authentication APIs
  static Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        }),
      );
      
      final result = await _handleResponse(response);
      if (result.success && result.data['token'] != null) {
        await _storage.write(key: AppConstants.tokenKey, value: result.data['token']);
      }
      
      return result;
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      final result = await _handleResponse(response);
      if (result.success && result.data['token'] != null) {
        await _storage.write(key: AppConstants.tokenKey, value: result.data['token']);
      }
      
      return result;
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }
  
  // Profile APIs
  static Future<ApiResponse> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? fingerprintEnabled,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (profileImage != null) body['profile_image'] = profileImage;
      if (fingerprintEnabled != null) body['fingerprint_enabled'] = fingerprintEnabled;
      
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Wallet APIs
  static Future<ApiResponse> getWallets() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wallets'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> getWalletByCurrency(String currency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wallets/$currency'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Transaction APIs
  static Future<ApiResponse> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> getTransactionsByCurrency(String currency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions/$currency'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> sendCrypto({
    required String currency,
    required double amount,
    required String toAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: await _getHeaders(),
        body: json.encode({
          'currency': currency,
          'amount': amount,
          'to_address': toAddress,
        }),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // KYC APIs
  static Future<ApiResponse> submitKYC({
    required String documentType,
    required String documentNumber,
    required String documentFront,
    String? documentBack,
    required String selfieImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kyc'),
        headers: await _getHeaders(),
        body: json.encode({
          'document_type': documentType,
          'document_number': documentNumber,
          'document_front': documentFront,
          'document_back': documentBack,
          'selfie_image': selfieImage,
        }),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  static Future<ApiResponse> getKYCStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/kyc/status'),
        headers: await _getHeaders(),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Crypto Prices API
  static Future<ApiResponse> getCryptoPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/crypto/prices'),
        headers: await _getHeaders(includeAuth: false),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Admin APIs (for testing)
  static Future<ApiResponse> adminSendCrypto({
    required int userId,
    required String currency,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/send'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'admin_key': AppConstants.adminKey,
          'user_id': userId,
          'currency': currency,
          'amount': amount,
        }),
      );
      
      return await _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;
  
  ApiResponse.success(this.data) : success = true, error = null, statusCode = null;
  ApiResponse.error(this.error, [this.statusCode]) : success = false, data = null;
}

