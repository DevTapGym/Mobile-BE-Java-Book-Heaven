import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/payment/payment_event.dart';
import 'package:heaven_book_app/bloc/payment/payment_state.dart';
import 'package:heaven_book_app/services/payment_service.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;

  PaymentBloc(this._paymentService) : super(PaymentInitial()) {
    on<CreateVNPayPaymentEvent>(_createVNPayPayment);
  }

  Future<void> _createVNPayPayment(
    CreateVNPayPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final res = await _paymentService.createVnPayPayment(
        amount: event.amount,
        bankCode: event.bankCode,
      );
      emit(PaymentSuccess(res));
    } catch (e) {
      emit(PaymentError('Failed to create VNPay payment: $e'));
    }
  }
}
