import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthState> get authStateChanges;
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    // String? companyName,
    // String? industry,
    // String? tenantId,
  });
  Future<void> signIn({required String email, required String password});
  Future<bool> signInWithOAuth(OAuthProvider provider);
  Future<void> signOut();
  Future<AppUser?> getCurrentUserProfile();
  Future<void> updateFcmToken(String token);
  Future<void> resetPassword(String email);
  Future<void> resendVerificationEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  @override
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return await supabase.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.flutter://login-callback/', // Schema สำหรับ Deep Link กลับมายังแอป
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-password/',
    );
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: 'io.supabase.flutter://email-callback/',
    );
  }

  @override
  Future<AppUser?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (response == null) return null;

    return AppUser.fromJson(response);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    // String? companyName,
    // String? industry,
    // String? tenantId,
  }) async {
    final metaData = <String, dynamic>{
      'full_name': fullName,
      'role': role,
      // if (companyName != null && companyName.isNotEmpty)
      //   'company_name': companyName,
      // if (industry != null && industry.isNotEmpty) 'industry': industry,
      // if (tenantId != null && tenantId.isNotEmpty) 'tenant_id': tenantId,
    };
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: metaData,
    );
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      log('Failed to update FCM token: ${e.message}');
      rethrow;
    }
  }
}
