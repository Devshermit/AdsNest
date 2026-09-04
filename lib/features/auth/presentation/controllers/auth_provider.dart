import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/app_user.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return dataSource.authStateChanges;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  final session = authState?.session;
  final user = session?.user;

  if (user != null) {
    final dataSource = ref.read(authRemoteDataSourceProvider);
    return await dataSource.getUserProfile(user.id, user.email ?? '');
  }
  return null;
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.signInWithEmail(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.signInWithOAuth(provider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.signUpWithEmail(email, password, fullName);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.resetPassword(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.resendVerificationEmail(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
