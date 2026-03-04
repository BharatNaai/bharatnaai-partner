class ServiceOffering {
  final String? id;
  final String serviceName;
  final int durationMinutes;
  final String experience;
  final String serviceCost;
  final String? notes;

  ServiceOffering({
    this.id,
    required this.serviceName,
    required this.durationMinutes,
    required this.experience,
    required this.serviceCost,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'durationMinutes': durationMinutes,
      'experience': experience,
      'serviceCost': serviceCost,
    };
  }

  factory ServiceOffering.fromJson(Map<String, dynamic> json) {
    return ServiceOffering(
      serviceName: json['serviceName'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      experience: json['experience'] ?? 0,
      serviceCost: json['serviceCost']?.toString() ?? '0',
    );
  }
}

/// Shared catalog of supported services for dropdowns.
const List<String> kServiceOptions = <String>[
  'HAIRCUT',
  'BEARD',
  'BASIC HAIRCUT',
  'KIDS HAIRCUT',
  'BEARD TRIM',
  'SHAVE',
  'HAIR COLOR',
  'HAIR STYLING',
  'HEAD MASSAGE',
  'FACIAL',
  'CLEANUP',
];

