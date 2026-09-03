import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/campaign_provider.dart';

class CampaignFilterBar extends ConsumerWidget {
  const CampaignFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlatform = ref.watch(selectedPlatformFilterProvider);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'ค้นหาแคมเปญ...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white38,
              ),
              filled: true,
              fillColor: const Color(0xFF162032),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) =>
                ref.read(campaignSearchQueryProvider.notifier).state = val,
          ),
        ),
        _buildFilterChip(ref, 'ทั้งหมด', 'ALL', selectedPlatform),
        _buildFilterChip(ref, 'TikTok', 'TIKTOK', selectedPlatform),
        _buildFilterChip(ref, 'Facebook', 'FACEBOOK', selectedPlatform),
        _buildFilterChip(ref, 'Shopee', 'SHOPEE', selectedPlatform),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String label,
    String value,
    String currentSelected,
  ) {
    final isSelected = currentSelected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      backgroundColor: const Color(0xFF162032),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white54,
        fontSize: 13,
      ),
      onSelected: (_) =>
          ref.read(selectedPlatformFilterProvider.notifier).state = value,
    );
  }
}
