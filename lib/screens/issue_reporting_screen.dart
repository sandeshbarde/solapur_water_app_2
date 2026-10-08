import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/complaint_service.dart';
import '../services/location_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/confirm_action_dialog.dart';

/// Screen: Issue Reporting Flow
/// Real camera & gallery attachment preview, GPS capture, category selection, and REST backend dispatch.
class IssueReportingScreen extends StatefulWidget {
  const IssueReportingScreen({super.key});

  @override
  State<IssueReportingScreen> createState() => _IssueReportingScreenState();
}

class _IssueReportingScreenState extends State<IssueReportingScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedFiles = [];
  String? _selectedCategory;
  String _selectedWard = 'Ward 1 (Ashok Chowk)';
  bool _isLocating = false;
  bool _isSubmitting = false;
  String? _categoryError;
  String? _descriptionError;
  double _currentLat = 17.6599;
  double _currentLng = 75.9064;

  final List<String> _solapurWards = [
    'Ward 1 (Ashok Chowk)',
    'Ward 2 (Saat Rasta)',
    'Ward 3 (Jule Solapur)',
    'Ward 4 (Bhavani Peth)',
    'Ward 5 (MIDC Area)',
    'Ward 6 (Budhwar Peth)',
    'Ward 7 (Railway Lines)',
    'Ward 8 (Hotgi Road)',
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 photos or files can be attached.')),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _selectedFiles.add(photo);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera/Storage access denied: $e')),
        );
      }
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final coords = await LocationService.getCurrentLocation();
      _currentLat = coords['latitude'] ?? 17.6599;
      _currentLng = coords['longitude'] ?? 75.9064;

      final address = await LocationService.getAddressFromCoordinates(_currentLat, _currentLng);
      if (mounted) {
        setState(() {
          _addressController.text = address;
          _isLocating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressController.text = 'Solapur Central Area (17.6599, 75.9064)';
          _isLocating = false;
        });
      }
    }
  }

  bool _validateAll() {
    if (_selectedCategory == null) {
      setState(() => _categoryError = 'Please choose the water issue category');
      return false;
    }
    setState(() => _categoryError = null);

    if (_addressController.text.trim().isEmpty) {
      _addressController.text = 'Solapur Central Area (Auto GPS)';
    }

    if (_descriptionController.text.trim().length < 5) {
      setState(() => _descriptionError = 'Please provide at least 5 characters explaining the issue location/severity');
      return false;
    }
    setState(() => _descriptionError = null);

    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateAll()) return;

    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Submit Water Complaint',
      actionDescription: 'Your report will be sent directly to the Solapur Municipal Corporation rapid-response engineering team.',
      consequences: [
        'Verified complaints award +25 Civic Points and priority repair dispatch.',
        'Assigned ticket ID will be created and tracked live under My Complaints.',
      ],
      confirmLabel: 'Confirm & Send',
      cancelLabel: 'Review',
    );

    if (confirmed == true && mounted) {
      setState(() => _isSubmitting = true);
      final complaintService = Provider.of<ComplaintService>(context, listen: false);

      final filesToSend = _selectedFiles.map((x) => File(x.path)).toList();

      final success = await complaintService.submitComplaint(
        category: _selectedCategory ?? 'Pipeline Leak',
        description: _descriptionController.text.trim(),
        ward: _selectedWard,
        address: _addressController.text.trim(),
        latitude: _currentLat,
        longitude: _currentLng,
        files: filesToSend,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusOk(context),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Complaint submitted successfully! SMC ticket dispatched.'),
                ),
              ],
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCritical(context),
            content: const Text('Failed submitting complaint. Please check your network and try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.accent(context);

    final categories = [
      {'name': 'Pipe Leakage', 'icon': Icons.water_drop_outlined, 'desc': 'Visible burst or leaking valve'},
      {'name': 'Low Pressure', 'icon': Icons.speed, 'desc': 'Low trickle or zero flow'},
      {'name': 'Contamination', 'icon': Icons.science_outlined, 'desc': 'Discoloration or foul odor'},
      {'name': 'Water Theft', 'icon': Icons.gavel_outlined, 'desc': 'Unauthorized motor suction or illegal connection'},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.reportIssue),
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.statusOk(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.statusOk(context).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.statusOk(context)),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'Verified citizen reports earn 25 Civic Points upon dispatch.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 1. Issue Category
                Text('1. Select Issue Type', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (_categoryError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_categoryError!, style: TextStyle(color: AppColors.statusCritical(context), fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: AppSpacing.s12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['name'] as String;
                          _categoryError = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withValues(alpha: 0.1) : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isSelected ? accent : AppColors.border(context),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'] as IconData, size: 28, color: isSelected ? accent : AppColors.textSecondary(context)),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'] as String,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? accent : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.s28),

                // 2. Ward & Location
                Text('2. Ward & Location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedWard,
                        decoration: const InputDecoration(labelText: 'Municipal Ward'),
                        items: _solapurWards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedWard = val);
                        },
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Icon(Icons.my_location, color: AppColors.statusOk(context), size: 20),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              'Auto GPS (${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)})',
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (_isLocating)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            TextButton.icon(
                              onPressed: _detectLocation,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Refresh'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Street address or landmark',
                          hintText: 'e.g. Near Siddheshwar Temple, Navi Peth',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // 3. Photo & Evidence
                Text('3. Photos & Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      if (_selectedFiles.isNotEmpty) ...[
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedFiles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final f = _selectedFiles[idx];
                              return Stack(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.border(context)),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: !kIsWeb && File(f.path).existsSync()
                                        ? Image.file(File(f.path), fit: BoxFit.cover)
                                        : const Center(child: Icon(Icons.insert_drive_file, color: AppColors.primary)),
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedFiles.removeAt(idx)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: Text(l10n.takePhoto),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 18),
                              label: Text(l10n.chooseGallery),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          hintText: 'Explain the issue (e.g. Clean drinking water pipe burst on main road...)',
                          errorText: _descriptionError,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // Submit Actions
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.submitComplaint.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse("https://wa.me/919322242762?text=${Uri.encodeComponent('Hi JalNirnay Solapur, I want to report an emergency water leak.')}");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: Icon(Icons.chat_outlined, size: 18, color: AppColors.statusOk(context)),
                    label: Text(
                      'Report directly via WhatsApp Helpline',
                      style: TextStyle(color: AppColors.statusOk(context), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
