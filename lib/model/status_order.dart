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
      name: json['status'] ?? '', // đổi status_name -> status
      description: json['label'] ?? '', // đổi description -> label
      sequence: 0, // JSON không có thứ tự
      note: json['note'] ?? '',
      timestamp: DateTime.now(), // JSON không có created_at
    );
  }
}
