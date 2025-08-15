import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/wallet_model.dart';

class SendCryptoScreen extends StatefulWidget {
  final String? currency;
  
  const SendCryptoScreen({super.key, this.currency});

  @override
  State<SendCryptoScreen> createState() => _SendCryptoScreenState();
}

class _SendCryptoScreenState extends State<SendCryptoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCurrency = 'BTC';
  bool _isLoading = false;
  double _estimatedFee = 0.0;
  double _usdValue = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.currency != null) {
      _selectedCurrency = widget.currency!;
    }
    _calculateFee();
  }

  void _calculateFee() {
    // Simulate fee calculation
    setState(() {
      switch (_selectedCurrency) {
        case 'BTC':
          _estimatedFee = 0.0001;
          break;
        case 'USDT':
          _estimatedFee = 2.5;
          break;
        case 'ETH':
          _estimatedFee = 0.002;
          break;
        default:
          _estimatedFee = 0.001;
      }
    });
  }

  void _calculateUSDValue() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    setState(() {
      _usdValue = cryptoProvider.getUSDValue(_selectedCurrency, amount);
    });
  }

  Future<void> _sendCrypto() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check KYC status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.isVerified != true) {
      _showKYCRequiredDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final amount = double.parse(_amountController.text);
    
    final success = await walletProvider.sendCrypto(
      currency: _selectedCurrency,
      amount: amount,
      toAddress: _addressController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      _showErrorSnackBar(walletProvider.error ?? 'Transaction failed');
    }
  }

  void _showKYCRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KYC Verification Required'),
        content: const Text(
          'You need to complete KYC verification before sending cryptocurrency. Would you like to start the verification process now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/kyc');
            },
            child: const Text('Start KYC'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Transaction Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your transaction has been successfully submitted to the network.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${_amountController.text} $_selectedCurrency'),
                  Text('To: ${_addressController.text.substring(0, 20)}...'),
                  Text('Fee: $_estimatedFee $_selectedCurrency'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Crypto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency Selection
                _buildCurrencySelection(),
                const SizedBox(height: 24),
                
                // Recipient Address
                _buildAddressInput(),
                const SizedBox(height: 24),
                
                // Amount Input
                _buildAmountInput(),
                const SizedBox(height: 24),
                
                // Transaction Summary
                _buildTransactionSummary(),
                const SizedBox(height: 32),
                
                // Send Button
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelection() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
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
                    _calculateFee();
                    _calculateUSDValue();
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient Address',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter wallet address',
            filled: true,
            fillColor: AppTheme.surfaceColor.withOpacity(0.5),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _addressController.text = data!.text!;
                    }
                  },
                  icon: const Icon(Icons.paste),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement QR scanner
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient address';
            }
            final walletProvider = Provider.of<WalletProvider>(context, listen: false);
            if (!walletProvider.isValidAddress(value, _selectedCurrency)) {
              return 'Invalid address format';
            }
            return null;
          },
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Consumer2<WalletProvider, CryptoProvider>(
      builder: (context, walletProvider, cryptoProvider, child) {
        final wallet = walletProvider.getWalletByCurrency(_selectedCurrency);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: AppTheme.surfaceColor.withOpacity(0.5),
                suffixText: _selectedCurrency,
                suffixIcon: TextButton(
                  onPressed: () {
                    if (wallet != null) {
                      _amountController.text = wallet.balance.toString();
                      _calculateUSDValue();
                    }
                  },
                  child: const Text('MAX'),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (wallet != null && amount > wallet.balance) {
                  return 'Insufficient balance';
                }
                return null;
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculateUSDValue(),
            ),
            if (_usdValue > 0) ...[
              const SizedBox(height: 8),
              Text(
                '≈ \$${_usdValue.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTransactionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Network Fee', '$_estimatedFee $_selectedCurrency'),
          _buildSummaryRow('Total Amount', '${_amountController.text.isEmpty ? '0' : _amountController.text} $_selectedCurrency'),
          if (_usdValue > 0)
            _buildSummaryRow('USD Value', '\$${_usdValue.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendCrypto,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Send Crypto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

