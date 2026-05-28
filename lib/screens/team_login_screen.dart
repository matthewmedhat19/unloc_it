import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/challenge_service.dart';
import 'admin_login_screen.dart';
import 'challenge_screen.dart';

class TeamLoginScreen extends StatefulWidget {
  const TeamLoginScreen({super.key});

  @override
  State<TeamLoginScreen> createState() => _TeamLoginScreenState();
}

class _TeamLoginScreenState extends State<TeamLoginScreen> {
  final _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _enterAsTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final teamName = _teamNameController.text.trim();

      // سجّل الفريق في Firestore أو رجّع الموجود
      final teamData =
          await ChallengeService.registerOrGetTeam(teamName);

      // جيب التحديات من Firestore
      final challenges = await ChallengeService.getChallenges();

      if (!mounted) return;

      if (challenges.isEmpty) {
        setState(() => _isLoading = false);
        _showError('مفيش تحديات لسه، كلم الأدمن!');
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChallengeScreen(
            teamName: teamName,
            teamId: teamData['id'] as String,
            challenges: challenges,
            startIndex: teamData['currentChallengeIndex'] as int? ?? 0,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('في مشكلة في الاتصال، حاول تاني');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToAdminLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // nav bar - admin button top right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _goToAdminLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 15, color: AppTheme.primary),
                          SizedBox(width: 5),
                          Text(
                            'أنا أدمن',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Spacer(),

                      // logo
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.emoji_events_rounded,
                            size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اللعبة',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'سجل دخولك كفريق',
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary),
                      ),

                      const Spacer(),

                      Align(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'اسم فريقك',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _teamNameController,
                        textAlign: TextAlign.right,
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'مثلاً: الفريق الأول',
                          prefixIcon: Icon(Icons.groups_rounded,
                              color: AppTheme.primary),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'اكتب اسم الفريق';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _enterAsTeam,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('دخول'),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
