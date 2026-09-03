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

import 'package:ads_nest/features/campaigns/presentation/screens/campaigns_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/main_layout.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard', // กำหนดจุดเริ่มต้น
  routes: [
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
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Affiliate'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Profile'))),
            ),
          ],
        ),
      ],
    ),
  ],
);
