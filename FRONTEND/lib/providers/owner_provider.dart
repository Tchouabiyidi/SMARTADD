import 'package:flutter/material.dart';
import '../models/billboard.dart';
import '../models/booking.dart';
import '../services/owner_service.dart';

class OwnerProvider extends ChangeNotifier {
  final OwnerService _ownerService = OwnerService();

  List<Billboard> _ownerBillboards = [];
  List<Booking> _ownerBookings = [];
  bool _isLoading = false;

  OwnerProvider() {
    loadData();
  }

  List<Billboard> get ownerBillboards => _ownerBillboards;
  List<Booking> get ownerBookings => _ownerBookings;
  bool get isLoading => _isLoading;

  int get totalBillboards => _ownerBillboards.length;
  int get activeBillboards => _ownerBillboards.where((b) => b.isPowerOn && b.status == 'ACTIVE').length;
  int get upcomingBookingsCount => _ownerBookings.where((b) => b.playbackStatus == PlaybackStatus.scheduled).length;
  int get currentAdsCount => _ownerBookings.where((b) => b.playbackStatus == PlaybackStatus.playing).length;

  Future<void> loadData() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    _ownerBillboards = await _ownerService.getOwnerBillboards();
    _ownerBookings = await _ownerService.getOwnerBookings();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBillboard({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    required double pricePerSlot,
    required bool isAvailable,
    required String connectionInfo,
    String dimensions = '8m x 4m',
  }) async {
    _isLoading = true;
    notifyListeners();

    final created = await _ownerService.addBillboard(
      name: name,
      location: location,
      latitude: latitude,
      longitude: longitude,
      pricePerSlot: pricePerSlot,
      isAvailable: isAvailable,
      connectionInfo: connectionInfo,
      dimensions: dimensions,
    );

    if (created != null) {
      _ownerBillboards.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBillboard({
    required String id,
    required String name,
    required String location,
    required double pricePerSlot,
    required bool isAvailable,
  }) async {
    _isLoading = true;
    notifyListeners();

    final updated = await _ownerService.updateBillboard(
      id: id,
      name: name,
      location: location,
      pricePerSlot: pricePerSlot,
      isAvailable: isAvailable,
    );

    if (updated != null) {
      final index = _ownerBillboards.indexWhere((b) => b.id == id);
      if (index != -1) {
        _ownerBillboards[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> togglePower(String billboardId, bool powerOn) async {
    final success = await _ownerService.togglePower(billboardId, powerOn);
    if (success) {
      final index = _ownerBillboards.indexWhere((b) => b.id == billboardId);
      if (index != -1) {
        _ownerBillboards[index] = _ownerBillboards[index].copyWith(
          isPowerOn: powerOn,
          connectionInfo: powerOn ? 'Display Output #1 - Active' : 'Display Output #1 - Power OFF',
        );
        notifyListeners();
      }
    }
  }
}
