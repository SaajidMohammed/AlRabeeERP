enum LeadStage {
  newLead('New', 'Newly captured prospect'),
  contacted('Contacted', 'Initial outreach made'),
  qualified('Qualified', 'Requirements and budget verified'),
  proposal('Proposal', 'Custom quotation sent'),
  negotiation('Negotiation', 'Pricing and terms in review'),
  won('Won', 'Converted to Active Customer'),
  lost('Lost', 'Deal not materialized');

  final String label;
  final String description;
  const LeadStage(this.label, this.description);
}

class LeadModel {
  final String id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String source; // 'Website', 'Referral', 'Walk-in', 'Corporate Inquiry', 'Trade Fair'
  final double estimatedValue;
  final String assignedTo;
  final LeadStage stage;
  final DateTime nextFollowUp;
  final String notes;
  final String interestedCategory;
  final DateTime createdAt;

  LeadModel({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.source,
    required this.estimatedValue,
    required this.assignedTo,
    required this.stage,
    required this.nextFollowUp,
    this.notes = '',
    required this.interestedCategory,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LeadModel copyWith({
    String? name,
    String? company,
    String? phone,
    String? email,
    String? source,
    double? estimatedValue,
    String? assignedTo,
    LeadStage? stage,
    DateTime? nextFollowUp,
    String? notes,
    String? interestedCategory,
  }) {
    return LeadModel(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      assignedTo: assignedTo ?? this.assignedTo,
      stage: stage ?? this.stage,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      notes: notes ?? this.notes,
      interestedCategory: interestedCategory ?? this.interestedCategory,
      createdAt: createdAt,
    );
  }
}
