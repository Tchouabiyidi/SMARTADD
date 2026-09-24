import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../models/billboard.dart';
import '../../models/time_slot.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'my_advertisements_screen.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Billboard? preselectedBillboard;

  const BookingScreen({
    super.key,
    this.preselectedBillboard,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Billboard? _selectedBillboard;
  Advertisement? _selectedAdvertisement;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _timeSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _selectedBillboard = widget.preselectedBillboard;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdvertiserProvider>(context, listen: false);
      if (_selectedBillboard == null && provider.billboards.isNotEmpty) {
        _selectedBillboard = provider.billboards.first;
      }
      final approvedAds = provider.approvedAdvertisements;
      if (approvedAds.isNotEmpty) {
        _selectedAdvertisement = approvedAds.first;
      }
      _loadSlots();
    });
  }

  Future<void> _loadSlots() async {
    if (_selectedBillboard == null) return;

    setState(() {
      _isLoadingSlots = true;
      _selectedTimeSlot = null;
    });

    final provider = Provider.of<AdvertiserProvider>(context, listen: false);
    final slots = await provider.getTimeSlots(_selectedBillboard!.id, _selectedDate);

    setState(() {
      _timeSlots = slots;
      _isLoadingSlots = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdvertiserProvider>(context);
    final approvedAds = provider.approvedAdvertisements;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Book Billboard Slot'),
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
              // Step 1: Billboard Selection
              const Text(
                '1. Selected Billboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<Billboard>(
                initialValue: _selectedBillboard,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.view_carousel_rounded, color: AppTheme.primaryBlue),
                ),
                items: provider.billboards.map((b) {
                  return DropdownMenuItem(
                    value: b,
                    child: Text('${b.name} (${b.location})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBillboard = val;
                    });
                    _loadSlots();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Step 2: Select Approved Advertisement (Prerequisite enforce)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2. Select Approved Advertisement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  if (approvedAds.isEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MyAdvertisementsScreen()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Upload Ad'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (approvedAds.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have no APPROVED advertisements. Please upload an advertisement video and await approval before booking.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<Advertisement>(
                  initialValue: _selectedAdvertisement,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryBlue),
                  ),
                  items: approvedAds.map((ad) {
                    return DropdownMenuItem(
                      value: ad,
                      child: Text('${ad.title} (${ad.durationSeconds}s)', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedAdvertisement = val;
                    });
                  },
                ),
              const SizedBox(height: 24),

              // Step 3: Date Picker
              const Text(
                '3. Choose Playback Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _loadSlots();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Text(
                        dateFormat.format(_selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step 4: Time Slot Selection (Collision Prevention)
              const Text(
                '4. Select Time Slot',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),

              if (_isLoadingSlots)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_timeSlots.isEmpty)
                const Text('No slots available on selected date')
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot?.id == slot.id;
                    final isAvailable = slot.isAvailable;

                    return ChoiceChip(
                      label: Text(
                        '${slot.timeRange} ${!isAvailable ? '(Booked)' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: !isAvailable
                              ? Colors.grey
                              : (isSelected ? Colors.white : AppTheme.textPrimary),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryBlue,
                      disabledColor: Colors.grey.shade200,
                      avatar: Icon(
                        isAvailable ? Icons.access_time_rounded : Icons.lock_rounded,
                        size: 16,
                        color: !isAvailable
                            ? Colors.grey
                            : (isSelected ? Colors.white : AppTheme.primaryBlue),
                      ),
                      onSelected: isAvailable
                          ? (selected) {
                              setState(() {
                                _selectedTimeSlot = selected ? slot : null;
                              });
                            }
                          : null,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),

              // Summary Box & Payment Button
              if (_selectedTimeSlot != null && _selectedBillboard != null && _selectedAdvertisement != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price:', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          SizedBox(height: 2),
                          Text('1 Playback Slot', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                        ],
                      ),
                      Text(
                        currencyFormatter.format(_selectedTimeSlot!.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              CustomButton(
                text: 'Continue to Payment',
                icon: Icons.payment_rounded,
                onPressed: (_selectedBillboard != null &&
                        _selectedAdvertisement != null &&
                        _selectedTimeSlot != null)
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              billboard: _selectedBillboard!,
                              advertisement: _selectedAdvertisement!,
                              date: _selectedDate,
                              timeSlot: _selectedTimeSlot!,
                            ),
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
}
