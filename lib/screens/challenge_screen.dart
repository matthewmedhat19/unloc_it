import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'winner_screen.dart';

// بيانات وهمية للـ UI - هتتبدل بـ Firebase لاحقاً
final List<Map<String, String>> _mockChallenges = [
  {
    'title': 'اوصل للنقطة الصفراء',
    'description':
    'روح للمكان اللي فيه الرمز الأصفر وصوّر نفسك جنبه، بعدين ادور على كلمة السر المكتوبة على الورقة الجنبه.',
    'password': 'صفراء',
  },
  {
    'title': 'حل اللغز',
    'description':
    'في المكان ده هتلاقي لغز مكتوب على ورقة — حله وحط الإجابة كلمة السر.',
    'password': 'نجمة',
  },
  {
    'title': 'اجمع الفريق',
    'description':
    'اجمع كل أفراد فريقك في مكان واحد وصوروا سيلفي جماعي، بعدين ادور على كلمة السر.',
    'password': 'فريق',
  },
];

class ChallengeScreen extends StatefulWidget {
  final String teamName;
  const ChallengeScreen({super.key, required this.teamName});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentIndex = 0;
  final _passwordController = TextEditingController();
  bool _wrongPassword = false;
  bool _isLoading = false;

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

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final correct = _mockChallenges[_currentIndex]['password']!;

    if (input == correct) {
      _passwordController.clear();

      if (_currentIndex + 1 >= _mockChallenges.length) {
        // خلص كل التحديات!
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WinnerScreen(teamName: widget.teamName),
          ),
        );
      } else {
        setState(() {
          _currentIndex++;
          _isLoading = false;
        });
        _showSuccessSnack();
      }
    } else {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _mockChallenges[_currentIndex];
    final total = _mockChallenges.length;

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              challenge['title']!,
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
                              challenge['description']!,
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

                    // password input section
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
                        errorText: _wrongPassword ? 'كلمة السر غلط، حاول تاني' : null,
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