class TransactionRecord {
  final String itemCode;
  final int delta; // positive for in, negative for out
  final DateTime timestamp;

  TransactionRecord({required this.itemCode, required this.delta, required this.timestamp});

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      itemCode: map['itemCode'] as String,
      delta: map['delta'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemCode': itemCode,
      'delta': delta,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
