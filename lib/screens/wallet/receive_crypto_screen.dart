import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../core/models/wallet_model.dart';

class ReceiveCryptoScreen extends StatefulWidget {
  final String? currency;
  
  const ReceiveCryptoScreen({super.key, this.currency});

  @override
  State<ReceiveCryptoScreen> createState() => _ReceiveCryptoScreenState();
}

class _ReceiveCryptoScreenState extends State<ReceiveCryptoScreen> {
  String _selectedCurrency = 'BTC';
  WalletModel? _selectedWallet;

  @override
  void initState() {
    super.initState();
    if (widget.currency != null) {
      _selectedCurrency = widget.currency!;
    }
    _loadWallet();
  }

  void _loadWallet() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _selectedWallet = walletProvider.getWalletByCurrency(_selectedCurrency);
  }

  void _copyAddress() {
    if (_selectedWallet != null) {
      Clipboard.setData(ClipboardData(text: _selectedWallet!.address));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address copied to clipboard'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _shareAddress() {
    if (_selectedWallet != null) {
      // TODO: Implement share functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share functionality coming soon'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Crypto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _shareAddress,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency Selection
                  _buildCurrencySelection(walletProvider),
                  const SizedBox(height: 32),
                  
                  // QR Code Section
                  _buildQRCodeSection(),
                  const SizedBox(height: 32),
                  
                  // Address Section
                  _buildAddressSection(),
                  const SizedBox(height: 32),
                  
                  // Instructions
                  _buildInstructions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencySelection(WalletProvider walletProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Currency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: walletProvider.wallets.map((wallet) {
              return DropdownMenuItem(
                value: wallet.currency,
                child: Row(
                  children: [
                    Text(
                      wallet.currencyIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wallet.currency),
                        Text(
                          'Balance: ${wallet.formattedBalance}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
                _selectedWallet = walletProvider.getWalletByCurrency(_selectedCurrency);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    if (_selectedWallet == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Scan QR Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this QR code to receive $_selectedCurrency',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: _selectedWallet!.address,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          
          // Currency Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: _getCryptoGradient(_selectedCurrency),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _selectedWallet!.currencyIcon,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedCurrency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    if (_selectedWallet == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Address',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Address Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedWallet!.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copyAddress,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy Address',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Copy Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _copyAddress,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.warningColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Important Instructions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            '1. Only send $_selectedCurrency to this address',
          ),
          _buildInstructionItem(
            '2. Sending other cryptocurrencies may result in permanent loss',
          ),
          _buildInstructionItem(
            '3. Ensure the network matches (${_getNetworkName(_selectedCurrency)})',
          ),
          _buildInstructionItem(
            '4. Transactions are irreversible once confirmed',
          ),
          _buildInstructionItem(
            '5. Always verify the address before sending',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  LinearGradient _getCryptoGradient(String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return const LinearGradient(
          colors: [Color(0xFFF7931A), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'USDT':
        return const LinearGradient(
          colors: [Color(0xFF26A17B), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ETH':
        return const LinearGradient(
          colors: [Color(0xFF627EEA), Color(0xFF8E9AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  String _getNetworkName(String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return 'Bitcoin Network';
      case 'USDT':
        return 'Ethereum Network (ERC-20)';
      case 'ETH':
        return 'Ethereum Network';
      default:
        return 'Blockchain Network';
    }
  }
}

