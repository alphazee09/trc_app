import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/bazari_api_service.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../widgets/common/wallet_balance_card.dart';
import 'wallet_detail_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
      
      // Load wallets from API
      final wallets = await BazariApiService.getUserWallets();
      walletProvider.setWallets(wallets);
      
      // Load crypto prices
      await cryptoProvider.loadCryptoPrices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wallets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer2<WalletProvider, CryptoProvider>(
          builder: (context, walletProvider, cryptoProvider, child) {
            if (walletProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: walletProvider.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = walletProvider.wallets[index];
                  final usdValue = cryptoProvider.getUSDValue(
                    wallet.currency,
                    wallet.balance,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WalletBalanceCard(
                      wallet: wallet,
                      usdValue: usdValue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletDetailScreen(wallet: wallet),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

