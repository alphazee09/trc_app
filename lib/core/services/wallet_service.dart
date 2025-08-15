import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class WalletService {
  static const _storage = FlutterSecureStorage();
  
  static Future<List<WalletModel>> getWallets() async {
    final response = await ApiService.getWallets();
    
    if (response.success) {
      final List<dynamic> walletsJson = response.data;
      final wallets = walletsJson.map((json) => WalletModel.fromJson(json)).toList();
      await _saveWallets(wallets);
      return wallets;
    } else {
      // Return cached wallets if API fails
      return await _getCachedWallets();
    }
  }
  
  static Future<WalletModel?> getWalletByCurrency(String currency) async {
    final response = await ApiService.getWalletByCurrency(currency);
    
    if (response.success) {
      return WalletModel.fromJson(response.data);
    }
    return null;
  }
  
  static Future<List<TransactionModel>> getTransactions() async {
    final response = await ApiService.getTransactions();
    
    if (response.success) {
      final List<dynamic> transactionsJson = response.data;
      return transactionsJson.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<List<TransactionModel>> getTransactionsByCurrency(String currency) async {
    final response = await ApiService.getTransactionsByCurrency(currency);
    
    if (response.success) {
      final List<dynamic> transactionsJson = response.data;
      return transactionsJson.map((json) => TransactionModel.fromJson(json)).toList();
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
      final transaction = TransactionModel.fromJson(response.data['transaction']);
      return WalletResult.success(transaction: transaction);
    } else {
      return WalletResult.error(response.error ?? 'Transaction failed');
    }
  }
  
  static Future<List<CryptoPriceModel>> getCryptoPrices() async {
    final response = await ApiService.getCryptoPrices();
    
    if (response.success) {
      final List<dynamic> pricesJson = response.data;
      final prices = pricesJson.map((json) => CryptoPriceModel.fromJson(json)).toList();
      await _savePrices(prices);
      return prices;
    } else {
      // Return cached prices if API fails
      return await _getCachedPrices();
    }
  }
  
  static Future<void> _saveWallets(List<WalletModel> wallets) async {
    final walletsJson = wallets.map((wallet) => wallet.toJson()).toList();
    await _storage.write(
      key: '${AppConstants.walletKey}_wallets',
      value: json.encode(walletsJson),
    );
  }
  
  static Future<List<WalletModel>> _getCachedWallets() async {
    final walletsJson = await _storage.read(key: '${AppConstants.walletKey}_wallets');
    if (walletsJson != null) {
      final List<dynamic> walletsList = json.decode(walletsJson);
      return walletsList.map((json) => WalletModel.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<void> _savePrices(List<CryptoPriceModel> prices) async {
    final pricesJson = prices.map((price) => price.toJson()).toList();
    await _storage.write(
      key: '${AppConstants.walletKey}_prices',
      value: json.encode(pricesJson),
    );
  }
  
  static Future<List<CryptoPriceModel>> _getCachedPrices() async {
    final pricesJson = await _storage.read(key: '${AppConstants.walletKey}_prices');
    if (pricesJson != null) {
      final List<dynamic> pricesList = json.decode(pricesJson);
      return pricesList.map((json) => CryptoPriceModel.fromJson(json)).toList();
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
  final TransactionModel? transaction;
  final String? error;
  
  WalletResult.success({this.transaction}) : success = true, error = null;
  WalletResult.error(this.error) : success = false, transaction = null;
}

class CryptoPriceModel {
  final String symbol;
  final String name;
  final double priceUsd;
  final double change24h;
  final double? marketCap;
  final double? volume24h;
  
  CryptoPriceModel({
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    this.marketCap,
    this.volume24h,
  });
  
  factory CryptoPriceModel.fromJson(Map<String, dynamic> json) {
    return CryptoPriceModel(
      symbol: json['symbol'],
      name: json['name'],
      priceUsd: json['price_usd'].toDouble(),
      change24h: json['change_24h'].toDouble(),
      marketCap: json['market_cap']?.toDouble(),
      volume24h: json['volume_24h']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price_usd': priceUsd,
      'change_24h': change24h,
      'market_cap': marketCap,
      'volume_24h': volume24h,
    };
  }
}

