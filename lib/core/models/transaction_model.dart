class Transaction {
  final int id;
  final int userId;
  final String fromAddress;
  final String toAddress;
  final String currency;
  final double amount;
  final double fee;
  final String txHash;
  final int? blockNumber;
  final String? blockHash;
  final int? gasUsed;
  final String status;
  final String transactionType;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.fromAddress,
    required this.toAddress,
    required this.currency,
    required this.amount,
    required this.fee,
    required this.txHash,
    this.blockNumber,
    this.blockHash,
    this.gasUsed,
    required this.status,
    required this.transactionType,
    required this.createdAt,
    this.confirmedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      fromAddress: json['from_address'],
      toAddress: json['to_address'],
      currency: json['currency'],
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      txHash: json['tx_hash'],
      blockNumber: json['block_number'],
      blockHash: json['block_hash'],
      gasUsed: json['gas_used'],
      status: json['status'],
      transactionType: json['transaction_type'],
      createdAt: DateTime.parse(json['created_at']),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'from_address': fromAddress,
      'to_address': toAddress,
      'currency': currency,
      'amount': amount,
      'fee': fee,
      'tx_hash': txHash,
      'block_number': blockNumber,
      'block_hash': blockHash,
      'gas_used': gasUsed,
      'status': status,
      'transaction_type': transactionType,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    int? userId,
    String? fromAddress,
    String? toAddress,
    String? currency,
    double? amount,
    double? fee,
    String? txHash,
    int? blockNumber,
    String? blockHash,
    int? gasUsed,
    String? status,
    String? transactionType,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      txHash: txHash ?? this.txHash,
      blockNumber: blockNumber ?? this.blockNumber,
      blockHash: blockHash ?? this.blockHash,
      gasUsed: gasUsed ?? this.gasUsed,
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isFailed => status.toLowerCase() == 'failed';
  
  bool get isSent => transactionType.toLowerCase() == 'send';
  bool get isReceived => transactionType.toLowerCase() == 'receive';

  String get formattedAmount {
    switch (currency.toUpperCase()) {
      case 'BTC':
      case 'ETH':
        return amount.toStringAsFixed(8);
      case 'USDT':
        return amount.toStringAsFixed(2);
      default:
        return amount.toStringAsFixed(8);
    }
  }

  String get shortTxHash {
    if (txHash.length <= 16) return txHash;
    return '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 8)}';
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

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String get typeDisplayText {
    return isSent ? 'Sent' : 'Received';
  }

  String get explorerUrl {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return 'https://www.blockchain.com/btc/tx/$txHash';
      case 'ETH':
      case 'USDT':
        return 'https://etherscan.io/tx/$txHash';
      default:
        return '';
    }
  }
}

