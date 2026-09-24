import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/billboard.dart';
import '../../../providers/owner_provider.dart';
import '../../../theme/app_theme.dart';

class PowerControlWidget extends StatelessWidget {
  final Billboard billboard;

  const PowerControlWidget({
    super.key,
    required this.billboard,
  });

  @override
  Widget build(BuildContext context) {
    final ownerProvider = Provider.of<OwnerProvider>(context, listen: false);
    final isPowerOn = billboard.isPowerOn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.power_settings_new_rounded, color: AppTheme.primaryBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Billboard Power Control',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              // Billboard Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPowerOn
                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPowerOn ? AppTheme.successGreen : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Billboard Status: ${isPowerOn ? "POWERED ON" : "POWERED OFF"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPowerOn ? AppTheme.successGreen : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Power ON / Power OFF Toggle Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isPowerOn
                      ? null
                      : () {
                          ownerProvider.togglePower(billboard.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Power ON sent to ${billboard.name}'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.power_rounded, size: 18),
                  label: const Text('Power ON', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !isPowerOn
                      ? null
                      : () {
                          ownerProvider.togglePower(billboard.id, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Power OFF sent to ${billboard.name}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    disabledForegroundColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.power_off_rounded, size: 18),
                  label: const Text('Power OFF', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
