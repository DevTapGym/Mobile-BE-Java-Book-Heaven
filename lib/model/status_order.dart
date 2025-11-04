class StatusOrder {
  final int id;
  final String name;
  final int sequence;
  final String note;
  final DateTime timestamp;
  final String description;

  StatusOrder({
    required this.id,
    required this.name,
    required this.description,
    required this.sequence,
    required this.note,
    required this.timestamp,
  });

  factory StatusOrder.fromJson(Map<String, dynamic> json) {
    return StatusOrder(
      id: json['id'],
      name: json['status_name'],
      description: json['description'] ?? '',
      sequence: json['status_sequence'] ?? 0,
      note: json['note'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}
