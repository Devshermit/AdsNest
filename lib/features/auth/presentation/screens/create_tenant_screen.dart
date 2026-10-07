import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_handler.dart';
import '../controllers/auth_provider.dart';

class CreateTenantScreen extends ConsumerStatefulWidget {
  const CreateTenantScreen({super.key});

  @override
  ConsumerState<CreateTenantScreen> createState() => _CreateTenantPageState();
}

class _CreateTenantPageState extends ConsumerState<CreateTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _createTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) throw Exception('ไม่พบข้อมูลการเข้าสู่ระบบ');

      // 1. สร้าง Tenant ใหม่ลงในตาราง tenants
      final tenantResponse = await supabase
          .from('tenants')
          .insert({
            'company_name': _companyNameController.text.trim(),
            'industry': _industryController.text.trim().isNotEmpty
                ? _industryController.text.trim()
                : null,
            'is_active': true,
          })
          .select('id')
          .single();

      final String newTenantId = tenantResponse['id'];

      // 2. อัปเดต tenant_id ลงตาราง profiles ของผู้ใช้ปัจจุบัน
      await supabase
          .from('profiles')
          .update({'tenant_id': newTenantId})
          .eq('id', currentUser.id);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('สร้างองค์กรสำเร็จ! กำลังเข้าสู่หน้าหลัก...'),
        ),
      );

      // // 3. รีโหลด currentUserProvider เพื่อให้ GoRouter Redirect ไปยังหน้าหลักทันที
      // ref.invalidate(currentUserProvider);

      // 3. รีเฟรชและรอจนกว่า currentUserProvider จะได้ข้อมูล Profile ตัวใหม่สำเร็จ
      // ignore: unused_result
      await ref.refresh(currentUserProvider.future);

      // 4. นำทางไปยังหน้า /campaigns โดยตรง
      if (mounted) {
        context.go('/campaigns');
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AuthErrorHandler.parse(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าองค์กรของคุณ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'ออกจากระบบ',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 72,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'ยินดีต้อนรับ! สร้างองค์กรเพื่อเริ่มต้นใช้งาน',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'กรอกรายละเอียดเกี่ยวกับบริษัทหรือแบรนด์ของคุณ เพื่อตั้งค่าพื้นที่ทำงาน',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Company Name Field
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อบริษัท / องค์กร *',
                    prefixIcon: Icon(Icons.apartment_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'กรุณากรอกชื่อบริษัท'
                      : null,
                ),
                const SizedBox(height: 16),

                // Industry Field
                TextFormField(
                  controller: _industryController,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทอุตสาหกรรม (เช่น E-commerce, Fashion)',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTenant,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'สร้างองค์กรและเริ่มต้นใช้งาน',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
