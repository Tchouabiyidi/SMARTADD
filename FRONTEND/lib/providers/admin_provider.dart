import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/billboard.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<User> _users = [];
  List<Billboard> _billboards = [];
  List<Advertisement> _pendingAds = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<User> get users => _users;
  List<Billboard> get billboards => _billboards;
  List<Advertisement> get pendingAds => _pendingAds;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // System Metrics
  int get totalUsers => _users.length;
  int get advertisersCount => _users.where((u) => u.role == UserRole.advertiser).length;
  int get ownersCount => _users.where((u) => u.role == UserRole.billboardOwner).length;
  int get totalBillboards => _billboards.length;
  int get pendingAdsCount => _pendingAds.length;
  int get activeBookingsCount => _bookings.where((b) => b.playbackStatus == PlaybackStatus.playing || b.bookingStatus == BookingStatus.confirmed).length;
  int get completedBookingsCount => _bookings.where((b) => b.playbackStatus == PlaybackStatus.completed).length;

  double get totalRevenue {
    double sum = 0.0;
    for (final b in _bookings) {
      if (b.paymentStatus == PaymentStatus.paid) {
        sum += b.totalPrice;
      }
    }
    return sum;
  }

  AdminProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    _users = await _adminService.fetchUsers();
    _billboards = await _adminService.fetchAllBillboards();
    _pendingAds = await _adminService.fetchPendingAds();
    _bookings = await _adminService.fetchAllBookings();

    _isLoading = false;
    notifyListeners();
  }

  // User Actions
  Future<bool> updateUser(User user) async {
    final success = await _adminService.updateUser(user);
    if (success) {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> deleteUser(String userId) async {
    final success = await _adminService.deleteUser(userId);
    if (success) {
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    }
    return success;
  }

  // Ad Verification Actions
  Future<bool> approveAd(String adId) async {
    final success = await _adminService.approveAd(adId);
    if (success) {
      _pendingAds.removeWhere((ad) => ad.id == adId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> rejectAd(String adId, String reason) async {
    final success = await _adminService.rejectAd(adId, reason);
    if (success) {
      _pendingAds.removeWhere((ad) => ad.id == adId);
      notifyListeners();
    }
    return success;
  }

  // Billboard Management Actions
  Future<bool> addBillboard({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    required double pricePerSlot,
    required String ownerName,
    required String connectionInfo,
  }) async {
    final newId = 'BILL-00${_billboards.length + 1}';
    final billboard = Billboard(
      id: newId,
      name: name,
      location: location,
      address: location,
      latitude: latitude,
      longitude: longitude,
      pricePerSlot: pricePerSlot,
      status: 'ACTIVE',
      isAvailable: true,
      isPowerOn: true,
      connectionInfo: connectionInfo,
      bookingUrl: 'http://localhost:3000/billboards/$newId/book',
      dimensions: '8m x 4m',
      ownerName: ownerName,
      availableTimeSlots: const ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00'],
    );

    final success = await _adminService.addBillboard(billboard);
    if (success) {
      _billboards.add(billboard);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateBillboard(Billboard billboard) async {
    final success = await _adminService.updateBillboard(billboard);
    if (success) {
      final index = _billboards.indexWhere((b) => b.id == billboard.id);
      if (index != -1) {
        _billboards[index] = billboard;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> deleteBillboard(String billboardId) async {
    final success = await _adminService.deleteBillboard(billboardId);
    if (success) {
      _billboards.removeWhere((b) => b.id == billboardId);
      notifyListeners();
    }
    return success;
  }
}
