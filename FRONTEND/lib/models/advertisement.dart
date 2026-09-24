enum AdVerificationStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case AdVerificationStatus.pending:
        return 'PENDING';
      case AdVerificationStatus.approved:
        return 'APPROVED';
      case AdVerificationStatus.rejected:
        return 'REJECTED';
    }
  }

  static AdVerificationStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AdVerificationStatus.approved;
      case 'REJECTED':
        return AdVerificationStatus.rejected;
      case 'PENDING':
      default:
        return AdVerificationStatus.pending;
    }
  }
}

typedef VerificationStatus = AdVerificationStatus;

class Advertisement {
  final String id;
  final String advertiserId;
  final String title;
  final String videoName;
  final String videoUrl;
  final int durationSeconds;
  final DateTime uploadDate;
  final AdVerificationStatus verificationStatus;
  final String? rejectionReason;

  DateTime get createdAt => uploadDate;

  const Advertisement({
    required this.id,
    this.advertiserId = 'USR-001',
    required this.title,
    required this.videoName,
    required this.videoUrl,
    required this.durationSeconds,
    required this.uploadDate,
    required this.verificationStatus,
    this.rejectionReason,
  });

  bool get isApproved => verificationStatus == AdVerificationStatus.approved;

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Advertisement Campaign',
      videoName: json['videoName'] ?? json['video_name'] ?? 'ad_video.mp4',
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
      durationSeconds: json['durationSeconds'] ?? json['duration'] ?? 15,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      verificationStatus: AdVerificationStatus.fromString(json['verificationStatus'] ?? json['status'] ?? 'PENDING'),
      rejectionReason: json['rejectionReason'] ?? json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoName': videoName,
      'videoUrl': videoUrl,
      'durationSeconds': durationSeconds,
      'uploadDate': uploadDate.toIso8601String(),
      'verificationStatus': verificationStatus.label,
      'rejectionReason': rejectionReason,
    };
  }
}
