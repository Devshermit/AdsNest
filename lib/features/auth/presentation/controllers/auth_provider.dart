import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_handler.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/app_user.dart';

// // Data Source Provider
// final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
//   return AuthRemoteDataSourceImpl(Supabase.instance.client);
// });

// //Stream ฟังการเปลี่ยนแปลงของ Auth State จาก Supabase
// final authStateStreamProvider = StreamProvider<AuthState>((ref) {
//   return Supabase.instance.client.auth.onAuthStateChange;
// });

// // Fetch ข้อมูล AppUser ปัจจุบัน
// final currentUserProvider = FutureProvider<AppUser?>((ref) async {
//   ref.watch(authStateStreamProvider);
//   final dataSource = ref.read(authRemoteDataSourceProvider);
//   return await dataSource.getCurrentUserProfile();
// });

// //Controller สำหรับจัดการ Actions (Login, Register, Logout)
// final authControllerProvider =
//     StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
//       return AuthController(ref.read(authRemoteDataSourceProvider), ref);
//     });

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(Supabase.instance.client);
});

// Stream ฟังการเปลี่ยนแปลงของ Auth State จาก Supabase
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Fetch ข้อมูล AppUser ปัจจุบัน
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  // 1. ดึง AuthState ล่าสุดจาก Stream
  final authState = ref.watch(authStateStreamProvider).value;

  // 2. เช็ก Session (ใช้ค่าจาก authState หรือดึงตรงจาก Supabase client)
  final session =
      authState?.session ?? Supabase.instance.client.auth.currentSession;

  // ถ้าไม่มี Session (ไม่ได้ล็อกอิน/ออกจากระบบ) ให้คืนค่า null ทันทีโดยไม่ต้อง Query DB
  if (session == null) {
    return null;
  }

  // 3. ดึงข้อมูล Profile เมื่อมี Session
  final dataSource = ref.read(authRemoteDataSourceProvider);
  return await dataSource.getCurrentUserProfile();
});

// Controller สำหรับจัดการ Actions (Login, Register, Logout)
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.read(authRemoteDataSourceProvider), ref);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRemoteDataSource _dataSource;
  final Ref _ref;

  AuthController(this._dataSource, this._ref) : super(const AsyncData(null));

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _dataSource.signIn(email: email, password: password);

      // ซิงก์ FCM Token หลัง Login สำเร็จ
      await NotificationService.syncFcmTokenPostLogin(_dataSource);

      _ref.invalidate(currentUserProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      final errorMessage = AuthErrorHandler.parse(e);
      state = AsyncError(errorMessage, StackTrace.current);
      return false;
    }
  }

  // Future<void> signInWithOAuth(OAuthProvider provider) async {
  //   state = const AsyncLoading();
  //   try {
  //     final dataSource = ref.read(authRemoteDataSourceProvider);
  //     await dataSource.signInWithOAuth(provider);
  //     state = const AsyncData(null);
  //   } catch (e, st) {
  //     state = AsyncError(e, st);
  //   }
  // }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? companyName,
    String? industry,
    String? tenantId,
  }) async {
    state = const AsyncLoading();
    try {
      await _dataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        // companyName: companyName,
        // industry: industry,
        // tenantId: tenantId,
      );

      // ซิงก์ FCM Token หลัง Register สำเร็จ
      await NotificationService.syncFcmTokenPostLogin(_dataSource);

      _ref.invalidate(currentUserProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      final errorMessage = AuthErrorHandler.parse(e);
      state = AsyncError(errorMessage, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _dataSource.signOut();
      _ref.invalidate(currentUserProvider);
      state = const AsyncData(null);
    } catch (e) {
      final errorMessage = AuthErrorHandler.parse(e);
      state = AsyncError(errorMessage, StackTrace.current);
    }
  }

  // Future<void> resetPassword(String email) async {
  //   state = const AsyncLoading();
  //   try {
  //     final dataSource = ref.read(authRemoteDataSourceProvider);
  //     await dataSource.resetPassword(email);
  //     state = const AsyncData(null);
  //   } catch (e, st) {
  //     state = AsyncError(e, st);
  //   }
  // }

  // Future<void> resendVerificationEmail(String email) async {
  //   state = const AsyncLoading();
  //   try {
  //     final dataSource = ref.read(authRemoteDataSourceProvider);
  //     await dataSource.resendVerificationEmail(email);
  //     state = const AsyncData(null);
  //   } catch (e, st) {
  //     state = AsyncError(e, st);
  //   }
  // }
}
