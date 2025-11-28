class VnPayPaymentMethod {
  final String code;
  final String message;
  final String paymentUrl;

  VnPayPaymentMethod({
    required this.code,
    required this.message,
    required this.paymentUrl,
  });

  factory VnPayPaymentMethod.fromJson(Map<String, dynamic> json) {
    return VnPayPaymentMethod(
      code: json["code"] ?? "",
      message: json["message"] ?? "",
      paymentUrl: json["paymentUrl"] ?? "",
    );
  }
}
