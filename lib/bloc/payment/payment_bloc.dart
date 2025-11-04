import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/payment/payment_event.dart';
import 'package:heaven_book_app/bloc/payment/payment_state.dart';
import 'package:heaven_book_app/services/payment_service.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _service;

  PaymentBloc(this._service) : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final payments = await _service.getPaymentMethods();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
