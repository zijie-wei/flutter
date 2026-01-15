class RechargePackage {
  final String id;
  final String name;
  final double price;
  final int credits;
  final String? description;
  final bool isPopular;

  RechargePackage({
    required this.id,
    required this.name,
    required this.price,
    required this.credits,
    this.description,
    this.isPopular = false,
  });

  factory RechargePackage.fromJson(Map<String, dynamic> json) {
    return RechargePackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      credits: json['credits'] ?? 0,
      description: json['description'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'credits': credits,
      'description': description,
      'is_popular': isPopular,
    };
  }
}

class RechargeRecord {
  final String id;
  final String packageId;
  final String packageName;
  final double amount;
  final int credits;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? transactionId;

  RechargeRecord({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.amount,
    required this.credits,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.transactionId,
  });

  factory RechargeRecord.fromJson(Map<String, dynamic> json) {
    return RechargeRecord(
      id: json['id'] ?? '',
      packageId: json['package_id'] ?? '',
      packageName: json['package_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      credits: json['credits'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'package_name': packageName,
      'amount': amount,
      'credits': credits,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'transaction_id': transactionId,
    };
  }
}
