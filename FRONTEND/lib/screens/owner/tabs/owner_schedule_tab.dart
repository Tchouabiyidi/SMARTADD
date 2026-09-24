import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../theme/app_theme.dart';

class OwnerScheduleTab extends StatefulWidget {
  const OwnerScheduleTab({super.key});

  @override
  State<OwnerScheduleTab> createState() => _OwnerScheduleTabState();
}

class _OwnerScheduleTabState extends State<OwnerScheduleTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);
    final bookings = ownerProvider.ownerBookings;
    final billboards = ownerProvider.ownerBillboards;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');

    // Filter bookings for selected date or show upcoming timeline
    final dateBookings = bookings.where((b) {
      return b.bookingDate.year == _selectedDate.year &&
          b.bookingDate.month == _selectedDate.month &&
          b.bookingDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Billboard Schedule Timeline'),
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Timeline Content per Owner Billboard
          Expanded(
            child: billboards.isEmpty
                ? const Center(child: Text('No billboards registered.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: billboards.length,
                    itemBuilder: (context, index) {
                      final billboard = billboards[index];
                      final billboardBookings = dateBookings.where((b) => b.billboardId == billboard.id).toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Billboard Title Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.display_settings_rounded, color: AppTheme.primaryBlue, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            billboard.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      billboard.id,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryBlue,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),

                              // Time Slots Timeline Entries
                              if (billboardBookings.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, color: AppTheme.successGreen, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'All time slots available for ${billboard.name}',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...billboardBookings.map((b) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, color: AppTheme.primaryBlue, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${b.startTime} - ${b.endTime}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Ad: ${b.adTitle} (${b.advertiserName})',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            b.playbackStatus.label,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.successGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
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
}
