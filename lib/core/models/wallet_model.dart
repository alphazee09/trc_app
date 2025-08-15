class WalletModel {
  final int id;
  final int userId;
  final String currency;
  final String address;
  final double balance;
  final DateTime? createdAt;
  
  WalletModel({
    required this.id,
    required this.userId,
    required this.currency,
    required this.address,
    required this.balance,
    this.createdAt,
  });
  
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['user_id'],
      currency: json['currency'],
      address: json['address'],
      balance: json['balance'].toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'currency': currency,
      'address': address,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  String get formattedBalance {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else {
      return balance.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
  }
  
  String get shortAddress {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
  
  String get currencyIcon {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return '₿';
      case 'USDT':
        return '₮';
      case 'ETH':
        return 'Ξ';
      default:
        return currency;
    }
  }
  
  WalletModel copyWith({
    int? id,
    int? userId,
    String? currency,
    String? address,
    double? balance,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

