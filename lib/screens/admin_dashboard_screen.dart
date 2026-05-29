import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/challenge_service.dart';
import 'team_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // logout + notification bell
                    Row(
                      children: [
                        // notification bell
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream:
                          ChallengeService.unreadNotificationsStream(),
                          builder: (context, snap) {
                            final unread = snap.data ?? [];
                            return GestureDetector(
                              onTap: () => _showNotificationsSheet(context),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: unread.isNotEmpty
                                      ? AppTheme.primary.withOpacity(0.15)
                                      : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: unread.isNotEmpty
                                        ? AppTheme.primary.withOpacity(0.4)
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.notifications_rounded,
                                      size: 20,
                                      color: unread.isNotEmpty
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                    ),
                                    if (unread.isNotEmpty)
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${unread.length}',
                                              style: const TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // logout
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const TeamLoginScreen()),
                                    (route) => false,
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.logout_rounded,
                                    size: 14,
                                    color: AppTheme.textSecondary),
                                SizedBox(width: 4),
                                Text('خروج',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'لوحة التحكم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'الفرق'),
                    Tab(text: 'التحديات'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Expanded(
                child: TabBarView(
                  children: [
                    _TeamsTab(),
                    _ChallengesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) async {
    await ChallengeService.markAllNotificationsRead();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: ChallengeService.allNotificationsStream(),
            builder: (ctx, snap) {
              final notifications = snap.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('الإشعارات',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    if (notifications.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  size: 40, color: AppTheme.textSecondary),
                              SizedBox(height: 8),
                              Text('مفيش إشعارات لسه',
                                  style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final notif = notifications[i];
                            final bool isRead = notif['read'] as bool? ?? true;
                            final ts = notif['createdAt'] as Timestamp?;
                            final time = ts != null ? _formatTime(ts.toDate()) : '';
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? AppTheme.background
                                    : AppTheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRead
                                      ? AppTheme.border
                                      : AppTheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(notif['title'] as String? ?? '',
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(notif['body'] as String? ?? '',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(time,
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('🏆', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'دلوقتي';
    if (diff.inMinutes < 60) return 'من \${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'من \${diff.inHours} ساعة';
    return 'من \${diff.inDays} يوم';
  }
}

// ─── Teams Tab ─────────────────────────────────────────────────────────────

class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChallengeService.teamsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final teams = snap.data ?? [];
        final doneCount = teams.where((t) => t['done'] == true).length;
        final activeCount = teams.length - doneCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'فرق نشطة',
                      value: '$activeCount',
                      icon: Icons.groups_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'أنهوا اللعبة',
                      value: '$doneCount',
                      icon: Icons.emoji_events_rounded,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (teams.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('مفيش فرق لسه',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: teams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final team = teams[i];
                      final bool done = team['done'] as bool? ?? false;
                      final int current =
                          team['currentChallengeIndex'] as int? ?? 0;

                      return FutureBuilder<int>(
                        future: ChallengeService.getChallenges()
                            .then((c) => c.length),
                        builder: (context, snapTotal) {
                          final total = snapTotal.data ?? 1;
                          final progress =
                          total == 0 ? 0.0 : current / total;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: done
                                    ? AppTheme.success.withOpacity(0.4)
                                    : AppTheme.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: done
                                            ? AppTheme.success
                                            .withOpacity(0.15)
                                            : AppTheme.primary
                                            .withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        done ? 'فاز 🏆' : 'في التقدم',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: done
                                              ? AppTheme.success
                                              : AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      team['name'] as String? ?? '',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: AppTheme.border,
                                    color: done
                                        ? AppTheme.success
                                        : AppTheme.primary,
                                    minHeight: 5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'التحدي $current من $total',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Challenges Tab ────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .orderBy('order')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final docs = snap.data?.docs ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // add button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddChallengeSheet(context, docs.length),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة تحدي جديد'),
                ),
              ),
              const SizedBox(height: 16),

              if (docs.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('مفيش تحديات لسه، اضغط إضافة!',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final data =
                      docs[i].data() as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            // delete button
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(context, docs[i].id),
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 20),
                            ),
                            const Spacer(),
                            // challenge info
                            Expanded(
                              flex: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        data['title'] as String? ?? '',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary
                                              .withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '#${data['order']}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['description'] as String? ?? '',
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.lock_outline,
                                          size: 12,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['password'] as String? ?? '',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddChallengeSheet(BuildContext context, int currentCount) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'إضافة تحدي جديد',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // title
                  const Text('عنوان التحدي',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'مثلاً: اوصل للنقطة الصفراء'),
                  ),
                  const SizedBox(height: 12),

                  // description
                  const Text('وصف التحدي',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration:
                    const InputDecoration(hintText: 'اشرح المطلوب...'),
                  ),
                  const SizedBox(height: 12),

                  // password
                  const Text('كلمة السر',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passCtrl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration:
                    const InputDecoration(hintText: 'كلمة السر السرية'),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (titleCtrl.text.trim().isEmpty ||
                            descCtrl.text.trim().isEmpty ||
                            passCtrl.text.trim().isEmpty) {
                          return;
                        }
                        setModalState(() => isLoading = true);
                        await ChallengeService.addChallenge(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          order: currentCount + 1,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('حفظ التحدي'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('حذف التحدي؟',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('مش هتقدر ترجعه تاني',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لأ',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await ChallengeService.deleteChallenge(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('احذف',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}