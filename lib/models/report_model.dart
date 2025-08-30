// models/report_model.dart
class Report {
  final String? id;
  final String type;
  final String description;
  final String location;
  final String? imageUrl;
  final bool legalAgreementAccepted;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final String? adminNotes;
  final String priority;
  final DateTime? estimatedFixTime;
  final String? assignedTechnician;
  final String? contactPhone;
  final String? contactEmail;

  Report({
    this.id,
    required this.type,
    required this.description,
    required this.location,
    this.imageUrl,
    required this.legalAgreementAccepted,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.userId,
    this.adminNotes,
    this.priority = 'medium',
    this.estimatedFixTime,
    this.assignedTechnician,
    this.contactPhone,
    this.contactEmail,
  });

  // إنشاء Report من Map (من Supabase)
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'],
      legalAgreementAccepted: map['legal_agreement_accepted'] ?? false,
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
      userId: map['user_id'],
      adminNotes: map['admin_notes'],
      priority: map['priority'] ?? 'medium',
      estimatedFixTime: map['estimated_fix_time'] != null 
          ? DateTime.parse(map['estimated_fix_time']) 
          : null,
      assignedTechnician: map['assigned_technician'],
      contactPhone: map['contact_phone'],
      contactEmail: map['contact_email'],
    );
  }

  // تحويل Report إلى Map (لإرساله إلى Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'legal_agreement_accepted': legalAgreementAccepted,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'admin_notes': adminNotes,
      'priority': priority,
      'estimated_fix_time': estimatedFixTime?.toIso8601String(),
      'assigned_technician': assignedTechnician,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
    };
  }

  // نسخ Report مع تحديث بعض الحقول
  Report copyWith({
    String? id,
    String? type,
    String? description,
    String? location,
    String? imageUrl,
    bool? legalAgreementAccepted,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? adminNotes,
    String? priority,
    DateTime? estimatedFixTime,
    String? assignedTechnician,
    String? contactPhone,
    String? contactEmail,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      legalAgreementAccepted: legalAgreementAccepted ?? this.legalAgreementAccepted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      adminNotes: adminNotes ?? this.adminNotes,
      priority: priority ?? this.priority,
      estimatedFixTime: estimatedFixTime ?? this.estimatedFixTime,
      assignedTechnician: assignedTechnician ?? this.assignedTechnician,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }

  // تحويل الحالة إلى نص عربي
  String get statusText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // تحويل الأولوية إلى نص عربي
  String get priorityText {
    switch (priority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجلة';
      default:
        return priority;
    }
  }

  // تحويل الأولوية إلى لون
  int get priorityColor {
    switch (priority) {
      case 'low':
        return 0xFF4CAF50; // أخضر
      case 'medium':
        return 0xFFFF9800; // برتقالي
      case 'high':
        return 0xFFFF5722; // أحمر
      case 'urgent':
        return 0xFFD32F2F; // أحمر داكن
      default:
        return 0xFF2196F3; // أزرق
    }
  }

  @override
  String toString() {
    return 'Report(id: $id, type: $type, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 