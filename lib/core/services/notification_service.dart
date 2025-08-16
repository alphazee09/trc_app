import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _priceAlertsKey = 'price_alerts_enabled';
  static const String _transactionAlertsKey = 'transaction_alerts_enabled';
  static const String _securityAlertsKey = 'security_alerts_enabled';
  static const String _marketNewsKey = 'market_news_enabled';

  // Price alert settings
  static Future<void> setPriceAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_priceAlertsKey, enabled);
  }

  static Future<bool> isPriceAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_priceAlertsKey) ?? true;
  }

  // Transaction alert settings
  static Future<void> setTransactionAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_transactionAlertsKey, enabled);
  }

  static Future<bool> isTransactionAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_transactionAlertsKey) ?? true;
  }

  // Security alert settings
  static Future<void> setSecurityAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_securityAlertsKey, enabled);
  }

  static Future<bool> isSecurityAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_securityAlertsKey) ?? true;
  }

  // Market news settings
  static Future<void> setMarketNewsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketNewsKey, enabled);
  }

  static Future<bool> isMarketNewsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_marketNewsKey) ?? false;
  }

  // Get all notification settings
  static Future<Map<String, bool>> getAllSettings() async {
    return {
      'priceAlerts': await isPriceAlertsEnabled(),
      'transactionAlerts': await isTransactionAlertsEnabled(),
      'securityAlerts': await isSecurityAlertsEnabled(),
      'marketNews': await isMarketNewsEnabled(),
    };
  }

  // Simulated notification methods (since we don't have real push notifications)
  static void showPriceAlert(String currency, double currentPrice, double previousPrice) {
    if (kDebugMode) {
      final change = ((currentPrice - previousPrice) / previousPrice * 100);
      print('🔔 Price Alert: $currency is ${change > 0 ? 'up' : 'down'} ${change.abs().toStringAsFixed(2)}%');
      print('   Current: \$${currentPrice.toStringAsFixed(2)}');
    }
  }

  static void showTransactionAlert(String type, String currency, double amount) {
    if (kDebugMode) {
      print('🔔 Transaction Alert: $type $amount $currency');
    }
  }

  static void showSecurityAlert(String message) {
    if (kDebugMode) {
      print('🔒 Security Alert: $message');
    }
  }

  static void showMarketNews(String headline) {
    if (kDebugMode) {
      print('📰 Market News: $headline');
    }
  }

  // Simulated price monitoring
  static void startPriceMonitoring(List<String> currencies) {
    if (kDebugMode) {
      print('📊 Started monitoring prices for: ${currencies.join(', ')}');
    }
  }

  static void stopPriceMonitoring() {
    if (kDebugMode) {
      print('📊 Stopped price monitoring');
    }
  }

  // Mock notification for demonstration
  static Future<void> sendTestNotification(String title, String message) async {
    if (kDebugMode) {
      print('🔔 Test Notification:');
      print('   Title: $title');
      print('   Message: $message');
    }
    
    // In a real app, this would trigger the actual notification
    // For now, we'll just simulate it
    await Future.delayed(const Duration(milliseconds: 500));
  }
}