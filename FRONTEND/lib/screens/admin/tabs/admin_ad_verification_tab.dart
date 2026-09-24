import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/advertisement.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';

class AdminAdVerificationTab extends StatelessWidget {
  const AdminAdVerificationTab({super.key});

  void _showVideoPreviewModal(BuildContext context, Advertisement ad) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Video Preview: ${ad.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    ad.videoName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Duration: ${ad.durationSeconds}s',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Campaign ID: ${ad.id} • Uploaded: ${DateFormat("dd MMM yyyy, HH:mm").format(ad.createdAt)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close Preview'),
          ),
        ],
      ),
    );
  }

  void _showRejectReasonDialog(BuildContext context, Advertisement ad) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Advertisement (${ad.id})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this advertisement campaign:'),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Rejection Reason',
              hint: 'e.g. Non-compliant content, poor video resolution...',
              controller: reasonController,
              prefixIcon: const Icon(Icons.warning_amber_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;

              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              await adminProvider.rejectAd(ad.id, reason);

              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Advertisement campaign rejected.'), backgroundColor: AppTheme.errorRed),
                );
              }
            },
            child: const Text('Reject Campaign'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final pendingAds = adminProvider.pendingAds;
    final dateFormat = DateFormat('EEE, dd MMM yyyy • HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Advertisement Verification Portal'),
      ),
      body: pendingAds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64, color: AppTheme.successGreen),
                  SizedBox(height: 16),
                  Text(
                    'No pending advertisements requiring verification 🎉',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingAds.length,
              itemBuilder: (context, index) {
                final ad = pendingAds[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campaign Title & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ad.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PENDING REVIEW',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Campaign ID: ${ad.id} • Uploaded ${dateFormat.format(ad.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const Divider(height: 20),

                        // Video & Advertiser Details
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _showVideoPreviewModal(context, ad),
                              child: Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'File: ${ad.videoName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Duration: ${ad.durationSeconds} seconds',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Advertiser ID: ${ad.advertiserId}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Action Buttons: Preview, Reject, Approve
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showVideoPreviewModal(context, ad),
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              label: const Text('Preview'),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              onPressed: () => _showRejectReasonDialog(context, ad),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Reject'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              onPressed: () async {
                                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                                await adminProvider.approveAd(ad.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Advertisement campaign APPROVED!'), backgroundColor: AppTheme.successGreen),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Approve'),
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
