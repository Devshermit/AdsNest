import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/entities/campaign.dart';
import '../controllers/campaign_provider.dart';

class EditCampaignDialog extends ConsumerStatefulWidget {
  final Campaign campaign;

  const EditCampaignDialog({super.key, required this.campaign});

  @override
  ConsumerState<EditCampaignDialog> createState() => _EditCampaignDialogState();
}

class _EditCampaignDialogState extends ConsumerState<EditCampaignDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late String _selectedPlatform;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campaign.campaignName);
    _budgetController = TextEditingController(
      text: widget.campaign.dailyBudgetLimit.toStringAsFixed(0),
    );
    _selectedPlatform = widget.campaign.platform;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updatedCampaign = widget.campaign.copyWith(
        campaignName: _nameController.text.trim(),
        platform: _selectedPlatform,
        dailyBudgetLimit: double.parse(_budgetController.text.trim()),
      );

      await ref
          .read(campaignActionProvider.notifier)
          .updateCampaign(updatedCampaign);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text(
        'แก้ไขแคมเปญ',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ชื่อแคมเปญ',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'กรุณาระบุชื่อแคมเปญ'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlatform,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'แพลตฟอร์ม',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'TIKTOK', child: Text('TikTok Ads')),
                  DropdownMenuItem(
                    value: 'FACEBOOK',
                    child: Text('Facebook Ads'),
                  ),
                  DropdownMenuItem(value: 'SHOPEE', child: Text('Shopee Ads')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPlatform = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'งบประมาณรายวัน (บาท)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณาระบุงบประมาณ';
                  }
                  if (double.tryParse(val) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'บันทึกการแก้ไข',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
