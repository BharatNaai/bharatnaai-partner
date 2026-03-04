class ServiceOffering {
  final dynamic id;
  final String serviceName;
  final int durationMinutes;
  final String experience;
  final String serviceCost;
  final String? description;
  final String? status;
  final String? notes;

  ServiceOffering({
    this.id,
    required this.serviceName,
    required this.durationMinutes,
    required this.experience,
    required this.serviceCost,
    this.description,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'durationMinutes': durationMinutes,
      'experience': experience,
      'serviceCost': serviceCost,
      'description': description,
      'status': status,
    };
  }

  factory ServiceOffering.fromJson(Map<String, dynamic> json) {
    return ServiceOffering(
      id: json['id'],
      serviceName: json['serviceName'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      experience: json['experience']?.toString() ?? '0',
      serviceCost: json['serviceCost']?.toString() ?? '0',
      description: json['description'],
      status: json['status'],
    );
  }
}

/// Shared catalog of supported services for dropdowns.
const List<String> kServiceOptions = <String>[
  'Haircut',
  'Shaving',
  'Combo'
];

