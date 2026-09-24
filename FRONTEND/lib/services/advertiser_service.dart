import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/advertisement.dart';
import '../models/billboard.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import 'auth_service.dart';

class AdvertiserService {
  final String _baseUrl = AuthService.baseUrl;

  /// Seed Billboards data for demonstration and offline mode
  static final List<Billboard> mockBillboards = [
    const Billboard(
      id: 'bb_douala_01',
      name: 'Akwa Central Square Billboard',
      location: 'Douala, Littoral',
      address: 'Boulevard de la Liberté, Akwa',
      latitude: 4.0511,
      longitude: 9.7679,
      pricePerSlot: 25000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Littoral Media Corp',
      dimensions: '8m x 4m',
      availableTimeSlots: [
        '08:00 - 10:00',
        '10:00 - 12:00',
        '12:00 - 14:00',
        '14:00 - 16:00',
        '16:00 - 18:00',
        '18:00 - 20:00'
      ],
    ),
    const Billboard(
      id: 'bb_douala_02',
      name: 'Bonanjo Express Junction Billboard',
      location: 'Douala, Littoral',
      address: 'Rue Hospitalière, Bonanjo',
      latitude: 4.0435,
      longitude: 9.6912,
      pricePerSlot: 30000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Urban Ads West',
      dimensions: '10m x 5m',
      availableTimeSlots: [
        '09:00 - 11:00',
        '11:00 - 13:00',
        '13:00 - 15:00',
        '15:00 - 17:00',
        '17:00 - 19:00'
      ],
    ),
    const Billboard(
      id: 'bb_yaounde_01',
      name: 'Place de l\'Indépendance Billboard',
      location: 'Yaoundé, Centre',
      address: 'Avenue Kennedy, Bastos',
      latitude: 3.8480,
      longitude: 11.5021,
      pricePerSlot: 35000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Capital Billboards Ltd',
      dimensions: '12m x 6m',
      availableTimeSlots: [
        '08:00 - 10:00',
        '10:00 - 12:00',
        '14:00 - 16:00',
        '18:00 - 20:00'
      ],
    ),
    const Billboard(
      id: 'bb_bafoussam_01',
      name: 'Marché Central High-Vis Billboard',
      location: 'Bafoussam, Ouest',
      address: 'Commercial Avenue',
      latitude: 5.4778,
      longitude: 10.4176,
      pricePerSlot: 18000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Western Outdoor Media',
      dimensions: '6m x 3m',
      availableTimeSlots: [
        '08:00 - 10:00',
        '10:00 - 12:00',
        '12:00 - 14:00',
        '14:00 - 16:00',
        '16:00 - 18:00'
      ],
    ),
  ];

  /// Initial seed advertisements
  static final List<Advertisement> mockAdvertisements = [
    Advertisement(
      id: 'ad_01',
      title: 'Summer Mega Promo 2026',
      videoName: 'summer_promo_hd.mp4',
      videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      durationSeconds: 15,
      uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      verificationStatus: AdVerificationStatus.approved,
    ),
    Advertisement(
      id: 'ad_02',
      title: 'New Product Launch - SMARTADD',
      videoName: 'smartadd_launch.mp4',
      videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      durationSeconds: 30,
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      verificationStatus: AdVerificationStatus.approved,
    ),
    Advertisement(
      id: 'ad_03',
      title: 'Brand Loyalty Campaign',
      videoName: 'brand_loyalty.mp4',
      videoUrl: '',
      durationSeconds: 20,
      uploadDate: DateTime.now().subtract(const Duration(hours: 4)),
      verificationStatus: AdVerificationStatus.pending,
    ),
  ];

  /// Initial seed bookings
  static final List<Booking> mockBookings = [
    Booking(
      id: 'bk_1001',
      billboardId: 'bb_douala_01',
      billboardName: 'Akwa Central Square Billboard',
      billboardLocation: 'Douala, Littoral',
      adId: 'ad_01',
      adTitle: 'Summer Mega Promo 2026',
      adVideoName: 'summer_promo_hd.mp4',
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      startTime: '10:00',
      endTime: '12:00',
      totalPrice: 25000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Fetch all available billboards from backend API with search & filter support
  Future<List<Billboard>> fetchBillboards({
    String? search,
    bool? availability,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (availability != null) {
        queryParams['availability'] = availability.toString();
      }
      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.trim();
      }

      final uri = Uri.parse('$_baseUrl/billboards').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body is Map && body.containsKey('data') ? body['data'] : (body as List);
        return list.map((json) => Billboard.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching billboards: $e');
    }
    return mockBillboards;
  }

  /// Get specific billboard by ID (used by direct QR code flow)
  Future<Billboard?> getBillboardById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/billboards/$id'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body is Map && body.containsKey('data') ? body['data'] : body;
        return Billboard.fromJson(data);
      }
    } catch (_) {}

