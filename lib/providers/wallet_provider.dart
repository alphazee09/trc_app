import 'package:flutter/material.dart';
import '../core/models/wallet_model.dart';
import '../core/models/transaction_model.dart';
import '../core/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _error;
  
  List<WalletModel> get wallets => _wallets;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get error => _error;
  
  double get totalBalanceUSD {
    // This would need crypto prices to calculate accurately
    // For now, return a placeholder calculation
    return _wallets.fold(0.0, (sum, wallet) => sum + (wallet.balance * 1.0));
  }
  
  WalletModel? getWalletByCurrency(String currency) {
    try {
      return _wallets.firstWhere(
        (wallet) => wallet.currency.toUpperCase() == currency.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  List<TransactionModel> getTransactionsByCurrency(String currency) {
    return _transactions
        .where((tx) => tx.currency.toUpperCase() == currency.toUpperCase())
        .toList();
  }
  
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return sorted.take(10).toList();
  }
  
  Future<void> loadWallets() async {
    _setLoading(true);
    _clearError();
    
    try {
      _wallets = await WalletService.getWallets();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load wallets: ${e.toString()}');
    }
  }
  
  Future<void> loadTransactions() async {
    _setLoadingTransactions(true);
    _clearError();
    
    try {
      _transactions = await WalletService.getTransactions();
      _setLoadingTransactions(false);
    } catch (e) {
      _setError('Failed to load transactions: ${e.toString()}');
    }
  }
  
  Future<void> refreshWallet(String currency) async {
    try {
      final wallet = await WalletService.getWalletByCurrency(currency);
      if (wallet != null) {
        final index = _wallets.indexWhere((w) => w.currency == currency);
        if (index != -1) {
          _wallets[index] = wallet;
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail for refresh
    }
  }
  
  Future<bool> sendCrypto({
    required String currency,
    required double amount,
    required String toAddress,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await WalletService.sendCrypto(
        currency: currency,
        amount: amount,
        toAddress: toAddress,
      );
      
      if (result.success) {
        // Add the new transaction to the list
        if (result.transaction != null) {
          _transactions.insert(0, result.transaction!);
        }
        
        // Refresh the wallet balance
        await refreshWallet(currency);
        
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Transaction failed');
        return false;
      }
    } catch (e) {
      _setError('Transaction failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<void> refreshData() async {
    await Future.wait([
      loadWallets(),
      loadTransactions(),
    ]);
  }
  
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    
    // Update wallet balance if it's a receive transaction
    if (transaction.isReceived) {
      final walletIndex = _wallets.indexWhere(
        (wallet) => wallet.currency == transaction.currency,
      );
      if (walletIndex != -1) {
        final updatedWallet = _wallets[walletIndex].copyWith(
          balance: _wallets[walletIndex].balance + transaction.amount,
        );
        _wallets[walletIndex] = updatedWallet;
      }
    }
    
    notifyListeners();
  }
  
  bool isValidAddress(String address, String currency) {
    return WalletService.isValidAddress(address, currency);
  }
  
  String formatCurrency(double amount, {int decimals = 8}) {
    return WalletService.formatCurrency(amount, decimals: decimals);
  }
  
  String formatUSD(double amount) {
    return WalletService.formatUSD(amount);
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setLoadingTransactions(bool loading) {
    _isLoadingTransactions = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    _isLoadingTransactions = false;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }
}

