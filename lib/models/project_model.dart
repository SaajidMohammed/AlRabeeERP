enum TaskStatus {
  todo('To Do'),
  inProgress('In Progress'),
  review('Under Review'),
  completed('Completed');

  final String label;
  const TaskStatus(this.label);
}

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  final String label;
  const TaskPriority(this.label);
}

class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assignedTo;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.priority,
    required this.dueDate,
  });

  ProjectTask copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
    DateTime? dueDate,
  }) {
    return ProjectTask(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String category; // 'Seasonal Campaign', 'Store Expansion', 'Import Logistics', 'Corporate Gifting'
  final String client;
  final String manager;
  final double progress; // 0.0 to 1.0
  final DateTime startDate;
  final DateTime deadline;
  final double budget;
  final String status; // 'In Progress', 'Completed', 'Planning', 'On Hold'
  final List<ProjectTask> tasks;

  ProjectModel({
    required this.id,
    required this.title,
    required this.category,
    required this.client,
    required this.manager,
    required this.progress,
    required this.startDate,
    required this.deadline,
    required this.budget,
    this.status = 'In Progress',
    List<ProjectTask>? tasks,
  }) : tasks = tasks ?? [];

  ProjectModel copyWith({
    double? progress,
    String? status,
    List<ProjectTask>? tasks,
  }) {
    return ProjectModel(
      id: id,
      title: title,
      category: category,
      client: client,
      manager: manager,
      progress: progress ?? this.progress,
      startDate: startDate,
      deadline: deadline,
      budget: budget,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }
}
