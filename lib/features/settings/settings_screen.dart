import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../providers/theme_provider.dart';
import '../../providers/erp_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _companyNameCtrl = TextEditingController(text: 'Al Rabee Gourmet Delicacies Pvt Ltd');
  final TextEditingController _gstinCtrl = TextEditingController(text: '27AABCA1234F1Z1');
  final TextEditingController _currencyCtrl = TextEditingController(text: 'INR (₹)');
  final TextEditingController _defaultTaxCtrl = TextEditingController(text: '5.0%');

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _gstinCtrl.dispose();
    _currencyCtrl.dispose();
    _defaultTaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ERP System Configuration',
                style: (isDesktop
                        ? Theme.of(context).textTheme.headlineMedium
                        : Theme.of(context).textTheme.titleLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Enterprise identity, tax compliance parameters, retail branches & appearance',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appearance Theme Mode Card
          SectionCard(
            title: 'Visual Theme & Appearance',
            subtitle: 'Toggle between sophisticated dark mode and crisp executive light mode',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;
                final opt1 = _buildThemeOption(
                  context,
                  title: 'Light Theme',
                  icon: Icons.light_mode_rounded,
                  isSelected: !themeProvider.isDark,
                  onTap: () {
                    if (themeProvider.isDark) themeProvider.toggleTheme();
                  },
                );
                final opt2 = _buildThemeOption(
                  context,
                  title: 'Dark Slate Theme',
                  icon: Icons.dark_mode_rounded,
                  isSelected: themeProvider.isDark,
                  onTap: () {
                    if (!themeProvider.isDark) themeProvider.toggleTheme();
                  },
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      opt1,
                      const SizedBox(height: 10),
                      opt2,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: opt1),
                    const SizedBox(width: 14),
                    Expanded(child: opt2),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Company Profile Section
          SectionCard(
            title: 'Al Rabee Legal Profile & Invoicing Details',
            subtitle: 'Printed on tax invoices, delivery challans and purchase receipts',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;
                return Column(
                  children: [
                    TextField(
                      controller: _companyNameCtrl,
                      decoration: const InputDecoration(labelText: 'Registered Legal Entity Name'),
                    ),
                    const SizedBox(height: 12),
                    if (isNarrow) ...[
                      TextField(
                        controller: _gstinCtrl,
                        decoration: const InputDecoration(labelText: 'GSTIN Number (State: 27 Maharashtra)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _currencyCtrl,
                        decoration: const InputDecoration(labelText: 'Base Currency Symbol'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _gstinCtrl,
                              decoration: const InputDecoration(labelText: 'GSTIN Number (State: 27 Maharashtra)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _currencyCtrl,
                              decoration: const InputDecoration(labelText: 'Base Currency Symbol'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Company profile configuration saved.')),
                          );
                        },
                        child: const Text('Save Profile Updates'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Retail & Cold Hub Locations
          SectionCard(
            title: 'Active Retail & Logistics Hubs',
            subtitle: 'Configured facilities and cold chain terminals',
            child: Column(
              children: erp.warehouses.map((wh) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusSm,
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: Text(wh.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(wh.location, style: Theme.of(context).textTheme.bodySmall),
                  trailing: StatusBadge.success(wh.isColdStorage ? 'Cold Storage Active' : 'Showroom Storage'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: AppTokens.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : null, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
