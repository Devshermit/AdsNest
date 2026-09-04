import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthState> get authStateChanges;
  Future<AuthResponse> signInWithEmail(String email, String password);
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  );
  Future<bool> signInWithOAuth(OAuthProvider provider);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<AppUser?> getUserProfile(String userId, String email);
  Future<void> resendVerificationEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      emailRedirectTo: 'io.supabase.flutter://email-callback/',
    );

    if (response.user != null) {
      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,

        // role และ created_at จะถูกตั้งค่า Default ตาม SQL ที่คุณเขียนไว้
      });
    }
    return response;
  }

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
  Future<AppUser?> getUserProfile(String userId, String email) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return AppUser.fromProfileMap(data, email);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: 'io.supabase.flutter://email-callback/',
    );
  }
}
