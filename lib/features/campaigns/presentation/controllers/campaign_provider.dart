import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/entities/campaign.dart';
import '../../domain/datasources/campaign_remote_datasource.dart';

final campaignSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedPlatformFilterProvider = StateProvider<String>((ref) => 'ALL');

final campaignRemoteDataSourceProvider = Provider<CampaignRemoteDataSource>((
  ref,
) {
  return CampaignRemoteDataSourceImpl(Supabase.instance.client);
});

final campaignsListProvider = FutureProvider<List<Campaign>>((ref) async {
  final dataSource = ref.watch(campaignRemoteDataSourceProvider);
  final search = ref.watch(campaignSearchQueryProvider).toLowerCase();
  final platform = ref.watch(selectedPlatformFilterProvider);

  final campaigns = await dataSource.fetchCampaigns();

  return campaigns.where((campaign) {
    final matchesPlatform = platform == 'ALL' || campaign.platform == platform;
    final matchesSearch =
        search.isEmpty || campaign.campaignName.toLowerCase().contains(search);
    return matchesPlatform && matchesSearch;
  }).toList();
});

class CampaignActionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleStatus(Campaign campaign) async {
    final dataSource = ref.read(campaignRemoteDataSourceProvider);
    final nextStatus = campaign.isActive ? 'PAUSED' : 'ACTIVE';
    await dataSource.updateStatus(campaign.id, nextStatus);
    ref.invalidate(campaignsListProvider);
  }

  Future<void> updateBudget(String campaignId, double newBudget) async {
    final dataSource = ref.read(campaignRemoteDataSourceProvider);
    await dataSource.updateBudget(campaignId, newBudget);
    ref.invalidate(campaignsListProvider);
  }

  Future<void> createCampaign({
    required String name,
    required String platform,
    required double dailyBudget,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dataSource = ref.read(campaignRemoteDataSourceProvider);

    final user = Supabase.instance.client.auth.currentUser;
    final tenantId = user?.userMetadata?['tenant_id'] ?? user?.id;

    if (tenantId == null) {
      throw Exception('ไม่พบข้อมูล Tenant ID');
    }

    final newCampaign = Campaign(
      id: '', // Supabase จะ gen_random_uuid() ให้เองใน DB
      tenantId: tenantId,
      campaignName: name,
      platform: platform,
      status: 'ACTIVE',
      dailyBudgetLimit: dailyBudget,
      startDate: startDate,
      endDate: endDate,
    );

    await dataSource.createCampaign(newCampaign);
    ref.invalidate(campaignsListProvider);
  }

  Future<void> updateCampaign(Campaign campaign) async {
    final dataSource = ref.read(campaignRemoteDataSourceProvider);
    await dataSource.updateCampaign(campaign);
    ref.invalidate(campaignsListProvider);
  }

  Future<void> deleteCampaign(String campaignId) async {
    final dataSource = ref.read(campaignRemoteDataSourceProvider);
    await dataSource.deleteCampaign(campaignId);
    ref.invalidate(campaignsListProvider);
  }
}

final campaignActionProvider = NotifierProvider<CampaignActionNotifier, void>(
  CampaignActionNotifier.new,
);
