
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/portal_page.dart';
import 'package:web_page/widgets/app_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glowCircle(260, AppColors.primary.withOpacity(.12)),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _glowCircle(300, AppColors.primaryLight.withOpacity(.13)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: width < 760
                      ? _mobileLayout()
                      : Row(
                          children: [
                            Expanded(child: _welcomePanel()),
                            const SizedBox(width: 30),
                            SizedBox(width: 430, child: _loginCard()),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        _welcomePanel(compact: true),
        const SizedBox(height: 24),
        _loginCard(),
      ],
    );
  }

  Widget _welcomePanel({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.all(compact ? 4 : 26),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30673AB7),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ShishuCare',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Child screening, simplified.',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A clean workspace for registering children, completing age-based screening and reviewing screening history.',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: AppColors.mutedText,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 28),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FeaturePill(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Child profiles',
                ),
                _FeaturePill(
                  icon: Icons.fact_check_rounded,
                  label: 'Smart screening',
                ),
                _FeaturePill(
                  icon: Icons.history_rounded,
                  label: 'History & reports',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _loginCard() {
    return AppCard(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(
            title: 'Welcome back',
            subtitle: 'Sign in to open the clinical screening workspace.',
            icon: Icons.lock_open_rounded,
          ),
          const SizedBox(height: 26),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'doctor@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Enter workspace'),
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PortalPage()),
                    );
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Secure clinical workspace • ShishuCare',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 1),
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
