import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';

class AdminBillboardMonitoringTab extends StatelessWidget {
  const AdminBillboardMonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final billboards = adminProvider.billboards;
    final bookings = adminProvider.bookings;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Live Billboard Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () => adminProvider.loadData(),
          ),
        ],
      ),
      body: billboards.isEmpty
          ? const Center(child: Text('No billboards registered.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: billboards.length,
              itemBuilder: (context, index) {
                final billboard = billboards[index];

                // Find active booking playing on this billboard
                final activeBooking = bookings.firstWhere(
                  (b) => b.billboardId == billboard.id && (b.playbackStatus == PlaybackStatus.playing || b.playbackStatus == PlaybackStatus.scheduled),
                  orElse: () => Booking(
                    id: 'N/A',
                    billboardId: billboard.id,
                    billboardName: billboard.name,
                    billboardLocation: billboard.location,
                    adId: 'N/A',
                    adTitle: 'No Active Campaign',
                    adVideoName: 'standby_loop.mp4',
                    bookingDate: DateTime.now(),
                    startTime: 'N/A',
                    endTime: 'N/A',
                    totalPrice: 0.0,
                    paymentStatus: PaymentStatus.paid,
                    bookingStatus: BookingStatus.confirmed,
                    playbackStatus: PlaybackStatus.completed,
                  ),
                );

                final bool isLivePlaying = activeBooking.id != 'N/A';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Billboard Name & Live Status Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                billboard.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: billboard.isPowerOn ? AppTheme.successGreen.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: billboard.isPowerOn ? AppTheme.successGreen : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    billboard.isPowerOn ? 'ONLINE' : 'OFFLINE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: billboard.isPowerOn ? AppTheme.successGreen : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${billboard.id} • Location: ${billboard.location}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const Divider(height: 20),

                        // Connection Status & Latency
                        Row(
                          children: [
                            const Icon(Icons.cable_rounded, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            const Text('Connection Status: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Text(
                              '${billboard.connectionInfo} • 18ms Latency',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Availability
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            const Text('Availability: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Text(
                              billboard.isAvailable ? 'AVAILABLE FOR BOOKINGS' : 'CURRENTLY BOOKED',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: billboard.isAvailable ? AppTheme.successGreen : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Live Playback / Current Ad Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isLivePlaying ? AppTheme.primaryLight : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isLivePlaying ? AppTheme.primaryBlue.withValues(alpha: 0.3) : AppTheme.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isLivePlaying ? Icons.play_circle_fill_rounded : Icons.pause_circle_outline_rounded,
                                    color: isLivePlaying ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLivePlaying ? 'CURRENT PLAYING ADVERTISEMENT' : 'STANDBY MODE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isLivePlaying ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Campaign: ${activeBooking.adTitle}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Video: ${activeBooking.adVideoName} • Booking ID: ${activeBooking.id}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              if (isLivePlaying) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Advertiser: ${activeBooking.advertiserName} (${activeBooking.startTime} - ${activeBooking.endTime})',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
