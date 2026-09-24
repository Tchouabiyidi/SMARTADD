import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/owner_provider.dart';
import '../../../theme/app_theme.dart';

class OwnerBookingsTab extends StatelessWidget {
  const OwnerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);
    final bookings = ownerProvider.ownerBookings;
    final dateFormat = DateFormat('EEE, dd MMM yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Billboard Bookings'),
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: AppTheme.textLight),
                  SizedBox(height: 16),
                  Text(
                    'No bookings found for your billboards',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                Color playbackColor;
                switch (booking.playbackStatus) {
                  case PlaybackStatus.playing:
                    playbackColor = AppTheme.successGreen;
                    break;
                  case PlaybackStatus.completed:
                    playbackColor = AppTheme.textSecondary;
                    break;
                  case PlaybackStatus.scheduled:
                    playbackColor = AppTheme.primaryBlue;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Billboard Name & Booking ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.billboardName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: playbackColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.playbackStatus.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: playbackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking ID: ${booking.id} • ${booking.billboardLocation}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const Divider(height: 20),

                        // Advertiser & Advertisement Details
                        Row(
                          children: [
                            const Icon(Icons.business_rounded, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            const Text('Advertiser: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Text(
                              booking.advertiserName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.movie_creation_outlined, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            const Text('Advertisement: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Expanded(
                              child: Text(
                                '${booking.adTitle} (${booking.adVideoName})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.event_note_rounded, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 8),
                            const Text('Date & Time: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Text(
                              '${dateFormat.format(booking.bookingDate)} (${booking.startTime} - ${booking.endTime})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Footer: Price & Payment Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: booking.paymentStatus == PaymentStatus.paid ? AppTheme.successGreen : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Payment Status: ${booking.paymentStatus.label}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: booking.paymentStatus == PaymentStatus.paid ? AppTheme.successGreen : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormatter.format(booking.totalPrice),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
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
