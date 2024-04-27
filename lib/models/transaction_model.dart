class Tap{
  final String userId;
  final String role;
  final String busId;
  final String status;
  final String transactionId;

  Tap({required this.userId, required this.role, required this.busId, required this.status, required this.transactionId});

  factory Tap.fromJson(Map<String, dynamic> json) {
    return Tap(
        userId: json['user_id'],
        role: json['role'],
        busId: json['busId'],
        status: json['status'],
        transactionId: json['transaction_id']);
  }
}