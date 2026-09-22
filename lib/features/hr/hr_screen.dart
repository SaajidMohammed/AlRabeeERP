import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/hr_model.dart';
import '../../providers/erp_provider.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  int _tabIndex = 0;

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
                    'HR & Team Management',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Staff directory, daily boutique attendance, leave approvals & payroll summary',
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
                label: Text('Staff Directory (${erp.employees.length})'),
                selected: _tabIndex == 0,
                onSelected: (_) => setState(() => _tabIndex = 0),
              ),
              ChoiceChip(
                label: Text('Today\'s Attendance (${erp.attendance.length})'),
                selected: _tabIndex == 1,
                onSelected: (_) => setState(() => _tabIndex = 1),
              ),
              ChoiceChip(
                label: Text('Leave Requests (${erp.leaveRequests.length})'),
                selected: _tabIndex == 2,
                onSelected: (_) => setState(() => _tabIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          SizedBox(
            height: 560,
            child: _buildCurrentTabContent(erp),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(ErpProvider erp) {
    switch (_tabIndex) {
      case 0:
        return ErpDataTable<EmployeeModel>(
          items: erp.employees,
          searchPlaceholder: 'Search employee name, code, department...',
          searchMatcher: (e, q) =>
              e.name.toLowerCase().contains(q) ||
              e.employeeCode.toLowerCase().contains(q) ||
              e.department.toLowerCase().contains(q),
          columns: [
            ErpTableColumn(
              title: 'Employee',
              cellBuilder: (e) => Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(e.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(e.employeeCode, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            ErpTableColumn(
              title: 'Designation & Dept',
              cellBuilder: (e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.designation, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(e.department, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            ErpTableColumn(
              title: 'Shift Schedule',
              cellBuilder: (e) => Text(e.shift, style: const TextStyle(fontSize: 12)),
            ),
            ErpTableColumn(
              title: 'Gross Salary',
              isNumeric: true,
              cellBuilder: (e) => Text(Formatters.currency(e.grossSalary), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ErpTableColumn(
              title: 'Status',
              cellBuilder: (e) => StatusBadge.success('Active Staff'),
            ),
          ],
        );

      case 1:
        return ErpDataTable<AttendanceRecord>(
          items: erp.attendance,
          searchPlaceholder: 'Search employee...',
          searchMatcher: (a, q) => a.employeeName.toLowerCase().contains(q),
          columns: [
            ErpTableColumn(
              title: 'Employee Name',
              cellBuilder: (a) => Text(a.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ErpTableColumn(
              title: 'Date',
              cellBuilder: (a) => Text(Formatters.date(a.date)),
            ),
            ErpTableColumn(
              title: 'Check-In Time',
              cellBuilder: (a) => Text(a.checkIn, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            ErpTableColumn(
              title: 'Status',
              cellBuilder: (a) => StatusBadge.success(a.status.label),
            ),
          ],
        );

      case 2:
      default:
        return SectionCard(
          isExpanded: true,
          title: 'Staff Leave Applications',
          subtitle: 'Review vacation & medical leave requests',
          child: erp.leaveRequests.isEmpty
              ? const Center(child: Text('No active leave requests.'))
              : ListView.separated(
                  itemCount: erp.leaveRequests.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, idx) {
                    final req = erp.leaveRequests[idx];
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.saffronGold.withValues(alpha: 0.1),
                            borderRadius: AppTokens.borderRadiusMd,
                          ),
                          child: const Icon(Icons.event_note_rounded, size: 20, color: AppColors.saffronGold),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${req.employeeName} — ${req.leaveType} (${req.totalDays} Days)', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${Formatters.date(req.startDate)} to ${Formatters.date(req.endDate)} • Reason: ${req.reason}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        if (req.status == LeaveStatus.pending) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32)),
                            onPressed: () => erp.processLeaveRequest(req.id, LeaveStatus.rejected, 'HR Manager'),
                            child: const Text('Reject', style: TextStyle(fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 32)),
                            onPressed: () => erp.processLeaveRequest(req.id, LeaveStatus.approved, 'HR Manager'),
                            child: const Text('Approve', style: TextStyle(fontSize: 11)),
                          ),
                        ] else
                          StatusBadge.success(req.status.label),
                      ],
                    );
                  },
                ),
        );
    }
  }
}
