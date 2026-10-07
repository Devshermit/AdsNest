import 'package:ads_nest/features/auth/domain/entities/app_user.dart';
import 'package:ads_nest/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ads_nest/features/auth/presentation/screens/admin_dashboard_screen.dart';
import 'package:ads_nest/features/auth/presentation/screens/create_tenant_screen.dart';
import 'package:ads_nest/features/auth/presentation/screens/login_screen.dart';
import 'package:ads_nest/features/auth/presentation/screens/pending_tenant_screen.dart';
import 'package:ads_nest/features/auth/presentation/screens/register_screen.dart';
import 'package:ads_nest/features/campaigns/presentation/screens/campaigns_screen.dart';
import 'package:ads_nest/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/layout/main_layout.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

// Helper Class สำหรับส่งสัญญาณให้ GoRouter ประเมิน redirect ใหม่
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
      // เมื่อข้อมูล user เปลี่ยนสถานะ (เช่น null -> AppUser หรือ Loading -> Data)
      // ให้สะกิด GoRouter ให้รัน redirect ใหม่ทันที
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final currentUserAsync = ref.read(currentUserProvider);
      final supabaseUser = Supabase.instance.client.auth.currentUser;

      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // 1. หากไม่มี Session ใน Supabase Auth จริงๆ ให้ส่งไปหน้า /login
      if (supabaseUser == null) {
        return isAuthPage ? null : '/login';
      }

      // 2. ถ้าล็อกอินอยู่ แต่ Provider กำลังโหลดข้อมูล Profile ให้ตรึงหน้าเดิมไว้ก่อน (ไม่ให้เด้งไป /login)
      if (currentUserAsync.isLoading) {
        return null;
      }

      final user = currentUserAsync.value;

      // 3. ถ้าดึง Profile ไม่พบ
      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      // 2. ล็อกอินสำเร็จและอยู่ในหน้า Auth -> Redirect ไปยังหน้าที่เหมาะสม
      if (isAuthPage) {
        if (user.role == 'SUPER_ADMIN') return '/admin-dashboard';

        if (user.tenantId == null) {
          return user.role == 'CLIENT_OWNER'
              ? '/onboarding'
              : '/pending-tenant';
        }

        // // ถ้าเป็น STAFF / AFFILIATE แต่ยังไม่มี tenant_id ให้ส่งไปหน้ารออนุมัติ
        // if (user.tenantId == null) {
        //   return '/pending-tenant';
        // }

        return '/campaigns';
      }

      // // 3. Route Guard เมื่อล็อกอินแล้วและเข้าใช้งานระบบ
      // if (user.role == 'SUPER_ADMIN') {
      //   return state.matchedLocation == '/admin-dashboard'
      //       ? null
      //       : '/admin-dashboard';
      // }

      // if (user.tenantId == null) {
      //   if (user.role == 'CLIENT_OWNER') {
      //     return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      //   } else {
      //     return state.matchedLocation == '/pending-tenant'
      //         ? null
      //         : '/pending-tenant';
      //   }
      // }

      // // 4. กรณีมี tenant_id เรียบร้อยแล้ว แต่เข้าหน้า onboarding/pending
      // if (state.matchedLocation == '/onboarding' ||
      //     state.matchedLocation == '/pending-tenant') {
      //   return '/campaigns';
      // }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const CreateTenantScreen(),
      ),
      GoRoute(
        path: '/pending-tenant',
        builder: (context, state) => const PendingTenantScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/campaigns',
        // builder: (context, state) => const CampaignsScreen(),
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('หน้าหลัก Campaigns'))),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/campaign',
                builder: (context, state) => const CampaignsScreen(),
              ),
            ],
          ),
          // Branch สำรองสำหรับเมนูอื่นๆ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('Chat'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/affiliate',
                builder: (context, state) => const AffiliateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
