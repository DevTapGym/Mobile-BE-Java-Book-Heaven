import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_event.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_state.dart';
import 'package:heaven_book_app/services/promotion_service.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final PromotionService _service;

  PromotionBloc(this._service) : super(PromotionInitial()) {
    on<LoadPromotions>(_onLoadPromotions);
  }

  Future<void> _onLoadPromotions(
    LoadPromotions event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    try {
      final promotions = await _service.getAllPromotions();
      emit(PromotionLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }
}
