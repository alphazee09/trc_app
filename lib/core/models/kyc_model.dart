class KYCModel {
  final int id;
  final int userId;
  final String documentType;
  final String documentNumber;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;
  
  KYCModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentNumber,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewerNotes,
  });
  
  factory KYCModel.fromJson(Map<String, dynamic> json) {
    return KYCModel(
      id: json['id'],
      userId: json['user_id'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      status: json['status'],
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at']) : null,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      reviewerNotes: json['reviewer_notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'document_type': documentType,
      'document_number': documentNumber,
      'status': status,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewer_notes': reviewerNotes,
    };
  }
  
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
  
  String get documentTypeDisplayText {
    switch (documentType.toLowerCase()) {
      case 'passport':
        return 'Passport';
      case 'driver_license':
        return 'Driver\'s License';
      case 'national_id':
        return 'National ID';
      default:
        return documentType;
    }
  }
  
  KYCModel copyWith({
    int? id,
    int? userId,
    String? documentType,
    String? documentNumber,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerNotes,
  }) {
    return KYCModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
    );
  }
}

