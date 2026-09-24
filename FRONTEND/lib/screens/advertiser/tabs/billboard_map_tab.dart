import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../models/billboard.dart';
import '../../../providers/advertiser_provider.dart';
import '../../../theme/app_theme.dart';
import '../billboard_detail_screen.dart';

class BillboardMapTab extends StatefulWidget {
  const BillboardMapTab({super.key});

  @override
  State<BillboardMapTab> createState() => _BillboardMapTabState();
}

class _BillboardMapTabState extends State<BillboardMapTab> {
  final MapController _mapController = MapController();
  Billboard? _selectedBillboard;

  @override
  Widget build(BuildContext context) {
    final advertiserProvider = Provider.of<AdvertiserProvider>(context);
    final billboards = advertiserProvider.filteredBillboards;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    // Initial center point (Douala coordinates)
    final LatLng initialCenter = const LatLng(4.0511, 9.7679);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billboard Map'),
      ),
      body: Stack(
        children: [
          // Flutter Map View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedBillboard = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smartbillboard.smartadd',
              ),
              MarkerLayer(
                markers: billboards.map((billboard) {
                  final isSelected = _selectedBillboard?.id == billboard.id;
                  return Marker(
                    width: isSelected ? 54.0 : 44.0,
                    height: isSelected ? 54.0 : 44.0,
                    point: LatLng(billboard.latitude, billboard.longitude),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBillboard = billboard;
                        });
                        _mapController.move(
                          LatLng(billboard.latitude, billboard.longitude),
                          13.5,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryDark : AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.view_carousel_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Selected Billboard Info Card Popup
          if (_selectedBillboard != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedBillboard!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedBillboard = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _selectedBillboard!.location,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selectedBillboard!.isAvailable
                                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedBillboard!.isAvailable ? 'AVAILABLE' : 'BOOKED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _selectedBillboard!.isAvailable ? AppTheme.successGreen : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${currencyFormatter.format(_selectedBillboard!.pricePerSlot)} / slot',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 42),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text('View Details'),
                            onPressed: () {
                              final b = _selectedBillboard!;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BillboardDetailScreen(billboard: b),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
