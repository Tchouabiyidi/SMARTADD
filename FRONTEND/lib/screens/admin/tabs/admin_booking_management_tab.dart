import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/booking.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';

class AdminBookingManagementTab extends StatefulWidget {
  const AdminBookingManagementTab({super.key});

  @override
  State<AdminBookingManagementTab> createState() => _AdminBookingManagementTabState();
}

class _AdminBookingManagementTabState extends State<AdminBookingManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final bookings = adminProvider.bookings;
    final dateFormat = DateFormat('EEE, dd MMM yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    // Apply Filter & Search
    final query = _searchController.text.toLowerCase().trim();
    final filteredBookings = bookings.where((b) {
      final matchesQuery = b.id.toLowerCase().contains(query) ||
          b.billboardName.toLowerCase().contains(query) ||
          b.advertiserName.toLowerCase().contains(query) ||
          b.adTitle.toLowerCase().contains(query);

      if (_selectedStatusFilter == 'ALL') return matchesQuery;
      if (_selectedStatusFilter == 'PLAYING') return matchesQuery && b.playbackStatus == PlaybackStatus.playing;
      if (_selectedStatusFilter == 'SCHEDULED') return matchesQuery && b.playbackStatus == PlaybackStatus.scheduled;
      if (_selectedStatusFilter == 'COMPLETED') return matchesQuery && b.playbackStatus == PlaybackStatus.completed;
      return matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Platform Booking Oversight'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  label: '',
                  hint: 'Search by booking ID, billboard, advertiser, or ad...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Bookings (${bookings.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PLAYING', 'Playing Now'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SCHEDULED', 'Scheduled'),
                      const SizedBox(width: 8),
                      _buildFilterChip('COMPLETED', 'Completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(child: Text('No bookings match criteria.', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.billboardName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: playbackColor),
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

                              // Advertiser & Campaign info
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  const Text('Advertiser: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                  Text(
                                    booking.advertiserName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.movie_creation_outlined, size: 18, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  const Text('Ad Campaign: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                  Expanded(
                                    child: Text(
                                      '${booking.adTitle} (${booking.adVideoName})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.event_note_rounded, size: 18, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  const Text('Schedule: ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                  Text(
                                    '${dateFormat.format(booking.bookingDate)} (${booking.startTime} - ${booking.endTime})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),

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
                                        'Payment: ${booking.paymentStatus.label}',
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
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = value;
          });
        }
      },
    );
  }
}
