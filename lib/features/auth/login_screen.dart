import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'admin@alrabee.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'alrabee2026');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(UserRole? specificRole) {
    final auth = context.read<AuthProvider>();
    if (specificRole != null) {
      auth.switchDemoRole(specificRole);
    } else {
      auth.login(_emailController.text, _passwordController.text);
    }
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: AppTokens.borderRadiusXl,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: AppTokens.shadowLg,
              ),
              child: ClipRRect(
                borderRadius: AppTokens.borderRadiusXl,
                child: Row(
                  children: [
                    // Left Brand Hero Panel (Hidden on very narrow screens)
                    if (MediaQuery.of(context).size.width > 768)
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryDark, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: AppTokens.borderRadiusMd,
                                    ),
                                    child: const Text(
                                      'الربيع',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'AL RABEE ERP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                'Enterprise Retail &\nDistribution Platform',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Specialized management for premium imported dates, luxury dry fruits, roasted nuts, artisan chocolates, cold-pressed juices, and air-flown exotic fruits.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: AppTokens.borderRadiusLg,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_user_rounded, color: AppColors.saffronGold, size: 22),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Multi-Role Demo Active. Choose any role on the right to test role-tailored dashboards.',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Right Login & Persona Selector Form
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(36.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In to Al Rabee ERP',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter credentials or click any demo persona below',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),

                            // Quick Demo Personas
                            Text(
                              'QUICK DEMO PERSONAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildPersonaChip('Super Admin', UserRole.superAdmin, AppColors.primary),
                                _buildPersonaChip('Store Manager', UserRole.manager, AppColors.oceanBlue),
                                _buildPersonaChip('Sales Staff', UserRole.salesStaff, AppColors.pistachio),
                                _buildPersonaChip('Inventory Mgr', UserRole.inventoryManager, AppColors.warning),
                                _buildPersonaChip('Accountant', UserRole.accountant, AppColors.saffronGold),
                                _buildPersonaChip('HR Manager', UserRole.hrManager, AppColors.berryRose),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            const SizedBox(height: 20),

                            // Form Fields
                            const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, size: 20),
                                hintText: 'admin@alrabee.com',
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: AppTokens.buttonHeightLg,
                              child: ElevatedButton(
                                onPressed: () => _handleLogin(null),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppTokens.borderRadiusMd,
                                  ),
                                ),
                                child: const Text(
                                  'Launch Enterprise Workspace',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaChip(String label, UserRole role, Color color) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 6,
      ),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      onPressed: () => _handleLogin(role),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
