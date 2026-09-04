import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_handler.dart';
import '../controllers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true; // สลับระหว่าง Login และ Register
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    // Animation สำหรับการเคลื่อนไหวของ Ambient Background
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final notifier = ref.read(authControllerProvider.notifier);
    if (_isLogin) {
      await notifier.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      await notifier.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );
    }

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorHandler.parse(authState.error)),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!_isLogin) {
      _showVerifyEmailDialog(context, _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Ambient Background Motion
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(color: const Color(0xFF0D0E15)),
                  Positioned(
                    top: -100 + (_bgAnimationController.value * 50),
                    left: -50 + (_bgAnimationController.value * 30),
                    child: _buildGlowCircle(const Color(0xFF6366F1), 350),
                  ),
                  Positioned(
                    bottom: -80 - (_bgAnimationController.value * 40),
                    right: -50 + (_bgAnimationController.value * 50),
                    child: _buildGlowCircle(const Color(0xFFA855F7), 380),
                  ),
                ],
              );
            },
          ),

          // 2. Center Glassmorphic Auth Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Logo & Animated Title
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(_isLogin),
                              children: [
                                Icon(
                                  _isLogin
                                      ? Icons.lock_person_rounded
                                      : Icons.person_add_rounded,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isLogin ? 'Welcome Back' : 'Create Account',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Full Name Field (Register Mode Only)
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTextField(
                                controller: _fullNameController,
                                label: 'ชื่อ-นามสกุล',
                                icon: Icons.badge_outlined,
                                enabled: !isLoading,
                                validator: (v) =>
                                    !_isLogin && (v == null || v.isEmpty)
                                    ? 'กรุณากรอกชื่อ'
                                    : null,
                              ),
                            ),
                            crossFadeState: _isLogin
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 300),
                          ),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'อีเมล',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            validator: (v) => v == null || !v.contains('@')
                                ? 'อีเมลไม่ถูกต้อง'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'รหัสผ่าน',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            enabled: !isLoading,
                            validator: (v) => v == null || v.length < 6
                                ? 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'
                                : null,
                          ),
                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _showForgotPasswordDialog(context),
                                child: const Text(
                                  'ลืมรหัสผ่าน?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 28),

                          // Animated Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mode Switcher Toggle
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => setState(() => _isLogin = !_isLogin),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily:
                                    theme.textTheme.bodyMedium?.fontFamily,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? 'ยังไม่มีบัญชีใช่ไหม? '
                                        : 'มีบัญชีอยู่แล้ว? ',
                                  ),
                                  Text(
                                    _isLogin ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider "หรือเข้าสู่ระบบด้วย"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Text(
                                  'หรือเข้าสู่ระบบด้วย',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Social Login Buttons Grid
                          Row(
                            children: [
                              // Google Sign-In
                              Expanded(
                                child: _buildSocialButton(
                                  label: 'Google',
                                  icon: Image.network(
                                    'https://authjs.dev/img/providers/google.svg',
                                    height: 20,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.g_mobiledata,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              authControllerProvider.notifier,
                                            )
                                            .signInWithOAuth(
                                              OAuthProvider.google,
                                            ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Apple Sign-In
                              Expanded(
                                child: _buildSocialButton(
                                  label: 'Apple',
                                  icon: const Icon(
                                    Icons.apple,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              authControllerProvider.notifier,
                                            )
                                            .signInWithOAuth(
                                              OAuthProvider.apple,
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Component: วงกลมส่องแสงเรืองแสงสำหรับ Mesh Background
  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // Component: Custom Input Field ทรงโมเดิร์น
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white60),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
    );
  }

  // Helper Component: ปุ่ม Social Login แบบ Glassmorphic Card
  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'รีเซ็ตรหัสผ่าน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'กรอกอีเมลของคุณเพื่อรับลิงก์สำหรับตั้งรหัสผ่านใหม่',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resetEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white60),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || !v.contains('@')
                    ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              await ref
                  .read(authControllerProvider.notifier)
                  .resetPassword(resetEmailController.text.trim());

              if (context.mounted) {
                final state = ref.read(authControllerProvider);
                if (state.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AuthErrorHandler.parse(state.error)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('ส่งลิงก์'),
          ),
        ],
      ),
    );
  }

  // Dialog แสดงคำแนะนำให้ไปกดยืนยันในอีเมล
  void _showVerifyEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.mark_email_unread_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 10),
            Text(
              'ยืนยันอีเมลของคุณ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ระบบได้ส่งลิงก์ยืนยันตัวตนไปที่:',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'กรุณาตรวจสอบกล่องข้อความ (หรือ Junk/Spam) และคลิกลิงก์ในอีเมลเพื่อเข้าใช้งานระบบ',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .resendVerificationEmail(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ส่งอีเมลยืนยันอีกครั้งแล้ว')),
                );
              }
            },
            child: const Text(
              'ส่งอีเมลอีกครั้ง',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isLogin = true); // สลับกลับมาหน้า Login
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
