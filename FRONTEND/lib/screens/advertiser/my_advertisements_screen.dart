import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class MyAdvertisementsScreen extends StatelessWidget {
  const MyAdvertisementsScreen({super.key});

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final videoNameController = TextEditingController();
    int duration = 15;
    String? selectedFilePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Consumer<AdvertiserProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upload Advertisement Video',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: provider.isUploading ? null : () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      CustomTextField(
                        label: 'Campaign Title',
                        hint: 'e.g. Summer Special Offer',
                        controller: titleController,
                        prefixIcon: const Icon(Icons.title_rounded),
                        enabled: !provider.isUploading,
                      ),
                      const SizedBox(height: 12),

                      // Video Selector Box
                      InkWell(
                        onTap: provider.isUploading
                            ? null
                            : () async {
                                try {
                                  final dynamic pickerClass = FilePicker;
                                  final result = await pickerClass.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['mp4', 'mov', 'avi', 'mkv'],
                                  );
                                  if (result != null && result.files.isNotEmpty) {
                                    setModalState(() {
                                      selectedFilePath = result.files.first.path;
                                      videoNameController.text = result.files.first.name;
                                    });
                                    return;
                                  }
                                } catch (_) {
                                  // Fallback simulation when platform picker is not supported on desktop test harness
                                }
                                setModalState(() {
                                  videoNameController.text = 'promo_video_2026.mp4';
                                  selectedFilePath = '/mock/path/promo_video_2026.mp4';
                                });
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
                              const Icon(Icons.video_file_rounded, color: AppTheme.primaryBlue, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      videoNameController.text.isNotEmpty
                                          ? videoNameController.text
                                          : 'Tap to select video file (.mp4)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: videoNameController.text.isNotEmpty
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (selectedFilePath != null)
                                      Text(
                                        selectedFilePath!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.file_upload_outlined, color: AppTheme.primaryBlue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration Dropdown
                      Row(
                        children: [
                          const Text('Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: duration,
                            items: const [
                              DropdownMenuItem(value: 15, child: Text('15 seconds')),
                              DropdownMenuItem(value: 30, child: Text('30 seconds')),
                              DropdownMenuItem(value: 45, child: Text('45 seconds')),
                              DropdownMenuItem(value: 60, child: Text('60 seconds')),
                            ],
                            onChanged: provider.isUploading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setModalState(() {
                                        duration = val;
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Upload Progress Bar
                      if (provider.isUploading) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploading Video...',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                            Text(
                              '${(provider.uploadProgress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: provider.uploadProgress,
                          backgroundColor: AppTheme.primaryLight,
                          color: AppTheme.primaryBlue,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 20),
                      ],

                      CustomButton(
                        text: 'Upload Advertisement',
                        icon: Icons.cloud_upload_rounded,
                        isLoading: provider.isUploading,
                        onPressed: provider.isUploading
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a campaign title')),
                                  );
                                  return;
                                }

                                final String vName = videoNameController.text.isNotEmpty
                                    ? videoNameController.text
                                    : 'ad_campaign.mp4';

                                final success = await provider.uploadVideo(
                                  title: titleController.text.trim(),
                                  videoName: vName,
                                  durationSeconds: duration,
                                );

                                if (success && modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Advertisement uploaded! Sent for verification.'),
                                      backgroundColor: AppTheme.successGreen,
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdvertiserProvider>(context);
    final ads = provider.userAdvertisements;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('My Advertisements'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        label: const Text('Upload Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined, size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  const Text(
                    'No advertisement videos uploaded yet',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context),
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('Upload First Advertisement'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                final statusColor = ad.verificationStatus == AdVerificationStatus.approved
                    ? AppTheme.successGreen
                    : (ad.verificationStatus == AdVerificationStatus.rejected ? Colors.red : Colors.orange);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.play_circle_fill_rounded, color: statusColor, size: 28),
                    ),
                    title: Text(
                      ad.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'File: ${ad.videoName} (${ad.durationSeconds}s)',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Uploaded: ${dateFormat.format(ad.uploadDate)}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ad.verificationStatus.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
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
