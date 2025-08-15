import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/wallet_service.dart';

class CryptoPriceCard extends StatelessWidget {
  final CryptoPriceModel price;
  final VoidCallback? onTap;

  const CryptoPriceCard({
    super.key,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = price.change24h >= 0;
    final changeColor = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Crypto Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _getCryptoGradient(price.symbol),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _getCryptoIcon(price.symbol),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Crypto Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.symbol,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(price.priceUsd),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          changeIcon,
                          size: 16,
                          color: changeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${price.change24h.toStringAsFixed(2)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getCryptoGradient(String symbol) {
    switch (symbol.toUpperCase()) {
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

  String _getCryptoIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'USDT':
        return '₮';
      case 'ETH':
        return 'Ξ';
      case 'BNB':
        return 'B';
      case 'ADA':
        return 'A';
      case 'SOL':
        return 'S';
      case 'DOT':
        return 'D';
      case 'DOGE':
        return 'Ð';
      default:
        return symbol.substring(0, 1);
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(0)}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 0.01) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }
}

