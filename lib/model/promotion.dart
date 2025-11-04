class Promotion {
  final int id;
  final String code;
  final String name;
  final bool status;
  final String promotionType;
  final double? promotionValue;
  final bool isMaxPromotionValue;
  final double? maxPromotionValue;
  final double? orderMinValue;
  final String? startDate;
  final String? endDate;
  final int? qtyLimit;
  final bool isOncePerCustomer;
  final String? note;

  Promotion({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.promotionType,
    required this.promotionValue,
    required this.isMaxPromotionValue,
    required this.maxPromotionValue,
    required this.orderMinValue,
    required this.startDate,
    required this.endDate,
    required this.qtyLimit,
    required this.isOncePerCustomer,
    required this.note,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      promotionType: json['promotionType'] ?? '',
      promotionValue:
          json['promotionValue'] != null
              ? double.tryParse(json['promotionValue'].toString())
              : null,
      isMaxPromotionValue: json['isMaxPromotionValue'] ?? false,
      maxPromotionValue:
          json['maxPromotionValue'] != null
              ? double.tryParse(json['maxPromotionValue'].toString())
              : null,
      orderMinValue:
          json['orderMinValue'] != null
              ? double.tryParse(json['orderMinValue'].toString())
              : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      qtyLimit: json['qtyLimit'],
      isOncePerCustomer: json['isOncePerCustomer'] ?? false,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      'promotionType': promotionType,
      'promotionValue': promotionValue,
      'isMaxPromotionValue': isMaxPromotionValue,
      'maxPromotionValue': maxPromotionValue,
      'orderMinValue': orderMinValue,
      'startDate': startDate,
      'endDate': endDate,
      'qtyLimit': qtyLimit,
      'isOncePerCustomer': isOncePerCustomer,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'Promotion{id: $id, code: $code, name: $name, status: $status, promotionType: $promotionType, promotionValue: $promotionValue, isMaxPromotionValue: $isMaxPromotionValue, maxPromotionValue: $maxPromotionValue, orderMinValue: $orderMinValue, startDate: $startDate, endDate: $endDate, qtyLimit: $qtyLimit, isOncePerCustomer: $isOncePerCustomer, note: $note}';
  }
}
