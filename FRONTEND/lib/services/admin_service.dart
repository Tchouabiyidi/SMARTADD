import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/advertisement.dart';
import '../models/billboard.dart';
import '../models/booking.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AdminService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Seed Mock Users
  final List<User> _mockUsers = [
    const User(
      id: 'USR-001',
      fullName: 'Alice Johnson',
      email: 'alice@advertiser.com',
      phone: '+237 670 112 233',
      role: UserRole.advertiser,
    ),
    const User(
      id: 'USR-002',
      fullName: 'Bob Smith',
      email: 'bob@owner.com',
      phone: '+237 699 445 566',
      role: UserRole.billboardOwner,
    ),
    const User(
      id: 'USR-003',
      fullName: 'Charles Admin',
      email: 'admin@smartadd.com',
      phone: '+237 655 778 899',
      role: UserRole.admin,
    ),
    const User(
      id: 'USR-004',
      fullName: 'David Guetta Ads',
      email: 'david@brand.com',
      phone: '+237 680 990 011',
      role: UserRole.advertiser,
    ),
    const User(
      id: 'USR-005',
      fullName: 'Emma Watson Displays',
      email: 'emma@displays.cm',
      phone: '+237 677 223 344',
      role: UserRole.billboardOwner,
    ),
  ];

  // Seed Mock Pending Ads
  final List<Advertisement> _mockPendingAds = [
    Advertisement(
      id: 'AD-101',
      advertiserId: 'USR-001',
      title: 'Summer Fashion Promo 2026',
      videoUrl: 'https://smartadd.com/media/summer_fashion.mp4',
      videoName: 'summer_fashion_2026.mp4',
      durationSeconds: 30,
      verificationStatus: AdVerificationStatus.pending,
      uploadDate: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Advertisement(
      id: 'AD-102',
      advertiserId: 'USR-004',
      title: 'Orange Cameroun Mobile Money Campaign',
      videoUrl: 'https://smartadd.com/media/orange_money.mp4',
      videoName: 'orange_money_spot.mp4',
      durationSeconds: 15,
      verificationStatus: AdVerificationStatus.pending,
      uploadDate: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // Seed Mock Billboards
  final List<Billboard> _mockBillboards = [
    Billboard(
      id: 'BILL-001',
      name: 'Akwa Commercial Tower Billboard',
      location: 'Boulevard de la Liberté, Douala',
      address: 'Boulevard de la Liberté, Douala',
      latitude: 4.0511,
      longitude: 9.7085,
      pricePerSlot: 15000.0,
      status: 'ACTIVE',
      isAvailable: true,
      isPowerOn: true,
      connectionInfo: 'Display Output #1 - Active (Fiber)',
      bookingUrl: 'http://localhost:3000/billboards/BILL-001/book',
      dimensions: '8m x 4m',
      ownerName: 'Bob Smith',
      availableTimeSlots: const ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00'],
    ),
    Billboard(
      id: 'BILL-002',
      name: 'Bonanjo Administrative Plaza Display',
      location: 'Place du Gouvernement, Douala',
      address: 'Place du Gouvernement, Douala',
      latitude: 4.0435,
      longitude: 9.6892,
      pricePerSlot: 25000.0,
      status: 'ACTIVE',
      isAvailable: true,
      isPowerOn: true,
      connectionInfo: 'Display Output #2 - Active (5G)',
      bookingUrl: 'http://localhost:3000/billboards/BILL-002/book',
      dimensions: '12m x 6m',
      ownerName: 'Emma Watson Displays',
      availableTimeSlots: const ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00'],
    ),
    Billboard(
      id: 'BILL-003',
      name: 'Bastos Junction Billboard',
      location: 'Avenue Rose, Yaoundé',
      address: 'Avenue Rose, Yaoundé',
      latitude: 3.8821,
      longitude: 11.5167,
      pricePerSlot: 18000.0,
      status: 'ACTIVE',
      isAvailable: false,
      isPowerOn: false,
      connectionInfo: 'Display Output #3 - Power Standby',
      bookingUrl: 'http://localhost:3000/billboards/BILL-003/book',
      dimensions: '10m x 5m',
      ownerName: 'Bob Smith',
      availableTimeSlots: const ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00'],
    ),
  ];

  // Seed Mock Bookings
  final List<Booking> _mockBookings = [
    Booking(
      id: 'BKG-501',
      billboardId: 'BILL-001',
      billboardName: 'Akwa Commercial Tower Billboard',
      billboardLocation: 'Boulevard de la Liberté, Douala',
      advertiserId: 'USR-001',
      advertiserName: 'Alice Johnson',
      adId: 'AD-001',
      adTitle: 'MTN MoMo Mega Promo',
      adVideoName: 'mtn_momo_spot.mp4',
      bookingDate: DateTime.now(),
      startTime: '08:00',
      endTime: '10:00',
      totalPrice: 15000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.playing,
    ),
    Booking(
      id: 'BKG-502',
      billboardId: 'BILL-002',
      billboardName: 'Bonanjo Administrative Plaza Display',
      billboardLocation: 'Place du Gouvernement, Douala',
      advertiserId: 'USR-004',
      advertiserName: 'David Guetta Ads',
      adId: 'AD-002',
      adTitle: 'Guinness Smooth Launch',
      adVideoName: 'guinness_smooth.mp4',
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      startTime: '14:00',
      endTime: '16:00',
      totalPrice: 25000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.scheduled,
    ),
  ];

  // API or Mock Fetch Users
  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/users'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.from(_mockUsers);
  }

  // Update User / Role
  Future<bool> updateUser(User updatedUser) async {
    final index = _mockUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _mockUsers[index] = updatedUser;
      return true;
    }
    return false;
  }

  // Delete User
  Future<bool> deleteUser(String userId) async {
    _mockUsers.removeWhere((u) => u.id == userId);
    return true;
  }

  // Fetch Pending Advertisements from REST API
  Future<List<Advertisement>> fetchPendingAds() async {
    try {
      final token = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl/advertisements/pending'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body is Map && body.containsKey('data') ? body['data'] : (body as List);
        return data.map((json) => Advertisement.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching pending ads: $e');
    }
    return List.from(_mockPendingAds);
  }

  // Approve Advertisement via REST API
  Future<bool> approveAd(String adId) async {
    try {
      final token = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.put(
        Uri.parse('$baseUrl/advertisements/$adId/approve'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _mockPendingAds.removeWhere((ad) => ad.id == adId);
        return true;
      }
    } catch (e) {
      debugPrint('Error approving ad: $e');
    }
    _mockPendingAds.removeWhere((ad) => ad.id == adId);
    return true;
  }

  // Reject Advertisement via REST API
  Future<bool> rejectAd(String adId, String reason) async {
    try {
      final token = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.put(
        Uri.parse('$baseUrl/advertisements/$adId/reject'),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        _mockPendingAds.removeWhere((ad) => ad.id == adId);
        return true;
      }
    } catch (e) {
      debugPrint('Error rejecting ad: $e');
    }
    _mockPendingAds.removeWhere((ad) => ad.id == adId);
    return true;
  }

  // Fetch All Billboards
  Future<List<Billboard>> fetchAllBillboards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/billboards'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Billboard.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.from(_mockBillboards);
  }

  // Add Billboard (Admin)
  Future<bool> addBillboard(Billboard billboard) async {
    _mockBillboards.add(billboard);
    return true;
  }

  // Edit Billboard (Admin)
  Future<bool> updateBillboard(Billboard billboard) async {
    final index = _mockBillboards.indexWhere((b) => b.id == billboard.id);
    if (index != -1) {
      _mockBillboards[index] = billboard;
      return true;
    }
    return false;
  }

  // Delete Billboard (Admin)
  Future<bool> deleteBillboard(String billboardId) async {
    _mockBillboards.removeWhere((b) => b.id == billboardId);
    return true;
  }

  // Fetch All Bookings
  Future<List<Booking>> fetchAllBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/bookings'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.from(_mockBookings);
  }
}
