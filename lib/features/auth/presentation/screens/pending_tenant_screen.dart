import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/auth_error_handler.dart';
import '../controllers/auth_provider.dart';

class PendingTenantScreen extends ConsumerStatefulWidget {
  const PendingTenantScreen({super.key});

  @override
  ConsumerState<PendingTenantScreen> createState() => _PendingTenantScreenState();
}

class _PendingTenantScreenState extends ConsumerState<PendingTenantScreen> {
  final _tenantIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isAttaching = false;

  @override
  void dispose() {
    _tenantIdController.dispose();
    super.dispose();
  }

  // ผูกผู้ใช้เข้ากับ Tenant ID / Invite Code ที่กรอกเพิ่ม
  Future<void> _attachTenantId() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAttaching = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final inputTenantId = _tenantIdController.text.trim();

      if (user != null) {
        // อัปเดต tenant_id ใน profiles
        await Supabase.instance.client
            .from('profiles')
            .update({'tenant_id': inputTenantId})
            .eq('id', user.id);

        messenger.showSnackBar(
          const SnackBar(content: Text('ผูกองค์กรสำเร็จ กำลังโหลดข้อมูลใหม่...')),
        );

        // สั่งให้ Riverpod รีโหลดข้อมูล currentUser เพื่อให้ GoRouter Redirect อัตโนมัติ
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AuthErrorHandler.parse(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAttaching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รอการอนุมัติเข้าร่วมองค์กร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'ออกจากระบบ',
            onPressed: isLoggingOut
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.domain_disabled_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'คุณยังไม่มีสังกัดองค์กรในระบบ',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'กรุณารอผู้ดูแลองค์กรส่งคำเชิญ หรือหากมีรหัสคำเชิญ (Tenant ID) สามารถกรอกเพื่อเข้าร่วมได้ทันทีด้านล่างนี้',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Form กรอก Tenant ID
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tenantIdController,
                      decoration: const InputDecoration(
                        labelText: 'กรอกรหัสองค์กร (Tenant ID / Invite Code)',
                        prefixIcon: Icon(Icons.key_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกรหัสองค์กร'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isAttaching ? null : _attachTenantId,
                        icon: _isAttaching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.link_rounded),
                        label: const Text('เข้าร่วมองค์กร'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              // Refresh Status Button
              OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(currentUserProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('อัปเดตสถานะข้อมูลเรียบร้อยแล้ว')),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('ตรวจสอบสถานะการอนุมัติอีกครั้ง'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}