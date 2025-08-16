import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/crypto_price_model.dart';
import 'token_manager.dart';
import 'api_exceptions.dart';

class BazariApiService {
  static const String baseUrl = 'https://bazari.aygroup.app/api';
  static const Duration timeout = Duration(seconds: 30);

  // Headers for API requests
  static Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> get _authenticatedHeaders async {
    final token = await TokenManager.getActiveToken();
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle HTTP responses
  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body ?? {};
      } else {
        throw ApiException.fromResponse(response.statusCode, body);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw JsonParsingException('Failed to parse response: $e');
    }
  }

  // Helper method to make HTTP requests with error handling
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = requiresAuth ? await _authenticatedHeaders : _baseHeaders;

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return response;
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Request failed: $e');
    }
  }

  // ============================================================================
  // USER AUTHENTICATION
  // ============================================================================

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await _makeRequest('POST', '/register', body: {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'phone': phone ?? '',
    });

    final data = await _handleResponse(response);
    
    // Store the token
    if (data['token'] != null) {
      await TokenManager.storeUserToken(data['token']);
    }
    
    return data;
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _makeRequest('POST', '/login', body: {
      'username': username,
      'password': password,
    });

    final data = await _handleResponse(response);
    
    // Store the token
    if (data['token'] != null) {
      await TokenManager.storeUserToken(data['token']);
    }
    
    return data;
  }

  /// Logout user
  static Future<void> logout() async {
    await TokenManager.clearAllTokens();
  }

  // ============================================================================
  // USER PROFILE
  // ============================================================================

  /// Get user profile
  static Future<User> getUserProfile() async {
    final response = await _makeRequest('GET', '/profile', requiresAuth: true);
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  /// Update user profile
  static Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    bool? fingerprintEnabled,
  }) async {
    final body = <String, dynamic>{};
    
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (fingerprintEnabled != null) body['fingerprint_enabled'] = fingerprintEnabled;

    final response = await _makeRequest('PUT', '/profile', 
        body: body, requiresAuth: true);
    final data = await _handleResponse(response);
    
    // Update local fingerprint setting
    if (fingerprintEnabled != null) {
      await TokenManager.setFingerprintEnabled(fingerprintEnabled);
    }
    
    return User.fromJson(data);
  }

  // ============================================================================
  // WALLET MANAGEMENT
  // ============================================================================

  /// Get user wallets
  static Future<List<Wallet>> getUserWallets() async {
    final response = await _makeRequest('GET', '/wallets', requiresAuth: true);
    final data = await _handleResponse(response);
    
    if (data is List) {
      return data.map((wallet) => Wallet.fromJson(wallet)).toList();
    } else {
      throw ApiException('Invalid wallet data format');
    }
  }

  /// Get wallet balance
  static Future<Map<String, dynamic>> getWalletBalance(int walletId) async {
    final response = await _makeRequest('GET', '/wallets/$walletId/balance', 
        requiresAuth: true);
    return await _handleResponse(response);
  }

  // ============================================================================
  // TRANSACTION MANAGEMENT
  // ============================================================================

  /// Send cryptocurrency
  static Future<Map<String, dynamic>> sendCrypto({
    required String currency,
    required String toAddress,
    required double amount,
  }) async {
    final response = await _makeRequest('POST', '/transactions/send', 
        body: {
          'currency': currency,
          'to_address': toAddress,
          'amount': amount,
        }, 
        requiresAuth: true);
    
    return await _handleResponse(response);
  }

  /// Get transaction history for a wallet
  static Future<Map<String, dynamic>> getTransactionHistory({
    required int walletId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _makeRequest('GET', 
        '/wallets/$walletId/transactions?page=$page&per_page=$perPage', 
        requiresAuth: true);
    
    return await _handleResponse(response);
  }

  /// Get transaction details
  static Future<Transaction> getTransactionDetails(int transactionId) async {
    final response = await _makeRequest('GET', '/transactions/$transactionId', 
        requiresAuth: true);
    final data = await _handleResponse(response);
    return Transaction.fromJson(data);
  }

  // ============================================================================
  // MARKET DATA
  // ============================================================================

  /// Get all crypto prices
  static Future<List<CryptoPrice>> getCryptoPrices() async {
    final response = await _makeRequest('GET', '/crypto/prices');
    final data = await _handleResponse(response);
    
    if (data is List) {
      return data.map((price) => CryptoPrice.fromJson(price)).toList();
    } else {
      throw ApiException('Invalid price data format');
    }
  }

  /// Get specific crypto price
  static Future<CryptoPrice> getCryptoPrice(String symbol) async {
    final response = await _makeRequest('GET', '/crypto/price/$symbol');
    final data = await _handleResponse(response);
    return CryptoPrice.fromJson(data);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      await getCryptoPrices();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await TokenManager.getUserToken();
      if (token == null || !TokenManager.isValidToken(token)) {
        return false;
      }
      
      // Test with a simple authenticated request
      await getUserProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user data
  static Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final user = await getUserProfile();
      final wallets = await getUserWallets();
      
      return {
        'user': user.toJson(),
        'wallets': wallets.map((w) => w.toJson()).toList(),
      };
    } catch (e) {
      throw ApiException('Failed to refresh user data: $e');
    }
  }
}