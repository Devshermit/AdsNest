import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  // Selected Role (Default: CLIENT_OWNER หรือ AGENCY_STAFF หากมี invite link)
  String _selectedRole = 'CLIENT_OWNER';

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  // ไปยัง Step 2
  void _goToNextStep() {
    if (_step1FormKey.currentState!.validate()) {
      setState(() => _currentStep = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ย้อนกลับ Step 1
  void _goToPreviousStep() {
    setState(() => _currentStep = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onRegisterSubmit() async {
    if (!_step2FormKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
        );

    if (!success && mounted) {
      final errorState = ref.read(authControllerProvider);
      if (errorState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorState.error.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('สมัครสมาชิก (ขั้นตอนที่ ${_currentStep + 1}/2)'),
        leading: _currentStep == 1
            ? IconButton(
                onPressed: isLoading ? null : _goToPreviousStep,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentStep + 1) / 2),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1AccountInfo(),
                  _buildStep2ProfileAndRoleInfo(isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: Email & Password
  // ==========================================
  Widget _buildStep1AccountInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'สร้างบัญชีผู้ใช้ใหม่',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'กรอกอีเมลและรหัสผ่านเพื่อใช้เข้าสู่ระบบ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || !v.contains('@')
                  ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                  : null,
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.length < 6
                  ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                  : null,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                prefixIcon: Icon(Icons.lock_reset_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != _passwordController.text) {
                  return 'รหัสผ่านไม่ตรงกัน';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Next Step Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ถัดไป', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: Full Name & Role Selection
  // ==========================================
  Widget _buildStep2ProfileAndRoleInfo(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ข้อมูลส่วนตัวและบทบาท',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ระบุชื่อและเลือกบทบาทของคุณในระบบ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ-นามสกุล',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
            ),
            const SizedBox(height: 24),

            // Role Selector
            const Text(
              'เลือกบทบาทของคุณ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                const ButtonSegment(
                  value: 'CLIENT_OWNER',
                  label: Text('เจ้าขององค์กร'),
                  icon: Icon(Icons.business),
                ),
                const ButtonSegment(
                  value: 'AGENCY_STAFF',
                  label: Text('ทีมงาน'),
                  icon: Icon(Icons.badge),
                ),
                const ButtonSegment(
                  value: 'AFFILIATE',
                  label: Text('นักรีวิว/ตัวแทน'),
                  icon: Icon(Icons.campaign),
                ),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (set) {
                setState(() => _selectedRole = set.first);
              },
            ),
            const SizedBox(height: 32),

            // Buttons: ย้อนกลับ & ยืนยัน
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('ย้อนกลับ'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onRegisterSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'ยืนยันสมัครสมาชิก',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
