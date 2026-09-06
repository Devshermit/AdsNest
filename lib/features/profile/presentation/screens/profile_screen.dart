import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/auth_error_handler.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../controllers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _fullNameController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _fullNameController.text = user.fullName;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          fullName: _fullNameController.text.trim(),
          imageFile: _selectedImage,
        );

    if (!mounted) return;
    final state = ref.read(profileControllerProvider);
    if (!state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตข้อมูลโปรไฟล์เรียบร้อยแล้ว')),
      );
    }
  }

  // Dialog สำหรับเปลี่ยนรหัสผ่าน
  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'เปลี่ยนรหัสผ่าน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่านใหม่',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white60),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ยืนยันรหัสผ่านใหม่',
                  prefixIcon: Icon(
                    Icons.lock_reset_outlined,
                    color: Colors.white60,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != newPasswordController.text
                    ? 'รหัสผ่านไม่ตรงกัน'
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
                  .read(profileControllerProvider.notifier)
                  .updatePassword(newPasswordController.text.trim());

              if (context.mounted) {
                final state = ref.read(profileControllerProvider);
                if (state.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AuthErrorHandler.parse(state.error)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว'),
                    ),
                  );
                }
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // Dialog ยืนยันออกจากระบบ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ออกจากระบบ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'คุณต้องการออกจากระบบใช่หรือไม่?',
          style: TextStyle(color: Colors.white70),
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(currentUserProvider);
    final isLoading = ref.watch(profileControllerProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ของฉัน')),
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar Selector
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null)
                                    as ImageProvider?,
                          child:
                              user.avatarUrl == null && _selectedImage == null
                              ? Text(
                                  user.fullName.isEmpty
                                      ? 'U'
                                      : user.fullName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 36),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton.filled(
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                            ),
                            onPressed: isLoading ? null : _pickImage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Role & Tenant Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          avatar: const Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                          ),
                          label: Text('Role: ${user.role.toUpperCase()}'),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.business_rounded, size: 16),
                          label: Text('Tenant: ${user.tenantId}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Full Name Input
                    TextFormField(
                      controller: _fullNameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อ-นามสกุล',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Read-only
                    TextFormField(
                      initialValue: user.email,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'อีเมล',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.save_rounded),
                        label: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('บันทึกการเปลี่ยนแปลง'),
                        onPressed: isLoading ? null : _saveProfile,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('เปลี่ยนรหัสผ่าน'),
                        onPressed: isLoading
                            ? null
                            : () => _showChangePasswordDialog(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'ออกจากระบบ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: isLoading
                            ? null
                            : () => _showLogoutDialog(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
