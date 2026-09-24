import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/billboard.dart';
import '../../providers/owner_provider.dart';
import '../../theme/app_theme.dart';
import 'edit_billboard_screen.dart';
import 'widgets/power_control_widget.dart';
import 'widgets/qr_code_dialog.dart';

class OwnerBillboardDetailScreen extends StatelessWidget {
  final Billboard billboard;

  const OwnerBillboardDetailScreen({
    super.key,
    required this.billboard,
  });

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);
    // Get live updated billboard instance from provider
    final liveBillboard = ownerProvider.ownerBillboards.firstWhere(
      (b) => b.id == billboard.id,
      orElse: () => billboard,
    );

    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(liveBillboard.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'QR Code',
            onPressed: () => QRCodeDialog.show(context, liveBillboard),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditBillboardScreen(billboard: liveBillboard),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Placeholder / Gradient Banner
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${liveBillboard.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      liveBillboard.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Integrated Power Control Box
            PowerControlWidget(billboard: liveBillboard),
            const SizedBox(height: 20),

            // Billboard Information Card
            const Text('Billboard Specs & Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                children: [
                  _buildSpecRow(Icons.payments_rounded, 'Price per Slot', currencyFormatter.format(liveBillboard.pricePerSlot)),
                  const Divider(height: 20),
                  _buildSpecRow(Icons.aspect_ratio_rounded, 'Dimensions', liveBillboard.dimensions),
                  const Divider(height: 20),
                  _buildSpecRow(
                    Icons.event_available_rounded,
                    'Availability',
                    liveBillboard.isAvailable ? 'AVAILABLE FOR BOOKING' : 'CURRENTLY BOOKED',
                    color: liveBillboard.isAvailable ? AppTheme.successGreen : Colors.orange,
                  ),
                  const Divider(height: 20),
                  _buildSpecRow(Icons.cable_rounded, 'Connection Info', liveBillboard.connectionInfo),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Location & Map Preview
            const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGray),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(liveBillboard.latitude, liveBillboard.longitude),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.smartadd.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(liveBillboard.latitude, liveBillboard.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primaryBlue,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Time Slots Schedule
            const Text('Time Slots Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: liveBillboard.availableTimeSlots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        slot,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Generate QR Code Action Button
            ElevatedButton.icon(
              onPressed: () => QRCodeDialog.show(context, liveBillboard),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryBlue,
              ),
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('View & Share QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
