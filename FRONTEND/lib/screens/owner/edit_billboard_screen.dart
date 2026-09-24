import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billboard.dart';
import '../../providers/owner_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditBillboardScreen extends StatefulWidget {
  final Billboard billboard;

  const EditBillboardScreen({
    super.key,
    required this.billboard,
  });

  @override
  State<EditBillboardScreen> createState() => _EditBillboardScreenState();
}

class _EditBillboardScreenState extends State<EditBillboardScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.billboard.name);
    _locationController = TextEditingController(text: widget.billboard.location);
    _priceController = TextEditingController(text: widget.billboard.pricePerSlot.toInt().toString());
    _isAvailable = widget.billboard.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final ownerProvider = Provider.of<OwnerProvider>(context, listen: false);

    final String name = _nameController.text.trim();
    final String location = _locationController.text.trim();
    final double price = double.tryParse(_priceController.text.trim()) ?? widget.billboard.pricePerSlot;

    final success = await ownerProvider.updateBillboard(
      id: widget.billboard.id,
      name: name,
      location: location,
      pricePerSlot: price,
      isAvailable: _isAvailable,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Billboard updated successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text('Edit ${widget.billboard.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Billboard ID Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.display_settings_rounded, color: AppTheme.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editing Billboard ID: ${widget.billboard.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Owner: ${widget.billboard.ownerName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              CustomTextField(
                label: 'Billboard Name',
                hint: 'Name',
                controller: _nameController,
                prefixIcon: const Icon(Icons.edit_note_rounded),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter billboard name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              CustomTextField(
                label: 'Location',
                hint: 'Location',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter location';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price Field
              CustomTextField(
                label: 'Price per Slot (FCFA)',
                hint: 'Price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.payments_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter price';
                  return null;
                },
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
                  title: const Text('Billboard Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_isAvailable ? 'Available for new bookings' : 'Marked as booked / unavailable'),
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

              CustomButton(
                text: 'Save Changes',
                icon: Icons.save_rounded,
                isLoading: ownerProvider.isLoading,
                onPressed: ownerProvider.isLoading ? null : _submitUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
