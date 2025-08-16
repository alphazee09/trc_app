import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/crypto_price_model.dart';
import 'api_service.dart';

class WalletService {
  static const _storage = FlutterSecureStorage();
  
  static Future<List<Wallet>> getWallets() async {
    final response = await ApiService.getWallets();
    
    if (response.success) {
      final List<dynamic> walletsJson = response.data;
      final wallets = walletsJson.map((json) => Wallet.fromJson(json)).toList();
      await _saveWallets(wallets);
      return wallets;
    } else {
      // Return cached wallets if API fails
      return await _getCachedWallets();
    }
  }
  
  static Future<Wallet?> getWalletByCurrency(String currency) async {
    final response = await ApiService.getWalletByCurrency(currency);
    
    if (response.success) {
      return Wallet.fromJson(response.data);
    }
    return null;
  }
  
  static Future<List<Transaction>> getTransactions() async {
    final response = await ApiService.getTransactions();
    
    if (response.success) {
      final List<dynamic> transactionsJson = response.data;
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<List<Transaction>> getTransactionsByCurrency(String currency) async {
    final response = await ApiService.getTransactionsByCurrency(currency);
    
    if (response.success) {
      final List<dynamic> transactionsJson = response.data;
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<WalletResult> sendCrypto({
    required String currency,
    required double amount,
    required String toAddress,
  }) async {
    final response = await ApiService.sendCrypto(
      currency: currency,
      amount: amount,
      toAddress: toAddress,
    );
    
    if (response.success) {
      final transaction = Transaction.fromJson(response.data['transaction']);
      return WalletResult.success(transaction: transaction);
    } else {
      return WalletResult.error(response.error ?? 'Transaction failed');
    }
  }
  
  static Future<List<CryptoPrice>> getCryptoPrices() async {
    final response = await ApiService.getCryptoPrices();
    
    if (response.success) {
      final List<dynamic> pricesJson = response.data;
      final prices = pricesJson.map((json) => CryptoPrice.fromJson(json)).toList();
      await _savePrices(prices);
      return prices;
    } else {
      // Return cached prices if API fails
      return await _getCachedPrices();
    }
  }
  
  static Future<void> _saveWallets(List<Wallet> wallets) async {
    final walletsJson = wallets.map((wallet) => wallet.toJson()).toList();
    await _storage.write(
      key: '${AppConstants.walletKey}_wallets',
      value: json.encode(walletsJson),
    );
  }
  
  static Future<List<Wallet>> _getCachedWallets() async {
    final walletsJson = await _storage.read(key: '${AppConstants.walletKey}_wallets');
    if (walletsJson != null) {
      final List<dynamic> walletsList = json.decode(walletsJson);
      return walletsList.map((json) => Wallet.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<void> _savePrices(List<CryptoPrice> prices) async {
    final pricesJson = prices.map((price) => price.toJson()).toList();
    await _storage.write(
      key: '${AppConstants.walletKey}_prices',
      value: json.encode(pricesJson),
    );
  }
  
  static Future<List<CryptoPrice>> _getCachedPrices() async {
    final pricesJson = await _storage.read(key: '${AppConstants.walletKey}_prices');
    if (pricesJson != null) {
      final List<dynamic> pricesList = json.decode(pricesJson);
      return pricesList.map((json) => CryptoPrice.fromJson(json)).toList();
    }
    return [];
  }
  
  static String formatCurrency(double amount, {int decimals = 8}) {
    return amount.toStringAsFixed(decimals).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  
  static String formatUSD(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }
  
  static bool isValidAddress(String address, String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return RegExp(AppConstants.btcAddressPattern).hasMatch(address);
      case 'USDT':
      case 'ETH':
        return RegExp(AppConstants.ethAddressPattern).hasMatch(address);
      default:
        return false;
    }
  }
}

class WalletResult {
  final bool success;
  final Transaction? transaction;
  final String? error;
  
  WalletResult.success({this.transaction}) : success = true, error = null;
  WalletResult.error(this.error) : success = false, transaction = null;
}

// Duplicate CryptoPriceModel definition was removed; use CryptoPrice from core/models instead.

