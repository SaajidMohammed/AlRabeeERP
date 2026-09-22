import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/audit_log_model.dart';
import '../../models/user_model.dart';
import '../../providers/erp_provider.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  int _tabIndex = 0;
  UserRole _selectedMatrixRole = UserRole.superAdmin;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                    'Administration & RBAC Security',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Role-based access control, security permissions, user profiles & audit logs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('System Users (${erp.users.length})'),
                selected: _tabIndex == 0,
                onSelected: (_) => setState(() => _tabIndex = 0),
              ),
              ChoiceChip(
                label: const Text('RBAC Permission Matrix'),
                selected: _tabIndex == 1,
                onSelected: (_) => setState(() => _tabIndex = 1),
              ),
              ChoiceChip(
                label: Text('Audit Trail (${erp.auditLogs.length})'),
                selected: _tabIndex == 2,
                onSelected: (_) => setState(() => _tabIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          SizedBox(
            height: 560,
            child: _buildCurrentTab(erp),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(ErpProvider erp) {
    switch (_tabIndex) {
      case 0:
        return ErpDataTable<UserModel>(
          items: erp.users,
          searchPlaceholder: 'Search user name, email, department...',
          searchMatcher: (u, q) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.role.label.toLowerCase().contains(q),
          columns: [
            ErpTableColumn(
              title: 'User Profile',
              cellBuilder: (u) => Row(
                children: [
                  CircleAvatar(radius: 16, backgroundImage: NetworkImage(u.avatarUrl)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(u.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            ErpTableColumn(
              title: 'Assigned Role',
              cellBuilder: (u) => StatusBadge.gold(u.role.label),
            ),
            ErpTableColumn(
              title: 'Department',
              cellBuilder: (u) => Text(u.department, style: const TextStyle(fontSize: 12)),
            ),
            ErpTableColumn(
              title: 'Last Active',
              cellBuilder: (u) => Text(Formatters.dateTime(u.lastLogin), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            ErpTableColumn(
              title: 'Status',
              cellBuilder: (u) => StatusBadge.success('Authorized'),
            ),
          ],
        );

      case 1:
        final permissions = UserModel.getPermissionsForRole(_selectedMatrixRole);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Selector Dropdown
            Row(
              children: [
                const Text('Select Role to Inspect: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                DropdownButton<UserRole>(
                  value: _selectedMatrixRole,
                  isDense: true,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  items: UserRole.values.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r.label));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMatrixRole = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Permission Matrix Table / Cards
            Expanded(
              child: SectionCard(
                isExpanded: true,
                title: 'Granular Access Matrix — ${_selectedMatrixRole.label}',
                subtitle: _selectedMatrixRole.description,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;

                    if (isMobile) {
                      return ListView.separated(
                        itemCount: permissions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final p = permissions[idx];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF8FAFC),
                              borderRadius: AppTokens.borderRadiusMd,
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildPermBadge('View', p.view),
                                    _buildPermBadge('Create', p.create),
                                    _buildPermBadge('Edit', p.edit),
                                    _buildPermBadge('Delete', p.delete),
                                    _buildPermBadge('Approve', p.approve),
                                    _buildPermBadge('Export', p.export),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return ListView.separated(
                      itemCount: permissions.length,
                      separatorBuilder: (_, _) => const Divider(height: 12),
                      itemBuilder: (context, idx) {
                        final p = permissions[idx];
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(p.module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Expanded(child: _buildPermCheck('View', p.view)),
                            Expanded(child: _buildPermCheck('Create', p.create)),
                            Expanded(child: _buildPermCheck('Edit', p.edit)),
                            Expanded(child: _buildPermCheck('Delete', p.delete)),
                            Expanded(child: _buildPermCheck('Approve', p.approve)),
                            Expanded(child: _buildPermCheck('Export', p.export)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );

      case 2:
      default:
        return ErpDataTable<AuditLogModel>(
          items: erp.auditLogs,
          searchPlaceholder: 'Search user, action, module...',
          searchMatcher: (l, q) =>
              l.user.toLowerCase().contains(q) ||
              l.action.toLowerCase().contains(q) ||
              l.module.toLowerCase().contains(q) ||
              l.details.toLowerCase().contains(q),
          columns: [
            ErpTableColumn(
              title: 'Timestamp',
              cellBuilder: (l) => Text(Formatters.dateTime(l.timestamp), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            ErpTableColumn(
              title: 'User & Role',
              cellBuilder: (l) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.user, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(l.role, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                ],
              ),
            ),
            ErpTableColumn(
              title: 'Action & Module',
              cellBuilder: (l) => StatusBadge.info('${l.module} • ${l.action}'),
            ),
            ErpTableColumn(
              title: 'Operation Details',
              cellBuilder: (l) => Text(l.details, style: const TextStyle(fontSize: 12)),
            ),
          ],
        );
    }
  }

  Widget _buildPermBadge(String label, bool isGranted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isGranted ? AppColors.success.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isGranted ? AppColors.success.withValues(alpha: 0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 13,
            color: isGranted ? AppColors.success : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isGranted ? FontWeight.bold : FontWeight.normal,
              color: isGranted ? AppColors.success : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermCheck(String label, bool isGranted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isGranted ? Icons.check_circle_rounded : Icons.cancel_outlined,
          size: 16,
          color: isGranted ? AppColors.success : Colors.grey.shade400,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isGranted ? null : Colors.grey,
            fontWeight: isGranted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
