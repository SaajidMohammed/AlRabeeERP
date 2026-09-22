enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  late('Late Arrival'),
  halfDay('Half Day'),
  leave('On Approved Leave');

  final String label;
  const AttendanceStatus(this.label);
}

enum LeaveStatus {
  pending('Pending Approval'),
  approved('Approved'),
  rejected('Rejected');

  final String label;
  const LeaveStatus(this.label);
}

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkIn;
  final String? checkOut;
  final AttendanceStatus status;
  final String notes;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.notes = '',
  });
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String leaveType; // 'Casual Leave', 'Sick Leave', 'Annual Vacation', 'Unpaid Leave'
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedOn;
  final String? actionBy;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    required this.appliedOn,
    this.actionBy,
  });

  LeaveRequest copyWith({
    LeaveStatus? status,
    String? actionBy,
  }) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      status: status ?? this.status,
      appliedOn: appliedOn,
      actionBy: actionBy ?? this.actionBy,
    );
  }
}

class EmployeeModel {
  final String id;
  final String employeeCode; // AR-EMP-104
  final String name;
  final String designation;
  final String department; // 'Retail Sales', 'Warehouse & Logistics', 'Procurement', 'Accounts & Finance', 'Executive'
  final String phone;
  final String email;
  final double basicSalary;
  final double allowances;
  final DateTime joiningDate;
  final bool isActive;
  final String shift; // 'Morning 9:00 - 18:00', 'Evening 13:00 - 22:00'
  final String avatarUrl;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.department,
    required this.phone,
    required this.email,
    required this.basicSalary,
    this.allowances = 5000,
    required this.joiningDate,
    this.isActive = true,
    this.shift = 'Morning 9:00 - 18:00',
    required this.avatarUrl,
  });

  double get grossSalary => basicSalary + allowances;
}
