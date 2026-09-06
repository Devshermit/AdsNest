// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../layout/main_layout.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/dashboard',
//     routes: [
//       StatefulShellRoute.indexedStack(
//         builder: (context, state, navigationShell) =>
//             MainLayout(navigationShell: navigationShell),
//         branches: [
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/dashboard',
//                 builder: (context, state) =>
//                     const Scaffold(body: Center(child: Text('Dashboard'))),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/chat',
//                 builder: (context, state) =>
//                     const Scaffold(body: Center(child: Text('Chat'))),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/affiliate',
//                 builder: (context, state) =>
//                     const Scaffold(body: Center(child: Text('Affiliate'))),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/profile',
//                 builder: (context, state) =>
//                     const Scaffold(body: Center(child: Text('Profile'))),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   );
// });

import 'package:ads_nest/features/affiliate/presentation/screens/affiliate_screen.dart';
import 'package:ads_nest/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ads_nest/features/auth/presentation/screens/auth_screen.dart';
import 'package:ads_nest/features/auth/presentation/screens/register_screen.dart';
import 'package:ads_nest/features/campaigns/presentation/screens/campaigns_screen.dart';
import 'package:ads_nest/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/main_layout.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider).value;

  return GoRouter(
    initialLocation: '/affiliate',
    redirect: (context, state) {
      // ตรวจสอบว่ามี User ใน Session หรือไม่
      final isAuthenticated = authState?.session != null;

      // เช็คว่าผู้ใช้กำลังจะไปหน้า Auth (Login หรือ Register) หรือไม่
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // 1. ยังไม่ล็อกอิน และพยายามเข้าหน้าอื่น -> ส่งไปหน้า /login
      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      // 2. ล็อกอินแล้ว แต่พยายามเข้าหน้า /login หรือ /register -> ส่งไปหน้าหลัก /
      if (isAuthenticated && isGoingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
