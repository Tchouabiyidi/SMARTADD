import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/billboard.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';

class AdminBillboardManagementTab extends StatelessWidget {
  const AdminBillboardManagementTab({super.key});

  void _showAddBillboardModal(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final priceController = TextEditingController(text: '20000');
    final ownerController = TextEditingController(text: 'Bob Smith');
    final connectionController = TextEditingController(text: 'Display Output #1 (Fiber)');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Platform Billboard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Billboard Name',
                hint: 'Name',
                controller: nameController,
                prefixIcon: const Icon(Icons.display_settings_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Location',
                hint: 'Address',
                controller: locationController,
                prefixIcon: const Icon(Icons.location_on_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Price per Slot (FCFA)',
                hint: 'Price',
                controller: priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.payments_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Owner Name',
                hint: 'Owner',
                controller: ownerController,
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Connection Info',
                hint: 'Display output info',
                controller: connectionController,
                prefixIcon: const Icon(Icons.cable_rounded),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || locationController.text.trim().isEmpty) return;

              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              await adminProvider.addBillboard(
                name: nameController.text.trim(),
                location: locationController.text.trim(),
                latitude: 4.0511,
                longitude: 9.7085,
                pricePerSlot: double.tryParse(priceController.text.trim()) ?? 20000.0,
                ownerName: ownerController.text.trim(),
                connectionInfo: connectionController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Billboard registered successfully!'), backgroundColor: AppTheme.successGreen),
                );
              }
            },
            child: const Text('Add Billboard'),
          ),
        ],
      ),
    );
  }

  void _showEditBillboardModal(BuildContext context, Billboard billboard) {
    final nameController = TextEditingController(text: billboard.name);
    final locationController = TextEditingController(text: billboard.location);
    final priceController = TextEditingController(text: billboard.pricePerSlot.toInt().toString());
    bool isAvailable = billboard.isAvailable;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Edit Billboard (${billboard.id})'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Billboard Name',
                    hint: 'Name',
                    controller: nameController,
                    prefixIcon: const Icon(Icons.display_settings_rounded),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Location',
                    hint: 'Address',
                    controller: locationController,
                    prefixIcon: const Icon(Icons.location_on_rounded),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Price per Slot (FCFA)',
                    hint: 'Price',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.payments_rounded),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Available for Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    value: isAvailable,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setModalState(() {
                        isAvailable = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = billboard.copyWith(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    pricePerSlot: double.tryParse(priceController.text.trim()) ?? billboard.pricePerSlot,
                    isAvailable: isAvailable,
                  );

                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  await adminProvider.updateBillboard(updated);

                  if (context.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Billboard updated!'), backgroundColor: AppTheme.successGreen),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteBillboard(BuildContext context, Billboard billboard) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Billboard'),
        content: Text('Are you sure you want to delete "${billboard.name}" (${billboard.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              await adminProvider.deleteBillboard(billboard.id);
              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Billboard deleted.'), backgroundColor: AppTheme.errorRed),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final billboards = adminProvider.billboards;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Billboard Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Billboard',
            onPressed: () => _showAddBillboardModal(context),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Billboard Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                billboard.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: billboard.isAvailable
                                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                billboard.isAvailable ? 'AVAILABLE' : 'BOOKED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: billboard.isAvailable ? AppTheme.successGreen : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${billboard.id} • Owner: ${billboard.ownerName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const Divider(height: 20),

                        // Specs info
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                billboard.location,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ),
                            Text(
                              '${currencyFormatter.format(billboard.pricePerSlot)} / slot',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              billboard.isPowerOn ? Icons.power_rounded : Icons.power_off_rounded,
                              size: 16,
                              color: billboard.isPowerOn ? AppTheme.successGreen : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Billboard Status: ${billboard.isPowerOn ? "POWERED ON" : "POWERED OFF"} (${billboard.connectionInfo})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: billboard.isPowerOn ? AppTheme.successGreen : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Actions Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                              tooltip: 'Edit Billboard',
                              onPressed: () => _showEditBillboardModal(context, billboard),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed),
                              tooltip: 'Delete Billboard',
                              onPressed: () => _confirmDeleteBillboard(context, billboard),
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
