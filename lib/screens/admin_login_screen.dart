import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _wrongPassword = false;

  // TODO: استبدل بالباسوورد الحقيقية من Firebase لاحقاً
  static const String _adminPassword = 'admin1234';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _wrongPassword = false;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    if (_passwordController.text == _adminPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _wrongPassword = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // nav bar - back button + admin badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            size: 14, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text('رجوع',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(),

                    // logo
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          size: 40, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'دخول الأدمن',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'للمشرفين فقط',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary),
                    ),

                    const Spacer(),

                    // password field
                    Align(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'كلمة المرور',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        suffixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.primary),
                        errorText: _wrongPassword ? 'كلمة المرور غلط' : null,
                        errorStyle:
                            const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // login button - outlined style
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _login,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary, strokeWidth: 2),
                              )
                            : const Text('دخول كأدمن'),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
