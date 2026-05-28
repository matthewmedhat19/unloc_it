import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/challenge_service.dart';
import 'team_login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
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
                                size: 14, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Text('خروج',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
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
                    Tab(text: 'الترتيب'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Expanded(
                child: TabBarView(
                  children: [
                    _TeamsTab(),
                    _ChallengesTab(),
                    _LeaderboardTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

// ─── Leaderboard Tab ───────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  // حسب وقت الإنهاء — اللي خلص الأول يبقى أول
  List<Map<String, dynamic>> _sortTeams(List<Map<String, dynamic>> teams) {
    final done = teams.where((t) => t['done'] == true).toList()
      ..sort((a, b) {
        final aTime = a['completedAt'];
        final bTime = b['completedAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return (aTime as Timestamp).compareTo(bTime as Timestamp);
      });

    final inProgress = teams.where((t) => t['done'] != true).toList()
      ..sort((a, b) {
        final aIdx = a['currentChallengeIndex'] as int? ?? 0;
        final bIdx = b['currentChallengeIndex'] as int? ?? 0;
        return bIdx.compareTo(aIdx); // الأكتر تقدماً فوق
      });

    return [...done, ...inProgress];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChallengeService.teamsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final teams = _sortTeams(snap.data ?? []);

        if (teams.isEmpty) {
          return const Center(
            child: Text('مفيش فرق لسه',
                style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

        return FutureBuilder<int>(
          future: ChallengeService.getChallenges().then((c) => c.length),
          builder: (context, snapTotal) {
            final total = snapTotal.data ?? 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // top 3 podium
                  if (teams.length >= 3) ...[
                    const SizedBox(height: 8),
                    _Podium(teams: teams.take(3).toList(), total: total),
                    const SizedBox(height: 20),
                  ],

                  // rest of teams
                  if (teams.length > 3)
                    Expanded(
                      child: ListView.separated(
                        itemCount: teams.length - 3,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final team = teams[i + 3];
                          final rank = i + 4;
                          final bool done = team['done'] as bool? ?? false;
                          final int current =
                              team['currentChallengeIndex'] as int? ?? 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                // progress
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: total == 0
                                          ? 0
                                          : current / total,
                                      backgroundColor: AppTheme.border,
                                      color: AppTheme.primary,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // name + status
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      team['name'] as String? ?? '',
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      done
                                          ? 'خلص ✓'
                                          : 'تحدي $current من $total',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: done
                                              ? AppTheme.success
                                              : AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // rank badge
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppTheme.border,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Podium ────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final int total;

  const _Podium({required this.teams, required this.total});

  @override
  Widget build(BuildContext context) {
    // ترتيب البودويم: 2 - 1 - 3
    final order = [1, 0, 2];
    final heights = [80.0, 110.0, 60.0];
    final colors = [
      const Color(0xFFC0C0C0), // فضي
      const Color(0xFFF0B429), // ذهبي
      const Color(0xFFCD7F32), // برونزي
    ];
    final medals = ['🥈', '🥇', '🥉'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final teamIndex = order[i];
        final team = teams[teamIndex];
        final bool done = team['done'] as bool? ?? false;
        final int current = team['currentChallengeIndex'] as int? ?? 0;

        return Expanded(
          child: Column(
            children: [
              // medal + name
              Text(medals[i], style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                team['name'] as String? ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors[i],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                done ? 'خلص ✓' : '$current/$total',
                style: TextStyle(
                  fontSize: 10,
                  color: done ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              // podium block
              Container(
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors[i].withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                  border: Border.all(color: colors[i].withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '${teamIndex + 1}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors[i],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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