class ServiceOffering {
  final String id;
  final String name;
  final String averageTime;
  final String experience;
  final String cost;
  final String notes;

  ServiceOffering({
    required this.id,
    required this.name,
    required this.averageTime,
    required this.experience,
    required this.cost,
    required this.notes,
  });
}

/// Shared catalog of supported services for dropdowns.
const List<String> kServiceOptions = <String>[
  'Basic Haircut',
  'Kids Haircut',
  'Beard Trim',
  'Shave',
  'Hair Color',
  'Hair Styling',
  'Head Massage',
  'Facial',
  'Cleanup',
];
