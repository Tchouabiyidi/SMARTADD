class Billboard {
  final String id;
  final String name;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerSlot; // formatted in FCFA
  final String status; // 'ACTIVE', 'MAINTENANCE', 'OFFLINE'
  final bool isAvailable;
  final String ownerName;
  final String dimensions;
  final List<String> availableTimeSlots; // e.g. ['08:00 - 10:00', '10:00 - 12:00', ...]
  final bool isPowerOn;
  final String connectionInfo;
  final String bookingUrl;
  final String? imageUrl;

  const Billboard({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerSlot,
    required this.status,
    required this.isAvailable,
    required this.ownerName,
    required this.dimensions,
    required this.availableTimeSlots,
    this.isPowerOn = true,
    this.connectionInfo = 'Display Output #1 - Active',
    this.bookingUrl = '',
    this.imageUrl,
  });

  factory Billboard.fromJson(Map<String, dynamic> json) {
    final String bId = json['id']?.toString() ?? json['_id']?.toString() ?? 'BILL-001';
    return Billboard(
      id: bId,
      name: json['name'] ?? 'Smart Billboard',
      location: json['location'] ?? 'Douala, Cameroon',
      address: json['address'] ?? json['location'] ?? 'Douala Central',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 4.0511,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 9.7679,
      pricePerSlot: (json['pricePerSlot'] ?? json['price'] as num?)?.toDouble() ?? 15000.0,
      status: json['status'] ?? 'ACTIVE',
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      ownerName: json['ownerName'] ?? json['owner'] ?? 'Billboard Owner',
      dimensions: json['dimensions'] ?? '6m x 3m',
      availableTimeSlots: (json['availableTimeSlots'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            '08:00 - 10:00',
            '10:00 - 12:00',
            '12:00 - 14:00',
            '14:00 - 16:00',
            '16:00 - 18:00',
            '18:00 - 20:00'
          ],
      isPowerOn: json['isPowerOn'] ?? json['power'] ?? true,
      connectionInfo: json['connectionInfo'] ?? 'Display Output #1 - Active',
      bookingUrl: json['bookingUrl'] ?? '/billboards/$bId/book',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerSlot': pricePerSlot,
      'status': status,
      'isAvailable': isAvailable,
      'ownerName': ownerName,
      'dimensions': dimensions,
      'availableTimeSlots': availableTimeSlots,
      'isPowerOn': isPowerOn,
      'connectionInfo': connectionInfo,
      'bookingUrl': bookingUrl,
      'imageUrl': imageUrl,
    };
  }

  Billboard copyWith({
    String? id,
    String? name,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    double? pricePerSlot,
    String? status,
    bool? isAvailable,
    String? ownerName,
    String? dimensions,
    List<String>? availableTimeSlots,
    bool? isPowerOn,
    String? connectionInfo,
    String? bookingUrl,
    String? imageUrl,
  }) {
    return Billboard(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerSlot: pricePerSlot ?? this.pricePerSlot,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      ownerName: ownerName ?? this.ownerName,
      dimensions: dimensions ?? this.dimensions,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      isPowerOn: isPowerOn ?? this.isPowerOn,
      connectionInfo: connectionInfo ?? this.connectionInfo,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class BillboardFilter {
  final String searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final bool? onlyAvailable;

  const BillboardFilter({
    this.searchQuery = '',
    this.minPrice,
    this.maxPrice,
    this.onlyAvailable,
  });

  BillboardFilter copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable,
  }) {
    return BillboardFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }
}
