class TransactionModel {
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
  final double? gasPrice;
  final String? contractAddress;
  final String? tokenId;
  final String status;
  final String transactionType;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  
  TransactionModel({
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
    this.gasPrice,
    this.contractAddress,
    this.tokenId,
    required this.status,
    required this.transactionType,
    this.createdAt,
    this.confirmedAt,
  });
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      fromAddress: json['from_address'],
      toAddress: json['to_address'],
      currency: json['currency'],
      amount: json['amount'].toDouble(),
      fee: json['fee'].toDouble(),
      txHash: json['tx_hash'],
      blockNumber: json['block_number'],
      blockHash: json['block_hash'],
      gasUsed: json['gas_used'],
      gasPrice: json['gas_price']?.toDouble(),
      contractAddress: json['contract_address'],
      tokenId: json['token_id'],
      status: json['status'],
      transactionType: json['transaction_type'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
      'gas_price': gasPrice,
      'contract_address': contractAddress,
      'token_id': tokenId,
      'status': status,
      'transaction_type': transactionType,
      'created_at': createdAt?.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
    };
  }
  
  String get formattedAmount {
    return amount.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  
  String get formattedFee {
    return fee.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  
  String get shortTxHash {
    if (txHash.length <= 10) return txHash;
    return '${txHash.substring(0, 6)}...${txHash.substring(txHash.length - 4)}';
  }
  
  String get shortFromAddress {
    if (fromAddress.length <= 10) return fromAddress;
    return '${fromAddress.substring(0, 6)}...${fromAddress.substring(fromAddress.length - 4)}';
  }
  
  String get shortToAddress {
    if (toAddress.length <= 10) return toAddress;
    return '${toAddress.substring(0, 6)}...${toAddress.substring(toAddress.length - 4)}';
  }
  
  String get shortBlockHash {
    if (blockHash == null || blockHash!.length <= 10) return blockHash ?? '';
    return '${blockHash!.substring(0, 6)}...${blockHash!.substring(blockHash!.length - 4)}';
  }
  
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  
  bool get isSent => transactionType == 'send';
  bool get isReceived => transactionType == 'receive';
  
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
    switch (transactionType.toLowerCase()) {
      case 'send':
        return 'Sent';
      case 'receive':
        return 'Received';
      default:
        return transactionType;
    }
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
  
  String get formattedGasPrice {
    if (gasPrice == null) return '';
    return '${gasPrice!.toStringAsFixed(2)} Gwei';
  }
  
  String get explorerUrl {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return 'https://blockstream.info/tx/$txHash';
      case 'USDT':
      case 'ETH':
        return 'https://etherscan.io/tx/$txHash';
      default:
        return '';
    }
  }
  
  TransactionModel copyWith({
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
    double? gasPrice,
    String? contractAddress,
    String? tokenId,
    String? status,
    String? transactionType,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) {
    return TransactionModel(
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
      gasPrice: gasPrice ?? this.gasPrice,
      contractAddress: contractAddress ?? this.contractAddress,
      tokenId: tokenId ?? this.tokenId,
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }
}

