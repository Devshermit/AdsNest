import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/campaign_provider.dart';

class CreateCampaignDialog extends ConsumerStatefulWidget {
  const CreateCampaignDialog({super.key});

  @override
  ConsumerState<CreateCampaignDialog> createState() =>
      _CreateCampaignDialogState();
}

class _CreateCampaignDialogState extends ConsumerState<CreateCampaignDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedPlatform = 'TIKTOK';
  bool _isSubmitting = false;

  DateTime? _startDate; // 👈 เก็บวันเริ่ม
  DateTime? _endDate; // 👈 เก็บวันจบ

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเปิดปฏิทินเลือกช่วงเวลา
  Future<void> _pickDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(campaignActionProvider.notifier)
          .createCampaign(
            name: _nameController.text.trim(),
            platform: _selectedPlatform,
            dailyBudget: double.parse(_budgetController.text.trim()),
            startDate: _startDate,
            endDate: _endDate,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateText = (_startDate != null && _endDate != null)
        ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
        : 'กำหนดระยะเวลา (ไม่บังคับ)';

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text(
        'สร้างแคมเปญใหม่',
        style: TextStyle(color: Colors.white),
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
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
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
                onChanged: (val) => setState(() => _selectedPlatform = val!),
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
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'กรุณาระบุงบประมาณ'
                    : null,
              ),
              const SizedBox(height: 16),
              // 👈 UI สำหรับเลือกวันที่
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: _startDate != null
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: _isSubmitting ? null : _submit,
          child: const Text(
            'สร้างแคมเปญ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
