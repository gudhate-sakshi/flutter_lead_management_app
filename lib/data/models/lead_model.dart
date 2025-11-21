import '/core/constant/lead_status.dart';

class Lead {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String? notes;
  final LeadStatus status;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  Lead({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'status': status.displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdatedAt': lastUpdatedAt.millisecondsSinceEpoch,
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      notes: map['notes'] as String?,
      status: LeadStatusExtension.fromString(map['status'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'status': status.displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  Lead copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    LeadStatus? status,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}