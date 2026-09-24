enum PaymentStatus {
  pending,
  paid,
  failed;

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.failed:
        return 'FAILED';
    }
  }

  static PaymentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'PENDING':
      default:
        return PaymentStatus.pending;
    }
  }
}

enum BookingStatus {
  confirmed,
  pending,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'PENDING':
      default:
        return BookingStatus.pending;
    }
  }
}

enum PlaybackStatus {
  scheduled,
  playing,
  completed;

  String get label {
    switch (this) {
      case PlaybackStatus.scheduled:
        return 'SCHEDULED';
      case PlaybackStatus.playing:
        return 'PLAYING';
      case PlaybackStatus.completed:
        return 'COMPLETED';
    }
  }

  static PlaybackStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PLAYING':
        return PlaybackStatus.playing;
      case 'COMPLETED':
        return PlaybackStatus.completed;
      case 'SCHEDULED':
      default:
        return PlaybackStatus.scheduled;
    }
  }
}

class Booking {
  final String id;
  final String billboardId;
  final String billboardName;
  final String billboardLocation;
  final String advertiserId;
  final String advertiserName;
  final String adId;
  final String adTitle;
  final String adVideoName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice; // in FCFA
  final PaymentStatus paymentStatus;
  final BookingStatus bookingStatus;
  final PlaybackStatus playbackStatus;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.billboardId,
    required this.billboardName,
    required this.billboardLocation,
    this.advertiserId = 'ADV-001',
    this.advertiserName = 'Advertiser Partner',
    required this.adId,
    required this.adTitle,
    required this.adVideoName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.playbackStatus,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      billboardId: json['billboardId']?.toString() ?? json['billboard_id']?.toString() ?? '',
      billboardName: json['billboardName'] ?? json['billboard_name'] ?? 'Smart Billboard',
      billboardLocation: json['billboardLocation'] ?? json['location'] ?? 'Douala',
      advertiserId: json['advertiserId']?.toString() ?? json['advertiser_id']?.toString() ?? 'ADV-001',
      advertiserName: json['advertiserName'] ?? json['advertiser_name'] ?? 'Advertiser Partner',
      adId: json['adId']?.toString() ?? json['ad_id']?.toString() ?? '',
      adTitle: json['adTitle'] ?? json['ad_title'] ?? 'Advertisement',
      adVideoName: json['adVideoName'] ?? json['video_name'] ?? 'campaign.mp4',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      startTime: json['startTime'] ?? '08:00',
      endTime: json['endTime'] ?? '10:00',
      totalPrice: (json['totalPrice'] ?? json['price'] as num?)?.toDouble() ?? 15000.0,
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] ?? json['payment_status'] ?? 'PENDING'),
      bookingStatus: BookingStatus.fromString(json['bookingStatus'] ?? json['booking_status'] ?? 'PENDING'),
      playbackStatus: PlaybackStatus.fromString(json['playbackStatus'] ?? json['playback_status'] ?? 'SCHEDULED'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billboardId': billboardId,
      'billboardName': billboardName,
      'billboardLocation': billboardLocation,
      'advertiserId': advertiserId,
      'advertiserName': advertiserName,
      'adId': adId,
      'adTitle': adTitle,
      'adVideoName': adVideoName,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalPrice': totalPrice,
      'paymentStatus': paymentStatus.label,
      'bookingStatus': bookingStatus.label,
      'playbackStatus': playbackStatus.label,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
