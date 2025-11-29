import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateVNPayPaymentEvent extends PaymentEvent {
  final int amount;
  final String? bankCode;

  CreateVNPayPaymentEvent({required this.amount, this.bankCode});

  @override
  List<Object?> get props => [amount, bankCode];
}
