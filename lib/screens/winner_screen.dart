import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'team_login_screen.dart';

class WinnerScreen extends StatefulWidget {
  final String teamName;
  const WinnerScreen({super.key, required this.teamName});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 96,
                    color: Color(0xFFF0B429),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'مبروك! 🎉',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.teamName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'خلصتوا كل التحديات! 🏆',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),

                // confetti dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final color in [
                      AppTheme.primary,
                      const Color(0xFFF0B429),
                      AppTheme.success,
                      Colors.redAccent,
                      AppTheme.primary,
                    ])
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                  ],
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const TeamLoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('العب مرة تانية'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
