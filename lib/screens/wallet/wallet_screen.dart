import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../widgets/common/wallet_balance_card.dart';

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
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.loadWallets();
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
                        // TODO: Navigate to wallet details
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

