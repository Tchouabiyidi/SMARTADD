class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final double price; // in FCFA

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.price,
  });

  String get timeRange => '$startTime - $endTime';

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      startTime: json['startTime'] ?? '08:00',
      endTime: json['endTime'] ?? '10:00',
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      price: (json['price'] as num?)?.toDouble() ?? 15000.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'price': price,
    };
  }
}
