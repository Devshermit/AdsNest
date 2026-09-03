import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/campaign_provider.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_filter_bar.dart';
import '../widgets/create_campaign_dialog.dart';

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCampaigns = ref.watch(campaignsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'จัดการแคมเปญ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('สร้างแคมเปญ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const CreateCampaignDialog(),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CampaignFilterBar(),
            const SizedBox(height: 24),
            Expanded(
              child: asyncCampaigns.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                data: (campaigns) {
                  if (campaigns.isEmpty) {
                    return const Center(
                      child: Text(
                        'ไม่พบรายการแคมเปญ',
                        style: TextStyle(color: Colors.white38),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) =>
                        CampaignCard(campaign: campaigns[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
