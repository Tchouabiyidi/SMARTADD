import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdvertiserProvider>(context);
    final bookings = provider.userBookings;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings made yet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Billboard Header & Booking ID
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                booking.id,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              booking.billboardLocation,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Advertisement Info & Schedule
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${booking.adTitle} (${booking.adVideoName})',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              dateFormat.format(booking.bookingDate),
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.schedule_rounded, color: AppTheme.textSecondary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${booking.startTime} - ${booking.endTime}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Status Badges & Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment & Playback', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    _buildStatusBadge(
                                      label: 'Pay: ${booking.paymentStatus.label}',
                                      color: booking.paymentStatus == PaymentStatus.paid
                                          ? AppTheme.successGreen
                                          : Colors.red,
                                    ),
                                    _buildStatusBadge(
                                      label: 'Play: ${booking.playbackStatus.label}',
                                      color: booking.playbackStatus == PlaybackStatus.playing
                                          ? AppTheme.primaryBlue
                                          : (booking.playbackStatus == PlaybackStatus.completed
                                              ? Colors.grey
                                              : AppTheme.primaryDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              currencyFormatter.format(booking.totalPrice),
                              style: const TextStyle(
                                fontSize: 16,
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

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
