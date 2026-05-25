import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'team_login_screen.dart';

// بيانات وهمية - هتتبدل بـ Firebase لاحقاً
final List<Map<String, dynamic>> _mockTeams = [
  {'name': 'الفريق الأول', 'current': 4, 'total': 3, 'done': false},
  {'name': 'الفريق الثاني', 'current': 3, 'total': 3, 'done': true},
  {'name': 'الفريق الثالث', 'current': 2, 'total': 3, 'done': false},
];

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doneCount = _mockTeams.where((t) => t['done'] == true).length;
    final activeCount = _mockTeams.length - doneCount;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const TeamLoginScreen()),
                        (route) => false,
                      );
                    },
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

              const SizedBox(height: 20),

              // stats row
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'التحديات',
                      value: '5',
                      icon: Icons.flag_rounded,
                      color: const Color(0xFFF0B429),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // teams section title
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'حالة الفرق',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // teams list
              Expanded(
                child: ListView.separated(
                  itemCount: _mockTeams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final team = _mockTeams[i];
                    final bool done = team['done'] as bool;
                    final int current = team['current'] as int;
                    final int total = team['total'] as int;

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: done
                                      ? AppTheme.success.withOpacity(0.15)
                                      : AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
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
                                team['name'] as String,
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
                              value: current / total,
                              backgroundColor: AppTheme.border,
                              color: done ? AppTheme.success : AppTheme.primary,
                              minHeight: 5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'التحدي $current من $total',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  fontSize: 22, fontWeight: FontWeight.w700, color: color)),
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
