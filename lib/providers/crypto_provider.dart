import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/wallet_service.dart';

class CryptoProvider extends ChangeNotifier {
  List<CryptoPriceModel> _prices = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  
  List<CryptoPriceModel> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CryptoPriceModel? getPriceBySymbol(String symbol) {
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
    return WalletService.formatUSD(usdValue);
  }
  
  Future<void> loadPrices() async {
    _setLoading(true);
    _clearError();
    
    try {
      _prices = await WalletService.getCryptoPrices();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load crypto prices: ${e.toString()}');
    }
  }
  
  Future<void> refreshPrices() async {
    try {
      _prices = await WalletService.getCryptoPrices();
      notifyListeners();
    } catch (e) {
      // Silently fail for refresh
    }
  }
  
  void startAutoRefresh({Duration interval = const Duration(minutes: 1)}) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (_) {
      refreshPrices();
    });
  }
  
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  List<CryptoPriceModel> get topGainers {
    final sorted = List<CryptoPriceModel>.from(_prices);
    sorted.sort((a, b) => b.change24h.compareTo(a.change24h));
    return sorted.take(5).toList();
  }
  
  List<CryptoPriceModel> get topLosers {
    final sorted = List<CryptoPriceModel>.from(_prices);
    sorted.sort((a, b) => a.change24h.compareTo(b.change24h));
    return sorted.take(5).toList();
  }
  
  List<CryptoPriceModel> get supportedCurrencies {
    return _prices.where((price) => 
      ['BTC', 'USDT', 'ETH'].contains(price.symbol.toUpperCase())
    ).toList();
  }
  
  double get totalMarketCap {
    return _prices.fold(0.0, (sum, price) => sum + (price.marketCap ?? 0.0));
  }
  
  double get total24hVolume {
    return _prices.fold(0.0, (sum, price) => sum + (price.volume24h ?? 0.0));
  }
  
  String getChangeColor(double change) {
    if (change > 0) return '#00B894'; // Green
    if (change < 0) return '#E74C3C'; // Red
    return '#B2B2B2'; // Gray
  }
  
  String getChangeIcon(double change) {
    if (change > 0) return '↗';
    if (change < 0) return '↘';
    return '→';
  }
  
  String formatChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}%';
  }
  
  String formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }
  
  String formatMarketCap(double? marketCap) {
    if (marketCap == null) return 'N/A';
    return WalletService.formatUSD(marketCap);
  }
  
  String formatVolume(double? volume) {
    if (volume == null) return 'N/A';
    return WalletService.formatUSD(volume);
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
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

