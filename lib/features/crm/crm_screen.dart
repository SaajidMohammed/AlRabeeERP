import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/stat_card.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/lead_model.dart';
import '../../providers/erp_provider.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  LeadStage? _selectedStageFilter; // null means 'All Stages'
  int _viewMode = 0; // 0: Responsive Deal Cards Grid/List, 1: Data Table View
  final Set<LeadStage> _collapsedStages = {};

  Color _getStageColor(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return AppColors.oceanBlue;
      case LeadStage.contacted:
        return const Color(0xFF06B6D4);
      case LeadStage.qualified:
        return const Color(0xFF8B5CF6);
      case LeadStage.proposal:
        return AppColors.saffronGold;
      case LeadStage.negotiation:
        return AppColors.warning;
      case LeadStage.won:
        return AppColors.success;
      case LeadStage.lost:
        return AppColors.berryRose;
    }
  }

  void _showAddEditLeadDialog(BuildContext context, {LeadModel? existingLead}) {
    final nameCtrl = TextEditingController(text: existingLead?.name ?? '');
    final companyCtrl = TextEditingController(text: existingLead?.company ?? '');
    final phoneCtrl = TextEditingController(text: existingLead?.phone ?? '');
    final emailCtrl = TextEditingController(text: existingLead?.email ?? '');
    final valueCtrl = TextEditingController(
        text: existingLead != null ? existingLead.estimatedValue.toInt().toString() : '250000');
    final notesCtrl = TextEditingController(text: existingLead?.notes ?? '');
    String source = existingLead?.source ?? 'Corporate Inquiry';
    String category = existingLead?.interestedCategory ?? 'Dates & Dry Fruits Hampers';
    String assignedTo = existingLead?.assignedTo ?? 'Zaid Ansari';
    LeadStage stage = existingLead?.stage ?? LeadStage.newLead;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.leaderboard_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  existingLead == null ? 'New CRM Lead & Deal' : 'Edit Deal Opportunity',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contact / Client Name *',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: companyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Company / Organization',
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Deal Value (₹) *',
                            prefixIcon: Icon(Icons.currency_rupee, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: source,
                          decoration: const InputDecoration(labelText: 'Lead Source'),
                          items: const [
                            DropdownMenuItem(value: 'Corporate Inquiry', child: Text('Corporate Inquiry')),
                            DropdownMenuItem(value: 'Website', child: Text('Website')),
                            DropdownMenuItem(value: 'Walk-in Boutique', child: Text('Walk-in Boutique')),
                            DropdownMenuItem(value: 'VIP Referral', child: Text('VIP Referral')),
                            DropdownMenuItem(value: 'Trade Fair / Expo', child: Text('Trade Fair')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => source = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Interested Category'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Dates & Dry Fruits Hampers', child: Text('Dates & Dry Fruits Hampers')),
                      DropdownMenuItem(
                          value: 'Ajwa & Medjool Luxury Boxes', child: Text('Ajwa & Medjool Luxury Boxes')),
                      DropdownMenuItem(
                          value: 'Mamra Almonds & Pistachio Crates', child: Text('Mamra Almonds & Pistachios')),
                      DropdownMenuItem(
                          value: 'Belgian Truffles & Chocolates', child: Text('Belgian Truffles & Chocolates')),
                      DropdownMenuItem(
                          value: 'Cold Storage Wholesale Consignment', child: Text('Wholesale Consignment')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<LeadStage>(
                          initialValue: stage,
                          decoration: const InputDecoration(labelText: 'Pipeline Stage'),
                          items: LeadStage.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStageColor(s),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s.label),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => stage = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: assignedTo,
                          decoration: const InputDecoration(labelText: 'Sales Executive'),
                          items: const [
                            DropdownMenuItem(value: 'Zaid Ansari', child: Text('Zaid Ansari')),
                            DropdownMenuItem(value: 'Hamza Khan', child: Text('Hamza Khan')),
                            DropdownMenuItem(value: 'Fatima Al-Sayed', child: Text('Fatima Al-Sayed')),
                            DropdownMenuItem(value: 'Omar Qureshi', child: Text('Omar Qureshi')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => assignedTo = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Inquiry & Customization Notes',
                      hintText: 'e.g. 500 gift boxes with gold foil logo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final lead = LeadModel(
                  id: existingLead?.id ?? 'LEAD-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  company: companyCtrl.text,
                  phone: phoneCtrl.text,
                  email: emailCtrl.text,
                  source: source,
                  estimatedValue: double.tryParse(valueCtrl.text) ?? 100000.0,
                  assignedTo: assignedTo,
                  stage: stage,
                  nextFollowUp: existingLead?.nextFollowUp ?? DateTime.now().add(const Duration(days: 2)),
                  notes: notesCtrl.text,
                  interestedCategory: category,
                );

                context.read<ErpProvider>().saveLead(lead, isNew: existingLead == null);
                Navigator.of(ctx).pop();
              },
              child: Text(existingLead == null ? 'Create Lead' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadDetailSheet(BuildContext context, LeadModel lead) {
    final erp = context.read<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final currentLead = erp.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: AppTokens.shadowLg,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentLead.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStageColor(currentLead.stage).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getStageColor(currentLead.stage),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  currentLead.stage.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: _getStageColor(currentLead.stage),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (currentLead.company.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              currentLead.company,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Deal',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showAddEditLeadDialog(context, existingLead: currentLead);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
                const SizedBox(height: 14),

                // Pipeline Stage Progress (Wrapped, Zero Horizontal Scroll)
                Text(
                  'PIPELINE STAGE PROGRESSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: LeadStage.values.map((stage) {
                    final isCurrent = currentLead.stage == stage;
                    final isPast = currentLead.stage.index > stage.index;
                    final color = _getStageColor(stage);

                    return InkWell(
                      onTap: () {
                        erp.updateLeadStage(currentLead.id, stage);
                        setSheetState(() {});
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? color
                              : isPast
                                  ? color.withValues(alpha: 0.15)
                                  : (isDark ? AppColors.cardDark : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent || isPast
                                ? color
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPast)
                              Icon(Icons.check_circle, size: 14, color: color)
                            else if (isCurrent)
                              const Icon(Icons.radio_button_checked, size: 14, color: Colors.white)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  size: 14,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            const SizedBox(width: 6),
                            Text(
                              stage.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent
                                    ? Colors.white
                                    : isPast
                                        ? color
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Details Content
                Expanded(
                  child: ListView(
                    children: [
                      // Deal Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
                                borderRadius: AppTokens.borderRadiusMd,
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Value',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.currency(currentLead.estimatedValue),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
                                borderRadius: AppTokens.borderRadiusMd,
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned Executive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentLead.assignedTo,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Category & Source Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.category_outlined, size: 14, color: AppColors.onPrimaryContainer),
                                const SizedBox(width: 6),
                                Text(
                                  currentLead.interestedCategory,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.source_outlined, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Source: ${currentLead.source}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Contact Options
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.phone_rounded, color: AppColors.primary, size: 18),
                        ),
                        title: Text(currentLead.phone, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Primary Contact Number'),
                        trailing: OutlinedButton.icon(
                          icon: const Icon(Icons.call, size: 14),
                          label: const Text('Call'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${currentLead.name} (${currentLead.phone})...')),
                            );
                          },
                        ),
                      ),
                      if (currentLead.email.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE0F2FE),
                            child: Icon(Icons.email_outlined, color: AppColors.oceanBlue, size: 18),
                          ),
                          title: Text(currentLead.email, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Invoicing Email'),
                        ),

                      const SizedBox(height: 12),

                      // Notes Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : const Color(0xFFFFFBEB),
                          borderRadius: AppTokens.borderRadiusMd,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.notes_rounded, size: 16, color: AppColors.saffronGold),
                                SizedBox(width: 6),
                                Text(
                                  'Client Inquiry & Customization Notes',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentLead.notes.isNotEmpty
                                  ? currentLead.notes
                                  : 'No specific customization notes provided.',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                              label: const Text('Convert to Sale / POS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                context.go('/sales/new');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: 'Delete Lead',
                            onPressed: () {
                              erp.deleteLead(currentLead.id);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    // Filter leads by search & category
    final filteredLeads = erp.leads.where((l) {
      final matchesQuery = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.interestedCategory.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || l.interestedCategory == _selectedCategory;

      final matchesStage = _selectedStageFilter == null || l.stage == _selectedStageFilter;

      return matchesQuery && matchesCategory && matchesStage;
    }).toList();

    // CRM KPI calculations
    final totalPipelineValue = erp.leads
        .where((l) => l.stage != LeadStage.lost)
        .fold(0.0, (sum, l) => sum + l.estimatedValue);
    final wonDealsCount = erp.leads.where((l) => l.stage == LeadStage.won).length;
    final activeDealsCount = erp.leads
        .where((l) => l.stage != LeadStage.won && l.stage != LeadStage.lost)
        .length;
    final winRate = erp.leads.isNotEmpty ? ((wonDealsCount / erp.leads.length) * 100).toInt() : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CRM & Corporate Deals',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Corporate gift hampers, luxury dates consignments, tastings & institutional leads',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // Action Toolbar
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // View Mode Toggle (Vertical Cards / Table)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                      borderRadius: AppTokens.borderRadiusMd,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.grid_view_rounded, size: 18),
                          color: _viewMode == 0
                              ? AppColors.primary
                              : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          tooltip: 'Deal Cards View',
                          onPressed: () => setState(() => _viewMode = 0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.table_rows_rounded, size: 18),
                          color: _viewMode == 1
                              ? AppColors.primary
                              : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          tooltip: 'Table List View',
                          onPressed: () => setState(() => _viewMode = 1),
                        ),
                      ],
                    ),
                  ),

                  // New Lead Button
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditLeadDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Lead / Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CRM Metrics Overview (Vertical/Grid Responsive - Zero Horizontal Scroll)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1100;

              final cards = [
                StatCard(
                  title: 'Active Pipeline Value',
                  value: Formatters.compactCurrency(totalPipelineValue),
                  subtitle: '${erp.leads.length} total opportunities',
                  icon: Icons.monetization_on_rounded,
                  iconColor: AppColors.primary,
                ),
                StatCard(
                  title: 'Win Conversion Rate',
                  value: '$winRate%',
                  subtitle: '$wonDealsCount deals won',
                  icon: Icons.military_tech_rounded,
                  iconColor: AppColors.success,
                ),
                StatCard(
                  title: 'In-Flight Deals',
                  value: '$activeDealsCount',
                  subtitle: 'in proposals & negotiations',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.saffronGold,
                ),
                StatCard(
                  title: 'Top Demand Sector',
                  value: 'Luxury Hampers',
                  subtitle: 'Dates & Dry Fruits Gift Sets',
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.berryRose,
                ),
              ];

              if (isMobile) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: cards,
                );
              }

              if (isTablet) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: cards,
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[2]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[3]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Search and Filters Bar (Wrapped, Zero Horizontal Scroll)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final searchField = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isNarrow ? double.infinity : 280,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search client, company, deal...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              );

              final categoryFilter = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All',
                  'Dates & Dry Fruits Hampers',
                  'Ajwa & Medjool Luxury Boxes',
                  'Mamra Almonds & Pistachio Crates',
                  'Belgian Truffles & Chocolates',
                  'Cold Storage Wholesale Consignment',
                ].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat == 'All' ? 'All Categories' : cat),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    categoryFilter,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      searchField,
                      const SizedBox(width: 14),
                      Expanded(child: categoryFilter),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Pipeline Stage Quick Filter Chips (Zero Horizontal Scroll - Wrap Layout)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text('All Stages (${erp.leads.length})'),
                selected: _selectedStageFilter == null,
                onSelected: (_) => setState(() => _selectedStageFilter = null),
              ),
              ...LeadStage.values.map((stage) {
                final count = erp.leads.where((l) => l.stage == stage).length;
                final isSelected = _selectedStageFilter == stage;
                final color = _getStageColor(stage);

                return FilterChip(
                  avatar: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  label: Text('${stage.label} ($count)'),
                  selected: isSelected,
                  selectedColor: color.withValues(alpha: 0.2),
                  checkmarkColor: color,
                  onSelected: (_) => setState(() {
                    _selectedStageFilter = isSelected ? null : stage;
                  }),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Main View (Vertical Deal Feed vs. Table View)
          _viewMode == 0
              ? _buildVerticalDealsView(context, filteredLeads, isDark, isDesktop)
              : SizedBox(
                  height: 600,
                  child: _buildTableView(context, filteredLeads, isDark),
                ),
        ],
      ),
    );
  }

  /// Vertical Deal Feed: Displays grouped stages or selected stage cards vertically
  Widget _buildVerticalDealsView(
    BuildContext context,
    List<LeadModel> leads,
    bool isDark,
    bool isDesktop,
  ) {
    if (leads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 44,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              const SizedBox(height: 10),
              Text(
                'No deals match your search criteria',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If user selected a specific stage filter, render a responsive grid/list directly
    if (_selectedStageFilter != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);

          if (crossAxisCount == 1) {
            return Column(
              children: leads
                  .map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildDealCard(context, l, isDark),
                      ))
                  .toList(),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 1.9 : 1.7,
            ),
            itemCount: leads.length,
            itemBuilder: (context, idx) => _buildDealCard(context, leads[idx], isDark),
          );
        },
      );
    }

    // When viewing "All Stages", display vertical expandable stage sections
    final stagesWithLeads = LeadStage.values.where((stage) {
      return leads.any((l) => l.stage == stage);
    }).toList();

    return Column(
      children: stagesWithLeads.map((stage) {
        final stageLeads = leads.where((l) => l.stage == stage).toList();
        final stageValue = stageLeads.fold(0.0, (s, l) => s + l.estimatedValue);
        final color = _getStageColor(stage);
        final isCollapsed = _collapsedStages.contains(stage);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
            borderRadius: AppTokens.borderRadiusLg,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stage Section Header
              InkWell(
                onTap: () {
                  setState(() {
                    if (isCollapsed) {
                      _collapsedStages.remove(stage);
                    } else {
                      _collapsedStages.add(stage);
                    }
                  });
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCollapsed ? Icons.keyboard_arrow_right_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stage.label.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${stageLeads.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.currency(stageValue),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isCollapsed) ...[
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);

                      if (crossAxisCount == 1) {
                        return Column(
                          children: stageLeads
                              .map((l) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildDealCard(context, l, isDark),
                                  ))
                              .toList(),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isDesktop ? 1.9 : 1.7,
                        ),
                        itemCount: stageLeads.length,
                        itemBuilder: (context, idx) => _buildDealCard(context, stageLeads[idx], isDark),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Individual Deal Card
  Widget _buildDealCard(BuildContext context, LeadModel lead, bool isDark) {
    final erp = context.read<ErpProvider>();
    final stageColor = _getStageColor(lead.stage);

    return InkWell(
      onTap: () => _showLeadDetailSheet(context, lead),
      borderRadius: AppTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: AppTokens.borderRadiusMd,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: isDark ? [] : AppTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Client Name, Company & Stage Move Menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lead.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<LeadStage>(
                      tooltip: 'Change Stage',
                      icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      itemBuilder: (ctx) => LeadStage.values
                          .where((s) => s != lead.stage)
                          .map((s) => PopupMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStageColor(s),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Move to ${s.label}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ))
                          .toList(),
                      onSelected: (newStage) => erp.updateLeadStage(lead.id, newStage),
                    ),
                  ],
                ),
                if (lead.company.isNotEmpty)
                  Text(
                    lead.company,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),

                // Category & Stage Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: stageColor.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Text(
                        lead.stage.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: stageColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lead.interestedCategory,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom: Value & Sales Rep
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.currency(lead.estimatedValue),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lead.assignedTo.split(' ').first,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Table / List View
  Widget _buildTableView(BuildContext context, List<LeadModel> leads, bool isDark) {
    return ErpDataTable<LeadModel>(
      items: leads,
      searchPlaceholder: 'Search deals in table...',
      searchMatcher: (l, q) =>
          l.name.toLowerCase().contains(q) ||
          l.company.toLowerCase().contains(q) ||
          l.interestedCategory.toLowerCase().contains(q),
      onRowTap: (lead) => _showLeadDetailSheet(context, lead),
      columns: [
        ErpTableColumn(
          title: 'Client & Company',
          cellBuilder: (l) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (l.company.isNotEmpty)
                Text(
                  l.company,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
        ErpTableColumn(
          title: 'Category',
          cellBuilder: (l) => Text(l.interestedCategory, style: const TextStyle(fontSize: 12)),
        ),
        ErpTableColumn(
          title: 'Deal Value',
          isNumeric: true,
          cellBuilder: (l) => Text(
            Formatters.currency(l.estimatedValue),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        ErpTableColumn(
          title: 'Stage',
          cellBuilder: (l) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getStageColor(l.stage).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _getStageColor(l.stage), width: 1),
            ),
            child: Text(
              l.stage.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getStageColor(l.stage),
              ),
            ),
          ),
        ),
        ErpTableColumn(
          title: 'Sales Rep',
          cellBuilder: (l) => Text(l.assignedTo, style: const TextStyle(fontSize: 12)),
        ),
        ErpTableColumn(
          title: 'Source',
          cellBuilder: (l) => StatusBadge.gold(l.source),
        ),
      ],
    );
  }
}
