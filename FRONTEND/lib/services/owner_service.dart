import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/billboard.dart';
import '../models/booking.dart';

class OwnerService {
  final String baseUrl;

  OwnerService({this.baseUrl = 'http://localhost:5000/api'});

  static int _billboardCounter = 7;

  // Mock initial owner billboards
  final List<Billboard> _ownerBillboards = [
    const Billboard(
      id: 'BILL-001',
      name: 'Akwa Central Digital Billboard',
      location: 'Douala - Akwa',
      address: 'Boulevard de la Liberté, Akwa',
      latitude: 4.0511,
      longitude: 9.7085,
      pricePerSlot: 15000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Smart Owner',
      dimensions: '8m x 4m',
      availableTimeSlots: ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '18:00 - 20:00'],
      isPowerOn: true,
      connectionInfo: 'Display Output #1 - Active (Fiber 100Mbps)',
      bookingUrl: '/billboards/BILL-001/book',
    ),
    const Billboard(
      id: 'BILL-002',
      name: 'Bonanjo Highway Display',
      location: 'Douala - Bonanjo',
      address: 'Avenue du Général de Gaulle',
      latitude: 4.0435,
      longitude: 9.6892,
      pricePerSlot: 20000.0,
      status: 'ACTIVE',
      isAvailable: true,
      ownerName: 'Smart Owner',
      dimensions: '10m x 5m',
      availableTimeSlots: ['08:00 - 10:00', '12:00 - 14:00', '16:00 - 18:00'],
      isPowerOn: true,
      connectionInfo: 'Display Output #2 - Active (4G LTE)',
      bookingUrl: '/billboards/BILL-002/book',
    ),
    const Billboard(
      id: 'BILL-003',
      name: 'Bastos Express Billboard',
      location: 'Yaoundé - Bastos',
      address: 'Rue de Bastos, Yaoundé',
      latitude: 3.8860,
      longitude: 11.5150,
      pricePerSlot: 25000.0,
      status: 'ACTIVE',
      isAvailable: false,
      ownerName: 'Smart Owner',
      dimensions: '12m x 6m',
      availableTimeSlots: ['10:00 - 12:00', '14:00 - 16:00'],
      isPowerOn: false,
      connectionInfo: 'Display Output #1 - Power OFF',
      bookingUrl: '/billboards/BILL-003/book',
    ),
  ];

  // Mock initial owner bookings
  final List<Booking> _ownerBookings = [
    Booking(
      id: 'BOOK-901',
      billboardId: 'BILL-001',
      billboardName: 'Akwa Central Digital Billboard',
      billboardLocation: 'Douala - Akwa',
      advertiserId: 'ADV-101',
      advertiserName: 'Orange Mobile Cameroon',
      adId: 'AD-201',
      adTitle: 'Orange Money 5G Mega Promo',
      adVideoName: 'orange_5g_promo.mp4',
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      startTime: '10:00',
      endTime: '12:00',
      totalPrice: 15000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.scheduled,
    ),
    Booking(
      id: 'BOOK-902',
      billboardId: 'BILL-002',
      billboardName: 'Bonanjo Highway Display',
      billboardLocation: 'Douala - Bonanjo',
      advertiserId: 'ADV-102',
      advertiserName: 'MTN Mobile Money',
      adId: 'AD-202',
      adTitle: 'MTN MoMo Cashless Campaign',
      adVideoName: 'mtn_momo_2026.mp4',
      bookingDate: DateTime.now(),
      startTime: '08:00',
      endTime: '10:00',
      totalPrice: 20000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.playing,
    ),
    Booking(
      id: 'BOOK-903',
      billboardId: 'BILL-001',
      billboardName: 'Akwa Central Digital Billboard',
      billboardLocation: 'Douala - Akwa',
      advertiserId: 'ADV-103',
      advertiserName: 'UBA Cameroon',
      adId: 'AD-203',
      adTitle: 'UBA Africard Digital Banking',
      adVideoName: 'uba_africard.mp4',
      bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '14:00',
      endTime: '16:00',
      totalPrice: 15000.0,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      playbackStatus: PlaybackStatus.completed,
    ),
  ];

  Future<List<Billboard>> getOwnerBillboards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/owner/billboards'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Billboard.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback mock
    }
    return List.from(_ownerBillboards);
  }

  Future<Billboard?> addBillboard({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    required double pricePerSlot,
    required bool isAvailable,
    required String connectionInfo,
    String dimensions = '8m x 4m',
  }) async {
    final String nextId = 'BILL-00${_billboardCounter++}';
    final newBillboard = Billboard(
      id: nextId,
      name: name,
      location: location,
      address: location,
      latitude: latitude,
      longitude: longitude,
      pricePerSlot: pricePerSlot,
      status: 'ACTIVE',
      isAvailable: isAvailable,
      ownerName: 'Smart Owner',
      dimensions: dimensions,
      availableTimeSlots: const [
        '08:00 - 10:00',
        '10:00 - 12:00',
        '12:00 - 14:00',
        '14:00 - 16:00',
        '16:00 - 18:00'
      ],
      isPowerOn: true,
      connectionInfo: connectionInfo.isNotEmpty ? connectionInfo : 'Display Output #1 - Active',
      bookingUrl: '/billboards/$nextId/book',
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/owner/billboards'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newBillboard.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Billboard.fromJson(json.decode(response.body));
      }
    } catch (_) {
      // Fallback mock
    }
    _ownerBillboards.insert(0, newBillboard);
    return newBillboard;
  }

  Future<Billboard?> updateBillboard({
    required String id,
    required String name,
    required String location,
    required double pricePerSlot,
    required bool isAvailable,
  }) async {
    final index = _ownerBillboards.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = _ownerBillboards[index].copyWith(
        name: name,
        location: location,
        pricePerSlot: pricePerSlot,
        isAvailable: isAvailable,
      );
      _ownerBillboards[index] = updated;

      try {
        await http.put(
          Uri.parse('$baseUrl/owner/billboards/$id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updated.toJson()),
        );
      } catch (_) {}
      return updated;
    }
    return null;
  }

  Future<bool> togglePower(String billboardId, bool powerOn) async {
    final index = _ownerBillboards.indexWhere((b) => b.id == billboardId);
    if (index != -1) {
      _ownerBillboards[index] = _ownerBillboards[index].copyWith(
        isPowerOn: powerOn,
        connectionInfo: powerOn ? 'Display Output #1 - Active' : 'Display Output #1 - Power OFF',
      );
      try {
        await http.post(
          Uri.parse('$baseUrl/owner/billboards/$billboardId/power'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'powerOn': powerOn}),
        );
      } catch (_) {}
      return true;
    }
    return false;
  }

  Future<List<Booking>> getOwnerBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/owner/bookings'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.from(_ownerBookings);
  }
}
