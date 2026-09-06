import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/controllers/auth_provider.dart';
import '../../data/datasources/profile_remote_data_source.dart';

final profileDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(Supabase.instance.client);
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref.read(profileDataSourceProvider), ref);
    });

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRemoteDataSource _dataSource;
  final Ref _ref;

  ProfileController(this._dataSource, this._ref) : super(const AsyncData(null));

  Future<void> updateProfile({
    required String fullName,
    File? imageFile,
  }) async {
    state = const AsyncLoading();
    try {
      final currentUser = _ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

      String? avatarUrl = currentUser.avatarUrl;

      if (imageFile != null) {
        avatarUrl = await _dataSource.uploadAvatar(
          userId: currentUser.id,
          imageFile: imageFile,
        );
      }

      await _dataSource.updateProfile(
        userId: currentUser.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      _ref.invalidate(currentUserProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await _dataSource.updatePassword(newPassword);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
