import 'package:flutter/material.dart';
import '../core/models/wallet_model.dart';
import '../core/models/transaction_model.dart';
import '../core/services/bazari_api_service.dart';

class WalletProvider extends ChangeNotifier {
  List<Wallet> _wallets = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _error;
  
  List<Wallet> get wallets => _wallets;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get error => _error;
  
  double get totalBalanceUSD {
    // This would need crypto prices to calculate accurately
    // For now, return a placeholder calculation
    return _wallets.fold(0.0, (sum, wallet) => sum + (wallet.balance * 1.0));
  }
  
  Wallet? getWalletByCurrency(String currency) {
    try {
      return _wallets.firstWhere(
        (wallet) => wallet.currency.toUpperCase() == currency.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  List<Transaction> getTransactionsByCurrency(String currency) {
    return _transactions
        .where((tx) => tx.currency.toUpperCase() == currency.toUpperCase())
        .toList();
  }
  
  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }
  
  Future<void> loadWallets() async {
    _setLoading(true);
    _clearError();
    
    try {
      _wallets = await BazariApiService.getUserWallets();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setWallets(List<Wallet> wallets) {
    _wallets = wallets;
    notifyListeners();
  }

  Future<void> refreshWalletBalance(int walletId) async {
    try {
      final balanceData = await BazariApiService.getWalletBalance(walletId);
      final index = _wallets.indexWhere((w) => w.id == walletId);
      
      if (index != -1 && balanceData['balance'] != null) {
        _wallets[index] = _wallets[index].copyWith(
          balance: (balanceData['balance'] as num).toDouble(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadTransactions({int page = 1, int perPage = 20}) async {
    _setLoadingTransactions(true);
    _clearError();
    
    try {
      final allTransactions = <Transaction>[];
      
      // Load transactions for each wallet
      for (final wallet in _wallets) {
        final response = await BazariApiService.getTransactionHistory(
          walletId: wallet.id,
          page: page,
          perPage: perPage,
        );
        
        if (response['data'] != null) {
          final List<dynamic> transactionData = response['data'];
          final transactions = transactionData
              .map((tx) => Transaction.fromJson(tx))
              .toList();
          allTransactions.addAll(transactions);
        }
      }
      
      // Sort by date (newest first)
      allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (page == 1) {
        _transactions = allTransactions;
      } else {
        _transactions.addAll(allTransactions);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingTransactions(false);
    }
  }

  Future<bool> sendCrypto({
    required String currency,
    required String toAddress,
    required double amount,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await BazariApiService.sendCrypto(
        currency: currency,
        toAddress: toAddress,
        amount: amount,
      );
      
      // Update wallet balance
      if (result['remaining_balance'] != null) {
        final wallet = getWalletByCurrency(currency);
        if (wallet != null) {
          final index = _wallets.indexWhere((w) => w.id == wallet.id);
          if (index != -1) {
            _wallets[index] = wallet.copyWith(
              balance: (result['remaining_balance'] as num).toDouble(),
            );
          }
        }
      }
      
      // Refresh transactions
      await loadTransactions();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void updateWalletBalance(String currency, double newBalance) {
    final index = _wallets.indexWhere(
      (wallet) => wallet.currency.toUpperCase() == currency.toUpperCase(),
    );
    
    if (index != -1) {
      _wallets[index] = _wallets[index].copyWith(balance: newBalance);
      notifyListeners();
    }
  }

  void clearData() {
    _wallets.clear();
    _transactions.clear();
    _error = null;
    notifyListeners();
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
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}

