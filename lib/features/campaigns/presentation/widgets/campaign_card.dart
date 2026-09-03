import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/entities/campaign.dart';
import '../controllers/campaign_provider.dart';
import 'edit_campaign_dialog.dart';

class CampaignCard extends ConsumerWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '฿',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _buildPlatformBadge(campaign.platform),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.campaignName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'งบประมาณรายวัน: ${currencyFormatter.format(campaign.dailyBudgetLimit)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.white54,
              size: 20,
            ),
            tooltip: 'แก้ไขแคมเปญ',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => EditCampaignDialog(campaign: campaign),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            tooltip: 'ลบแคมเปญ',
            onPressed: () => _showDeleteConfirmDialog(context, ref, campaign),
          ),
          const SizedBox(width: 4),
          Switch(
            value: campaign.isActive,
            activeThumbColor: const Color(0xFF10B981),
            onChanged: (_) {
              ref.read(campaignActionProvider.notifier).toggleStatus(campaign);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String platform) {
    Color color;
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        color = const Color(0xFFE53935);
        break;
      case 'FACEBOOK':
        color = const Color(0xFF1E88E5);
        break;
      case 'SHOPEE':
        color = const Color(0xFFFF8F00);
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        platform,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'ยืนยันการลบแคมเปญ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'คุณต้องการลบแคมเปญ "${campaign.campaignName}" ใช่หรือไม่? ข้อมูลนี้จะไม่สามารถกู้คืนได้',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await ref
                  .read(campaignActionProvider.notifier)
                  .deleteCampaign(campaign.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'ลบแคมเปญ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
