import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/billboard.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import '../services/advertiser_service.dart';

class AdvertiserProvider extends ChangeNotifier {
  final AdvertiserService _service = AdvertiserService();

  List<Billboard> _billboards = [];
  List<Advertisement> _userAdvertisements = [];
  List<Booking> _userBookings = [];

  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  BillboardFilter _filter = const BillboardFilter();

  List<Billboard> get billboards => _billboards;
  List<Advertisement> get userAdvertisements => _userAdvertisements;
  List<Booking> get userBookings => _userBookings;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  BillboardFilter get filter => _filter;

  /// Filtered billboards list based on search and price
  List<Billboard> get filteredBillboards {
    return _billboards.where((b) {
      if (_filter.searchQuery.isNotEmpty) {
        final query = _filter.searchQuery.toLowerCase();
        final matchName = b.name.toLowerCase().contains(query);
        final matchLocation = b.location.toLowerCase().contains(query);
        final matchAddress = b.address.toLowerCase().contains(query);
        if (!matchName && !matchLocation && !matchAddress) return false;
      }
      if (_filter.minPrice != null && b.pricePerSlot < _filter.minPrice!) {
        return false;
      }
      if (_filter.maxPrice != null && b.pricePerSlot > _filter.maxPrice!) {
        return false;
      }
      if (_filter.onlyAvailable == true && !b.isAvailable) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get only approved advertisements ready for booking
  List<Advertisement> get approvedAdvertisements {
    return _userAdvertisements
        .where((ad) => ad.verificationStatus == AdVerificationStatus.approved)
        .toList();
  }

  /// Get active bookings
  List<Booking> get activeBookings {
    return _userBookings
        .where((b) => b.bookingStatus == BookingStatus.confirmed)
        .toList();
  }

  /// Get pending advertisements count
  int get pendingAdsCount {
    return _userAdvertisements
        .where((ad) => ad.verificationStatus == AdVerificationStatus.pending)
        .length;
  }

  /// Get upcoming advertisements count
  int get upcomingAdsCount {
    return _userBookings
        .where((b) => b.playbackStatus == PlaybackStatus.scheduled)
        .length;
  }

  AdvertiserProvider() {
    loadAllData();
  }

  /// Load all billboards, user advertisements, and bookings
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _billboards = await _service.fetchBillboards();
      _userAdvertisements = await _service.fetchAdvertisements();
      _userBookings = List.from(AdvertiserService.mockBookings);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query & filters
  void updateFilter(BillboardFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  /// Search billboards by keyword
  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  /// Upload advertisement video with progress
  Future<bool> uploadVideo({
    required String title,
    required String videoName,
    required int durationSeconds,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAd = await _service.uploadAdvertisement(
        title: title,
        videoName: videoName,
        durationSeconds: durationSeconds,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      _userAdvertisements.insert(0, newAd);
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch available time slots for a billboard
  Future<List<TimeSlot>> getTimeSlots(String billboardId, DateTime date) async {
    return await _service.fetchTimeSlots(billboardId: billboardId, date: date);
  }

  /// Process booking payment
  Future<Booking?> processPayment({
    required Billboard billboard,
    required Advertisement advertisement,
    required DateTime date,
    required TimeSlot timeSlot,
    required String paymentMethod,
    required String accountNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _service.processBookingPayment(
        billboard: billboard,
        advertisement: advertisement,
        date: date,
        timeSlot: timeSlot,
        paymentMethod: paymentMethod,
        accountNumber: accountNumber,
      );

      _userBookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Lookup billboard by ID (for QR code scanning flow)
  Future<Billboard?> resolveBillboardFromQR(String billboardId) async {
    return await _service.getBillboardById(billboardId);
  }
}
