import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class AddBillboardScreen extends StatefulWidget {
  final VoidCallback? onCreated;

  const AddBillboardScreen({
    super.key,
    this.onCreated,
  });

  @override
  State<AddBillboardScreen> createState() => _AddBillboardScreenState();
}

class _AddBillboardScreenState extends State<AddBillboardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController(text: '4.0511');
  final _lngController = TextEditingController(text: '9.7085');
  final _priceController = TextEditingController(text: '15000');
  final _connectionController = TextEditingController(text: 'Display Output #1 - Active (Fiber)');
  final _dimensionsController = TextEditingController(text: '8m x 4m');

  bool _isAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _priceController.dispose();
    _connectionController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final ownerProvider = Provider.of<OwnerProvider>(context, listen: false);

    final String name = _nameController.text.trim();
    final String location = _locationController.text.trim();
    final double lat = double.tryParse(_latController.text.trim()) ?? 4.0511;
    final double lng = double.tryParse(_lngController.text.trim()) ?? 9.7085;
    final double price = double.tryParse(_priceController.text.trim()) ?? 15000.0;
    final String connectionInfo = _connectionController.text.trim();
    final String dimensions = _dimensionsController.text.trim();

    final success = await ownerProvider.addBillboard(
      name: name,
      location: location,
      latitude: lat,
      longitude: lng,
      pricePerSlot: price,
      isAvailable: _isAvailable,
      connectionInfo: connectionInfo,
      dimensions: dimensions,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Billboard created successfully with unique ID generated!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      if (widget.onCreated != null) {
        widget.onCreated!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Add New Billboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A unique Billboard ID (e.g. BILL-007) will be automatically generated upon creation.',
                        style: TextStyle(fontSize: 13, color: AppTheme.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Billboard Name
              CustomTextField(
                label: 'Billboard Name',
                hint: 'e.g. Akwa Commercial Tower Billboard',
                controller: _nameController,
                prefixIcon: const Icon(Icons.display_settings_rounded),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter billboard name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              CustomTextField(
                label: 'Location / Address',
                hint: 'e.g. Boulevard de la Liberté, Douala',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_rounded),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter location';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Latitude & Longitude
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Latitude',
                      hint: '4.0511',
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Longitude',
                      hint: '9.7085',
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price & Dimensions
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price per Slot (FCFA)',
                      hint: '15000',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.payments_rounded),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Dimensions',
                      hint: '8m x 4m',
                      controller: _dimensionsController,
                      prefixIcon: const Icon(Icons.aspect_ratio_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Display Connection Info
              CustomTextField(
                label: 'Display Connection Info',
                hint: 'e.g. Display Output #1 - Fiber Connection',
                controller: _connectionController,
                prefixIcon: const Icon(Icons.cable_rounded),
              ),
              const SizedBox(height: 16),

              // Availability Switch
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Available for Bookings',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Allow advertisers to book time slots on this billboard'),
                  value: _isAvailable,
                  activeThumbColor: AppTheme.primaryBlue,
                  onChanged: (val) {
                    setState(() {
                      _isAvailable = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: 'Register Billboard',
                icon: Icons.check_circle_rounded,
                isLoading: ownerProvider.isLoading,
                onPressed: ownerProvider.isLoading ? null : _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
