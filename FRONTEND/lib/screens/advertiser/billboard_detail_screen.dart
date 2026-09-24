import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../models/billboard.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'booking_screen.dart';

class BillboardDetailScreen extends StatelessWidget {
  final Billboard billboard;

  const BillboardDetailScreen({
    super.key,
    required this.billboard,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Billboard Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: billboard.isAvailable
                          ? AppTheme.successGreen.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          billboard.isAvailable ? Icons.check_circle_rounded : Icons.schedule_rounded,
                          size: 14,
                          color: billboard.isAvailable ? AppTheme.successGreen : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          billboard.isAvailable ? 'AVAILABLE FOR BOOKING' : 'FULLY BOOKED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: billboard.isAvailable ? AppTheme.successGreen : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ID: ${billboard.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                billboard.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${billboard.address}, ${billboard.location}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Specs Grid Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSpecCard(
                      label: 'Price per slot',
                      value: currencyFormatter.format(billboard.pricePerSlot),
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSpecCard(
                      label: 'Dimensions',
                      value: billboard.dimensions,
                      icon: Icons.aspect_ratio_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSpecCard(
                      label: 'Billboard Owner',
                      value: billboard.ownerName,
                      icon: Icons.business_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSpecCard(
                      label: 'Status',
                      value: billboard.status,
                      icon: Icons.info_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Location Mini Map Preview
              const Text(
                'Location Map',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(billboard.latitude, billboard.longitude),
                    initialZoom: 14.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartbillboard.smartadd',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(billboard.latitude, billboard.longitude),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.view_carousel_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Available Time Slots Schedule
              const Text(
                'Available Playback Slots',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: billboard.availableTimeSlots.map((slot) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderGray),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 6),
                        Text(
                          slot,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Book Billboard CTA
              CustomButton(
                text: 'Book This Billboard',
                icon: Icons.calendar_today_rounded,
                onPressed: billboard.isAvailable
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(preselectedBillboard: billboard),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
