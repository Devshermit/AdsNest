import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/entities/campaign.dart';

abstract class CampaignRemoteDataSource {
  Future<List<Campaign>> fetchCampaigns();
  Future<void> updateStatus(String id, String status);
  Future<void> updateBudget(String id, double budget);
  Future<void> createCampaign(Campaign campaign);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
}

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final SupabaseClient supabase;

  CampaignRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<Campaign>> fetchCampaigns() async {
    final response = await supabase
        .from('campaigns')
        .select()
        .order('created_at', ascending: false);

    final rawList = List<Map<String, dynamic>>.from(response);
    return rawList.map((item) => Campaign.fromMap(item)).toList();
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    await supabase.from('campaigns').update({'status': status}).eq('id', id);
  }

  @override
  Future<void> updateBudget(String id, double budget) async {
    await supabase
        .from('campaigns')
        .update({'daily_budget_limit': budget})
        .eq('id', id);
  }

  @override
  Future<void> createCampaign(Campaign campaign) async {
    await supabase.from('campaigns').insert(campaign.toMap());
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    await supabase
        .from('campaigns')
        .update({
          'campaign_name': campaign.campaignName,
          'platform': campaign.platform,
          'daily_budget_limit': campaign.dailyBudgetLimit,
        })
        .eq('id', campaign.id);
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await supabase.from('campaigns').delete().eq('id', id);
  }
}
