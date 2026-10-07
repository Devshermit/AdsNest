import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_handler.dart';
import '../controllers/auth_provider.dart';

// Provider สำหรับดึงสถิติรวมของ Platform
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final supabase = Supabase.instance.client;

  final tenantCount = await supabase.from('tenants').count();
  final userCount = await supabase.from('profiles').count();

  return {'total_tenants': tenantCount, 'total_users': userCount};
});

// Provider สำหรับดึงรายการ Tenants ทั้งหมด
final allTenantsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('tenants')
      .select()
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final tenantsAsync = ref.watch(allTenantsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(adminStatsProvider);
              ref.invalidate(allTenantsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'ออกจากระบบ',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18,
                    color: Colors.purple.shade900,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SUPER ADMIN PRIVILEGES',
                    style: TextStyle(
                      color: Colors.purple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Summary Cards
            statsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text(
                AuthErrorHandler.parse(err),
                style: const TextStyle(color: Colors.red),
              ),
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'องค์กรทั้งหมด',
                      value: '${stats['total_tenants'] ?? 0}',
                      icon: Icons.business_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'ผู้ใช้ในระบบ',
                      value: '${stats['total_users'] ?? 0}',
                      icon: Icons.people_alt_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tenant List Section
            Text(
              'รายการองค์กรในระบบ (Tenants)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            tenantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text(AuthErrorHandler.parse(err))),
              data: (tenants) {
                if (tenants.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('ยังไม่มีองค์กรในระบบ')),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    final isActive = tenant['is_active'] ?? true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          child: Icon(
                            Icons.apartment_rounded,
                            color: isActive
                                ? Colors.green.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                        title: Text(
                          tenant['company_name'] ?? 'Un-named Tenant',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Industry: ${tenant['industry'] ?? 'N/A'} • ID: ${tenant['id'].toString().substring(0, 8)}...',
                        ),
                        trailing: Switch(
                          value: isActive,
                          onChanged: (val) async {
                            // สลับสถานะ Active / Inactive ของ Tenant
                            await Supabase.instance.client
                                .from('tenants')
                                .update({'is_active': val})
                                .eq('id', tenant['id']);
                            ref.invalidate(allTenantsProvider);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
