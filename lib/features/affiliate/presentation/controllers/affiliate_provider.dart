import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/affiliate_remote_data_source.dart';
import '../../data/models/affiliate_link_model.dart';

final affiliateDataSourceProvider = Provider<AffiliateRemoteDataSource>((ref) {
  return AffiliateRemoteDataSourceImpl(Supabase.instance.client);
});

// Provider ดึงรายการ Affiliate Links ทั้งหมด
final affiliateLinksProvider = FutureProvider<List<AffiliateLinkModel>>((
  ref,
) async {
  final dataSource = ref.watch(affiliateDataSourceProvider);
  return await dataSource.getAffiliateLinks();
});

// Controller สำหรับการสร้างและลบลิงก์
final affiliateControllerProvider =
    StateNotifierProvider<AffiliateController, AsyncValue<void>>((ref) {
      return AffiliateController(ref.read(affiliateDataSourceProvider), ref);
    });

// Provider สำหรับดึงรายการ Campaigns ทั้งหมดมาใส่ Dropdown
final campaignListProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('campaigns')
      .select('id, title')
      .order('created_at', ascending: false);

  return (response as List)
      .map(
        (item) => {
          'id': item['id'].toString(),
          'title': item['title'].toString(),
        },
      )
      .toList();
});

// Provider สำหรับดึงรายการผู้ใช้/นักรีวิวมาใส่ Dropdown
final affiliateUsersProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('profiles')
      .select('id, full_name, email')
      .order('full_name', ascending: true);

  return (response as List)
      .map(
        (item) => {
          'id': item['id'].toString(),
          'name':
              (item['full_name'] != null &&
                  (item['full_name'] as String).isNotEmpty)
              ? item['full_name'].toString()
              : item['email'].toString(),
        },
      )
      .toList();
});

class AffiliateController extends StateNotifier<AsyncValue<void>> {
  final AffiliateRemoteDataSource _dataSource;
  final Ref _ref;

  AffiliateController(this._dataSource, this._ref)
    : super(const AsyncData(null));

  Future<void> createLink(AffiliateLinkModel link) async {
    state = const AsyncLoading();
    try {
      await _dataSource.createAffiliateLink(link);
      _ref.invalidate(affiliateLinksProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteLink(String id) async {
    state = const AsyncLoading();
    try {
      await _dataSource.deleteAffiliateLink(id);
      _ref.invalidate(affiliateLinksProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
