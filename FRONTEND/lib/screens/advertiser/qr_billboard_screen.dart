import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billboard.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'billboard_detail_screen.dart';

class QRBillboardScreen extends StatefulWidget {
  final String? initialBillboardId;

  const QRBillboardScreen({
    super.key,
    this.initialBillboardId,
  });

  @override
  State<QRBillboardScreen> createState() => _QRBillboardScreenState();
}

class _QRBillboardScreenState extends State<QRBillboardScreen> {
  final TextEditingController _idController = TextEditingController();
  bool _isResolving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialBillboardId != null && widget.initialBillboardId!.isNotEmpty) {
      _idController.text = widget.initialBillboardId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveAndNavigate(widget.initialBillboardId!);
      });
    } else {
      _idController.text = 'bb_douala_01';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _resolveAndNavigate(String billboardId) async {
    if (billboardId.trim().isEmpty) return;

    setState(() {
      _isResolving = true;
      _error = null;
    });

    final provider = Provider.of<AdvertiserProvider>(context, listen: false);
    final Billboard? resolved = await provider.resolveBillboardFromQR(billboardId.trim());

    setState(() {
      _isResolving = false;
    });

    if (mounted) {
      if (resolved != null) {
        // Automatically identified billboard: navigate directly without asking user to re-select
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BillboardDetailScreen(billboard: resolved),
          ),
        );
      } else {
        setState(() {
          _error = 'No Billboard found with ID "$billboardId"';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Scan Billboard QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scanner Target Frame Simulation
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryLight, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 100,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Point camera at Billboard QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Billboard will be identified automatically',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Manual Code Input Box
              const Text(
                'Or enter Billboard ID manually:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              CustomTextField(
                label: 'Billboard ID',
                hint: 'e.g. bb_douala_01',
                controller: _idController,
                prefixIcon: const Icon(Icons.qr_code_rounded),
                errorText: _error,
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Identify & Book Billboard',
                icon: Icons.search_rounded,
                isLoading: _isResolving,
                onPressed: () => _resolveAndNavigate(_idController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
