class CryptoPrice {
  final int id;
  final String symbol;
  final String name;
  final double priceUsd;
  final double change24h;
  final double? marketCap;
  final double? volume24h;
  final DateTime updatedAt;

  CryptoPrice({
    required this.id,
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    this.marketCap,
    this.volume24h,
    required this.updatedAt,
  });

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    return CryptoPrice(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      priceUsd: (json['price_usd'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
      marketCap: json['market_cap'] != null ? (json['market_cap'] as num).toDouble() : null,
      volume24h: json['volume_24h'] != null ? (json['volume_24h'] as num).toDouble() : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'price_usd': priceUsd,
      'change_24h': change24h,
      'market_cap': marketCap,
      'volume_24h': volume24h,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CryptoPrice copyWith({
    int? id,
    String? symbol,
    String? name,
    double? priceUsd,
    double? change24h,
    double? marketCap,
    double? volume24h,
    DateTime? updatedAt,
  }) {
    return CryptoPrice(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      priceUsd: priceUsd ?? this.priceUsd,
      change24h: change24h ?? this.change24h,
      marketCap: marketCap ?? this.marketCap,
      volume24h: volume24h ?? this.volume24h,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPriceUp => change24h > 0;
  bool get isPriceDown => change24h < 0;
  bool get isPriceStable => change24h == 0;

  String get formattedPrice {
    if (priceUsd >= 1000) {
      return '\$${priceUsd.toStringAsFixed(2)}';
    } else if (priceUsd >= 1) {
      return '\$${priceUsd.toStringAsFixed(4)}';
    } else {
      return '\$${priceUsd.toStringAsFixed(8)}';
    }
  }

  String get formattedChange {
    final prefix = change24h >= 0 ? '+' : '';
    return '$prefix${change24h.toStringAsFixed(2)}%';
  }

  String get formattedMarketCap {
    if (marketCap == null) return 'N/A';
    
    if (marketCap! >= 1e12) {
      return '\$${(marketCap! / 1e12).toStringAsFixed(2)}T';
    } else if (marketCap! >= 1e9) {
      return '\$${(marketCap! / 1e9).toStringAsFixed(2)}B';
    } else if (marketCap! >= 1e6) {
      return '\$${(marketCap! / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${marketCap!.toStringAsFixed(0)}';
    }
  }

  String get formattedVolume24h {
    if (volume24h == null) return 'N/A';
    
    if (volume24h! >= 1e9) {
      return '\$${(volume24h! / 1e9).toStringAsFixed(2)}B';
    } else if (volume24h! >= 1e6) {
      return '\$${(volume24h! / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${volume24h!.toStringAsFixed(0)}';
    }
  }

  String get currencyIcon {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'USDT':
        return '₮';
      default:
        return symbol.substring(0, 1).toUpperCase();
    }
  }
}