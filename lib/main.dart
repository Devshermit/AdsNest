import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
// import 'core/theme/app_theme.dart';

import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vtbgsbckhpifumwyzwqk.supabase.co',
    publishableKey: 'sb_publishable_UzYXimqEZk9V_wOT7BHRvA_fuWl57-1',
  );

  runApp(const ProviderScope(child: AdsNestApp()));
}

class AdsNestApp extends ConsumerWidget {
  const AdsNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AdsNest',
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.darkTheme,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      // routerConfig: router,
      routerConfig: appRouter,
    );
  }
}
