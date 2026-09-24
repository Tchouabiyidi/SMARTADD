import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/billboard.dart';
import '../../../providers/advertiser_provider.dart';
import '../../../theme/app_theme.dart';
import '../billboard_detail_screen.dart';

class BillboardListTab extends StatefulWidget {
  const BillboardListTab({super.key});

  @override
  State<BillboardListTab> createState() => _BillboardListTabState();
}

class _BillboardListTabState extends State<BillboardListTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    final provider = Provider.of<AdvertiserProvider>(context, listen: false);
    double? maxP = provider.filter.maxPrice;
    bool onlyAvail = provider.filter.onlyAvailable ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Billboards',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Only Available Toggle
                  SwitchListTile(
                    title: const Text('Only Available Billboards'),
                    value: onlyAvail,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setModalState(() {
                        onlyAvail = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Range slider
                  const Text('Maximum Price / Slot', style: TextStyle(fontWeight: FontWeight.w600)),
                  Slider(
                    value: maxP ?? 50000.0,
                    min: 10000.0,
                    max: 60000.0,
                    divisions: 10,
                    label: '${(maxP ?? 50000.0).toInt()} FCFA',
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setModalState(() {
                        maxP = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.updateFilter(const BillboardFilter());
                            Navigator.pop(modalContext);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.updateFilter(
                              provider.filter.copyWith(
                                maxPrice: maxP,
                                onlyAvailable: onlyAvail,
                              ),
                            );
                            Navigator.pop(modalContext);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final advertiserProvider = Provider.of<AdvertiserProvider>(context);
    final billboards = advertiserProvider.filteredBillboards;
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Browse Billboards'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => advertiserProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search billboard or location...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                advertiserProvider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: () => _showFilterModal(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),

          // Billboards List
          Expanded(
            child: billboards.isEmpty
                ? const Center(
                    child: Text(
                      'No billboards match your search criteria.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: billboards.length,
                    itemBuilder: (context, index) {
                      final billboard = billboards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BillboardDetailScreen(billboard: billboard),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
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
                                        billboard.name,
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
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      billboard.location,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.aspect_ratio_rounded, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      billboard.dimensions,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                const Divider(),
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Owner: ${billboard.ownerName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
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
                              ],
                            ),
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
