import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  });
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });
  Future<void> updatePassword(String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;
  ProfileRemoteDataSourceImpl(this.supabase);

  @override
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async {
    await supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'avatar_url': ?avatarUrl,
          //if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName =
        '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'avatars/$fileName';

    await supabase.storage.from('avatars').upload(filePath, imageFile);

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
    return publicUrl;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
