import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../models/project_model.dart';
import '../../providers/erp_provider.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _selectedProjectIndex = 0;
  TaskStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (erp.projects.isEmpty) {
      return const Center(child: Text('No projects available.'));
    }

    final activeProject = erp.projects[_selectedProjectIndex.clamp(0, erp.projects.length - 1)];
    final isDesktop = Responsive.isDesktop(context);

    final filteredTasks = _selectedStatusFilter == null
        ? activeProject.tasks
        : activeProject.tasks.where((t) => t.status == _selectedStatusFilter).toList();

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
                    'Projects & Expansion Initiatives',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Seasonal luxury gifting campaigns, cold storage logistics & new boutique launches',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project Selector Pills (Wrapped)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: erp.projects.asMap().entries.map((entry) {
              final idx = entry.key;
              final proj = entry.value;
              final isSelected = _selectedProjectIndex == idx;

              return ChoiceChip(
                label: Text('${proj.title} (${(proj.progress * 100).toInt()}%)'),
                selected: isSelected,
                avatar: isSelected ? const Icon(Icons.check_circle_rounded, size: 16) : null,
                onSelected: (_) => setState(() => _selectedProjectIndex = idx),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Active Project Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: AppTokens.borderRadiusLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge.gold(activeProject.category),
                              const SizedBox(width: 8),
                              StatusBadge.success(activeProject.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeProject.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(activeProject.progress * 100).toInt()}% Done',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lead: ${activeProject.manager} • Target Deadline: ${Formatters.date(activeProject.deadline)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: activeProject.progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.primary,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Task Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Task Deliverables (${filteredTasks.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              ChoiceChip(
                label: Text('All (${activeProject.tasks.length})'),
                selected: _selectedStatusFilter == null,
                onSelected: (_) => setState(() => _selectedStatusFilter = null),
              ),
              ...TaskStatus.values.map((s) {
                final count = activeProject.tasks.where((t) => t.status == s).length;
                return ChoiceChip(
                  label: Text('${s.label} ($count)'),
                  selected: _selectedStatusFilter == s,
                  onSelected: (_) => setState(() => _selectedStatusFilter = _selectedStatusFilter == s ? null : s),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Vertical Responsive Tasks Grid / List
          filteredTasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No tasks found for this filter.',
                      style: TextStyle(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
                    if (cols == 1) {
                      return Column(
                        children: filteredTasks
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildTaskCard(t, activeProject, erp, isDark),
                                ))
                            .toList(),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: cols == 3 ? 1.8 : 2.0,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredTasks.length,
                      itemBuilder: (ctx, i) => _buildTaskCard(filteredTasks[i], activeProject, erp, isDark),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    ProjectTask t,
    ProjectModel activeProject,
    ErpProvider erp,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(t.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t.status.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(t.status),
                  ),
                ),
              ),
              PopupMenuButton<TaskStatus>(
                icon: const Icon(Icons.more_vert, size: 18),
                itemBuilder: (ctx) => TaskStatus.values
                    .where((s) => s != t.status)
                    .map((s) => PopupMenuItem(
                          value: s,
                          child: Text('Move to ${s.label}', style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onSelected: (newStatus) => erp.updateTaskStatus(activeProject.id, t.id, newStatus),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    t.assignedTo,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.shortDate(t.dueDate),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.inProgress:
        return AppColors.info;
      case TaskStatus.review:
        return Colors.purple;
      case TaskStatus.todo:
        return Colors.orange;
    }
  }
}
