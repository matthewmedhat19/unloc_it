import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/challenge_service.dart';
import 'winner_screen.dart';

class ChallengeScreen extends StatefulWidget {
  final String teamName;
  final String teamId;
  final List<Map<String, dynamic>> challenges;
  final int startIndex;

  const ChallengeScreen({
    super.key,
    required this.teamName,
    required this.teamId,
    required this.challenges,
    required this.startIndex,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late int _currentIndex;
  final _passwordController = TextEditingController();
  bool _wrongPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submitPassword() async {
    final input = _passwordController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _wrongPassword = false;
    });

    final correct =
        widget.challenges[_currentIndex]['password'] as String;

    if (input == correct) {
      final nextIndex = _currentIndex + 1;
      final total = widget.challenges.length;

      try {
        // حدّث تقدم الفريق في Firestore
        await ChallengeService.advanceTeam(
          teamId: widget.teamId,
          nextIndex: nextIndex,
          totalChallenges: total,
        );
      } catch (_) {
        // لو في مشكلة في الاتصال، كمّل محلياً
      }

      if (!mounted) return;
      _passwordController.clear();

      if (nextIndex >= total) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WinnerScreen(teamName: widget.teamName),
          ),
        );
      } else {
        setState(() {
          _currentIndex = nextIndex;
          _isLoading = false;
        });
        _showSuccessSnack();
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _wrongPassword = true;
      });
    }
  }

  void _showSuccessSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('صح! كمّل على التحدي الجاي 🎉'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenges[_currentIndex];
    final total = widget.challenges.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / $total',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          widget.teamName,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / total,
                        backgroundColor: AppTheme.surface,
                        color: AppTheme.primary,
                        minHeight: 6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // challenge card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'التحدي ${_currentIndex + 1}',
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              challenge['title'] as String,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppTheme.border),
                            const SizedBox(height: 12),
                            Text(
                              challenge['description'] as String,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // password input
                    Align(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'كلمة السر',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'اكتب كلمة السر هنا...',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.primary),
                        errorText: _wrongPassword
                            ? 'كلمة السر غلط، حاول تاني'
                            : null,
                        errorStyle: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                      ),
                      onSubmitted: (_) => _submitPassword(),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitPassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('تأكيد وكمّل ✓'),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
