import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/affiliate_link_model.dart';

abstract class AffiliateRemoteDataSource {
  Future<List<AffiliateLinkModel>> getAffiliateLinks();
  Future<void> createAffiliateLink(AffiliateLinkModel link);
  Future<void> deleteAffiliateLink(String id);
}

class AffiliateRemoteDataSourceImpl implements AffiliateRemoteDataSource {
  final SupabaseClient supabase;

  AffiliateRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<AffiliateLinkModel>> getAffiliateLinks() async {
    // Join กับตาราง campaigns และ profiles เพื่อดึงชื่อมาแสดงผล
    final response = await supabase
        .from('affiliate_links')
        .select('*, campaigns(campaign_name), profiles(full_name)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AffiliateLinkModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> createAffiliateLink(AffiliateLinkModel link) async {
    await supabase.from('affiliate_links').insert(link.toJson());
  }

  @override
  Future<void> deleteAffiliateLink(String id) async {
    await supabase.from('affiliate_links').delete().eq('id', id);
  }
}
