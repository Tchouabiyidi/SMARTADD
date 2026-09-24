import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../theme/app_theme.dart';
import '../edit_billboard_screen.dart';
import '../owner_billboard_detail_screen.dart';
import '../widgets/power_control_widget.dart';
import '../widgets/qr_code_dialog.dart';
import 'add_billboard_screen.dart';

class MyBillboardsTab extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const MyBillboardsTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context);
    final billboards = ownerProvider.ownerBillboards;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('My Billboards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Billboard',
            onPressed: () {
              if (onNavigateTab != null) {
                onNavigateTab!(2);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBillboardScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: billboards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.view_carousel_outlined, size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  const Text(
                    'No billboards registered under your account yet',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (onNavigateTab != null) {
                        onNavigateTab!(2);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Register First Billboard'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: billboards.length,
              itemBuilder: (context, index) {
                final billboard = billboards[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OwnerBillboardDetailScreen(billboard: billboard),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name & ID + Status Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      billboard.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ID: ${billboard.id}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Availability Badge
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
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location & Price info
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
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Integrated Power Control Widget
                          PowerControlWidget(billboard: billboard),
                          const SizedBox(height: 12),

                          const Divider(),

                          // Footer Quick Actions (QR Code, Edit, Details)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () => QRCodeDialog.show(context, billboard),
                                icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                                label: const Text('View QR Code'),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                                    tooltip: 'Edit Billboard',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditBillboardScreen(billboard: billboard),
                                        ),
                                      );
                                    },
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
