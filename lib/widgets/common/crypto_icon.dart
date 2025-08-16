import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CryptoIcon extends StatelessWidget {
  final String currency;
  final double size;
  final Color? backgroundColor;

  const CryptoIcon({
    super.key,
    required this.currency,
    this.size = 32,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getCurrencyColor(currency),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getCurrencySymbol(currency),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getCurrencyColor(String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'USDT':
        return const Color(0xFF26A17B);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'USDT':
        return '₮';
      default:
        return currency.substring(0, 1).toUpperCase();
    }
  }
}