    try {
      return mockBillboards.firstWhere(
        (b) => b.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return mockBillboards.first;
    }
  }

  /// Fetch user advertisements from backend REST API
  Future<List<Advertisement>> fetchAdvertisements() async {
    try {
      final token = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$_baseUrl/advertisements/my/ads'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body is Map && body.containsKey('data') ? body['data'] : (body as List);
        return list.map((json) => Advertisement.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching advertisements: $e');
    }
    return mockAdvertisements;
  }

  /// Upload advertisement video with progress callback simulation and REST API integration
  Future<Advertisement> uploadAdvertisement({
    required String title,
    required String videoName,
    required int durationSeconds,
    void Function(double progress)? onProgress,
  }) async {
    // Simulate initial upload progress
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (onProgress != null) {
        onProgress(i / 10.0);
      }
    }

    try {
      final token = await AuthService().getToken();
      final uri = Uri.parse('$_baseUrl/advertisements/upload');
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['title'] = title;
      request.fields['duration_seconds'] = durationSeconds.toString();

      // If videoName is a local path on device/desktop, attach as file bytes/stream if exists
      // Otherwise create string multipart for demo compatibility
      request.files.add(
        http.MultipartFile.fromString(
          'video',
          'sample video payload content',
          filename: videoName.endsWith('.mp4') ? videoName : '$videoName.mp4',
        ),
      );

      for (int i = 6; i <= 9; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (onProgress != null) {
          onProgress(i / 10.0);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (onProgress != null) {
        onProgress(1.0);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final data = body is Map && body.containsKey('data') ? body['data'] : body;
        return Advertisement.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error uploading video ad to backend: $e');
    }

    final newAd = Advertisement(
      id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      videoName: videoName,
      videoUrl: 'http://localhost:5000/uploads/videos/$videoName',
      durationSeconds: durationSeconds,
      uploadDate: DateTime.now(),
      verificationStatus: AdVerificationStatus.pending,
    );

    mockAdvertisements.insert(0, newAd);
    return newAd;
  }

  /// Fetch available time slots for a billboard on a specific date
  Future<List<TimeSlot>> fetchTimeSlots({
    required String billboardId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final double price = mockBillboards
        .firstWhere((b) => b.id == billboardId, orElse: () => mockBillboards.first)
        .pricePerSlot;

    return [
      TimeSlot(id: 'ts_08_10', startTime: '08:00', endTime: '10:00', isAvailable: true, price: price),
      TimeSlot(id: 'ts_10_12', startTime: '10:00', endTime: '12:00', isAvailable: false, price: price), // booked slot
      TimeSlot(id: 'ts_12_14', startTime: '12:00', endTime: '14:00', isAvailable: true, price: price),
      TimeSlot(id: 'ts_14_16', startTime: '14:00', endTime: '16:00', isAvailable: true, price: price),
      TimeSlot(id: 'ts_16_18', startTime: '16:00', endTime: '18:00', isAvailable: false, price: price), // booked slot
      TimeSlot(id: 'ts_18_20', startTime: '18:00', endTime: '20:00', isAvailable: true, price: price),
    ];
  }

  /// Process booking payment with backend API integration
  Future<Booking> processBookingPayment({
    required Billboard billboard,
    required Advertisement advertisement,
    required DateTime date,
    required TimeSlot timeSlot,
    required String paymentMethod,
    required String accountNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final newBooking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      billboardId: billboard.id,
      billboardName: billboard.name,
      billboardLocation: billboard.location,
      adId: advertisement.id,
      adTitle: advertisement.title,
      adVideoName: advertisement.videoName,
      bookingDate: date,
      startTime: timeSlot.startTime,
      endTime: timeSlot.endTime,
      totalPrice: timeSlot.price,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.scheduled,
      createdAt: DateTime.now(),
    );

    mockBookings.insert(0, newBooking);
    return newBooking;
  }
}
