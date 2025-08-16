import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/crypto_price_model.dart';
import '../core/services/bazari_api_service.dart';

class CryptoProvider extends ChangeNotifier {
  List<CryptoPrice> _prices = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  
  List<CryptoPrice> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CryptoPrice? getPriceBySymbol(String symbol) {
    try {
      return _prices.firstWhere(
        (price) => price.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  double getUSDValue(String currency, double amount) {
    final price = getPriceBySymbol(currency);
    if (price != null) {
      return amount * price.priceUsd;
    }
    return 0.0;
  }
  
  String formatUSDValue(String currency, double amount) {
    final usdValue = getUSDValue(currency, amount);
    return '\$${usdValue.toStringAsFixed(2)}';
  }

  Future<void> loadCryptoPrices() async {
    _setLoading(true);
    _clearError();
    
    try {
      _prices = await BazariApiService.getCryptoPrices();
    } catch (e) {
      _setError('Failed to load crypto prices: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> refreshPrices() async {
    try {
      _prices = await BazariApiService.getCryptoPrices();
      notifyListeners();
    } catch (e) {
      // Silently fail for refresh
    }
  }

  Future<CryptoPrice?> getSpecificPrice(String symbol) async {
    try {
      return await BazariApiService.getCryptoPrice(symbol);
    } catch (e) {
      return null;
    }
  }
  
  void startAutoRefresh({Duration interval = const Duration(minutes: 1)}) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (timer) {
      refreshPrices();
    });
  }
  
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  List<CryptoPrice> get topGainers {
    final sorted = List<CryptoPrice>.from(_prices);
    sorted.sort((a, b) => b.change24h.compareTo(a.change24h));
    return sorted.take(5).toList();
  }

  List<CryptoPrice> get topLosers {
    final sorted = List<CryptoPrice>.from(_prices);
    sorted.sort((a, b) => a.change24h.compareTo(b.change24h));
    return sorted.take(5).toList();
  }

  double get totalMarketCap {
    return _prices.fold(0.0, (sum, price) => sum + (price.marketCap ?? 0.0));
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }

  void clearData() {
    _prices.clear();
    _error = null;
    stopAutoRefresh();
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

