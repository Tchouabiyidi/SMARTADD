import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../models/billboard.dart';
import '../../models/time_slot.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'advertiser_main_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Billboard billboard;
  final Advertisement advertisement;
  final DateTime date;
  final TimeSlot timeSlot;

  const PaymentScreen({
    super.key,
    required this.billboard,
    required this.advertisement,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'MTN Mobile Money';
  final TextEditingController _phoneController = TextEditingController(text: '670000000');
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile money phone number')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<AdvertiserProvider>(context, listen: false);

    // Call payment API endpoint via provider
    final booking = await provider.processPayment(
      billboard: widget.billboard,
      advertisement: widget.advertisement,
      date: widget.date,
      timeSlot: widget.timeSlot,
      paymentMethod: _selectedMethod,
      accountNumber: _phoneController.text.trim(),
    );

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      if (booking != null) {
        // Show success confirmation modal dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 48),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment processed successfully. Your booking is confirmed and scheduled.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const Divider(height: 24),
                  _buildReceiptRow('Booking ID:', booking.id),
                  _buildReceiptRow('Billboard:', booking.billboardName),
                  _buildReceiptRow('Advertisement:', booking.adTitle),
                  _buildReceiptRow('Time Slot:', '${booking.startTime} - ${booking.endTime}'),
                  _buildReceiptRow('Amount Paid:', currencyFormatter.format(booking.totalPrice)),
                  _buildReceiptRow('Status:', booking.bookingStatus.label),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AdvertiserMainScreen(initialTabIndex: 4)),
                      (route) => false,
                    );
                  },
                  child: const Text('View My Bookings'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Booking not confirmed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Payment'),
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
              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const Divider(height: 20),

                    _buildSummaryRow('Billboard:', widget.billboard.name),
                    _buildSummaryRow('Location:', widget.billboard.location),
                    _buildSummaryRow('Advertisement:', widget.advertisement.title),
                    _buildSummaryRow('Date:', dateFormat.format(widget.date)),
                    _buildSummaryRow('Time Slot:', '${widget.timeSlot.startTime} - ${widget.timeSlot.endTime}'),
                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          currencyFormatter.format(widget.timeSlot.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildPaymentMethodOption(
                title: 'MTN Mobile Money',
                subtitle: 'Fast mobile payment',
                icon: Icons.phone_android_rounded,
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 8),

              _buildPaymentMethodOption(
                title: 'Orange Money',
                subtitle: 'Orange Mobile Cash',
                icon: Icons.smartphone_rounded,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 8),

              _buildPaymentMethodOption(
                title: 'Credit / Debit Card',
                subtitle: 'Visa & MasterCard',
                icon: Icons.credit_card_rounded,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 24),

              // Account / Phone Number Field
              CustomTextField(
                label: _selectedMethod.contains('Card') ? 'Card Number' : 'Mobile Phone Number',
                hint: _selectedMethod.contains('Card') ? '4000 0000 0000 0000' : 'e.g. 670000000',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Pay ${currencyFormatter.format(widget.timeSlot.price)} & Confirm',
                icon: Icons.lock_rounded,
                isLoading: _isProcessing,
                onPressed: _handlePayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
