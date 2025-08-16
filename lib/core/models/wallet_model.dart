class Wallet {
  final int id;
  final int userId;
  final String currency;
  final String address;
  final double balance;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.currency,
    required this.address,
    required this.balance,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['user_id'],
      currency: json['currency'],
      address: json['address'],
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'currency': currency,
      'address': address,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Wallet copyWith({
    int? id,
    int? userId,
    String? currency,
    String? address,
    double? balance,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get currencyIcon {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'USDT':
        return '₮';
      default:
        return '₿';
    }
  }

  String get formattedBalance {
    if (balance == 0) return '0.00';
    
    switch (currency.toUpperCase()) {
      case 'BTC':
      case 'ETH':
        return balance.toStringAsFixed(8);
      case 'USDT':
        return balance.toStringAsFixed(2);
      default:
        return balance.toStringAsFixed(8);
    }
  }

  String get shortAddress {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }
}

