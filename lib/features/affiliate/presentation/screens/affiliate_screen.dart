import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/database_error_handler.dart';
import '../controllers/affiliate_provider.dart';
import '../../data/models/affiliate_link_model.dart';

class AffiliateScreen extends ConsumerWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(affiliateLinksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการ Affiliate Links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(affiliateLinksProvider);
              ref.invalidate(campaignListProvider);
              ref.invalidate(affiliateUsersProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLinkDialog(context, ref),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('สร้างลิงก์ใหม่'),
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        // 🟢 Handle Error สวยงาม พร้อมปุ่ม Retry
        error: (err, stackTrace) {
          final errorMessage = DatabaseErrorHandler.parse(err);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(affiliateLinksProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ลองใหม่อีกครั้ง'),
                  ),
                ],
              ),
            ),
          );
        },

        // 🟢 Empty State
        data: (links) {
          if (links.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_off_rounded,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มี Affiliate Link ในระบบ',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กดปุ่ม "สร้างลิงก์ใหม่" ด้านล่างเพื่อเริ่มสร้างลิงก์',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return _AffiliateCard(link: link);
            },
          );
        },
      ),
    );
  }

  void _showCreateLinkDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (ctx) => const _CreateLinkDialog());
  }
}

// Dialog สำหรับสร้าง Affiliate Link พร้อมการจัดการ Error ใน Dropdown
class _CreateLinkDialog extends ConsumerStatefulWidget {
  const _CreateLinkDialog();

  @override
  ConsumerState<_CreateLinkDialog> createState() => _CreateLinkDialogState();
}

class _CreateLinkDialogState extends ConsumerState<_CreateLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  late final TextEditingController _shortCodeController;

  String? _selectedCampaignId;
  String? _selectedAffiliateId;

  @override
  void initState() {
    super.initState();
    _shortCodeController = TextEditingController(text: _generateRandomCode());
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _shortCodeController.dispose();
    super.dispose();
  }

  String _generateRandomCode() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      6,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignListProvider);
    final usersAsync = ref.watch(affiliateUsersProvider);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'สร้าง Affiliate Link',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Dropdown Campaign พร้อมจัดการ Error
              campaignsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: LinearProgressIndicator(),
                ),
                error: (err, _) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        DatabaseErrorHandler.parse(err),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white60,
                      ),
                      onPressed: () => ref.invalidate(campaignListProvider),
                    ),
                  ],
                ),
                data: (campaigns) => DropdownButtonFormField<String>(
                  initialValue: _selectedCampaignId,
                  dropdownColor: const Color(0xFF2A2B38),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'เลือกแคมเปญ',
                    prefixIcon: Icon(
                      Icons.campaign_outlined,
                      color: Colors.white60,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: campaigns.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['id'],
                      child: Text(c['title']!, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCampaignId = val),
                  validator: (v) => v == null ? 'กรุณาเลือกแคมเปญ' : null,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Dropdown Affiliate User พร้อมจัดการ Error
              usersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: LinearProgressIndicator(),
                ),
                error: (err, _) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        DatabaseErrorHandler.parse(err),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white60,
                      ),
                      onPressed: () => ref.invalidate(affiliateUsersProvider),
                    ),
                  ],
                ),
                data: (users) => DropdownButtonFormField<String>(
                  initialValue: _selectedAffiliateId,
                  dropdownColor: const Color(0xFF2A2B38),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'เลือกนักรีวิว (Affiliate)',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.white60,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: users.map((u) {
                    return DropdownMenuItem<String>(
                      value: u['id'],
                      child: Text(u['name']!, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedAffiliateId = val),
                  validator: (v) => v == null ? 'กรุณาเลือกนักรีวิว' : null,
                ),
              ),
              const SizedBox(height: 12),

              // 3. Destination URL
              TextFormField(
                controller: _destinationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Destination URL (ปลายทาง)',
                  prefixIcon: Icon(Icons.link_rounded, color: Colors.white60),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || !v.startsWith('http')
                    ? 'กรุณากรอก URL ที่ถูกต้อง'
                    : null,
              ),
              const SizedBox(height: 12),

              // 4. Short Code Input
              TextFormField(
                controller: _shortCodeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Short Code',
                  prefixIcon: const Icon(
                    Icons.tag_rounded,
                    color: Colors.white60,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.autorenew_rounded,
                      color: Colors.white60,
                    ),
                    onPressed: () => setState(
                      () => _shortCodeController.text = _generateRandomCode(),
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอก Short Code' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.white54)),
        ),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            final newLink = AffiliateLinkModel(
              id: '',
              campaignId: _selectedCampaignId!,
              affiliateId: _selectedAffiliateId!,
              destinationUrl: _destinationController.text.trim(),
              shortCode: _shortCodeController.text.trim(),
              clicksCount: 0,
              createdAt: DateTime.now(),
            );

            await ref
                .read(affiliateControllerProvider.notifier)
                .createLink(newLink);

            final state = ref.read(affiliateControllerProvider);
            if (state.hasError) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(DatabaseErrorHandler.parse(state.error)),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else {
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('สร้าง Affiliate Link เรียบร้อยแล้ว'),
                ),
              );
            }
          },
          child: const Text('สร้างลิงก์'),
        ),
      ],
    );
  }
}

// Card Component
class _AffiliateCard extends ConsumerWidget {
  final AffiliateLinkModel link;
  const _AffiliateCard({required this.link});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ลบ Affiliate Link',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'คุณต้องการลบลิงก์ code "${link.shortCode}" ใช่หรือไม่?',
          style: const TextStyle(color: Colors.white70),
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
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);

              await ref
                  .read(affiliateControllerProvider.notifier)
                  .deleteLink(link.id);

              final state = ref.read(affiliateControllerProvider);
              if (state.hasError) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(DatabaseErrorHandler.parse(state.error)),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('ลบลิงก์เรียบร้อยแล้ว')),
                );
              }
            },
            child: const Text('ลบลิงก์'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shortUrl = 'https://yourdomain.com/a/${link.shortCode}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    link.campaignTitle ??
                        'Campaign: ${link.campaignId.substring(0, 8)}...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${link.clicksCount} Clicks',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteDialog(context, ref),
                      tooltip: 'ลบลิงก์',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'นักรีวิว: ${link.affiliateName ?? link.affiliateId}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Short Link Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shortUrl,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shortUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('คัดลอกลิงก์เรียบร้อยแล้ว'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
