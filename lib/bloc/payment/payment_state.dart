import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/vn_pay_payment_method.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final VnPayPaymentMethod response;

  PaymentSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
