import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/suggest/suggest_event.dart';
import 'package:heaven_book_app/bloc/suggest/suggest_state.dart';
import 'package:heaven_book_app/interceptors/app_session.dart';
import 'package:heaven_book_app/services/suggest_service.dart';

class SuggestBloc extends Bloc<SuggestEvent, SuggestState> {
  final SuggestService _service;

  SuggestBloc(this._service) : super(SuggestInitial()) {
    on<LoadSuggests>(_onLoadSuggestions);
    on<FeedbackSuggest>(_onFeedbackSuggest);
  }

  Future<void> _onLoadSuggestions(
    LoadSuggests event,
    Emitter<SuggestState> emit,
  ) async {
    emit(SuggestLoading());
    try {
      final suggestions = await _service.getSuggestions(
        customerId: AppSession().currentUser!.customer!.id,
        position: event.position,
      );
      emit(SuggestLoaded(suggestions: suggestions));
    } catch (e) {
      emit(SuggestError(e.toString()));
    }
  }

  Future<void> _onFeedbackSuggest(
    FeedbackSuggest event,
    Emitter<SuggestState> emit,
  ) async {
    try {
      await _service.feedback(
        customerId: AppSession().currentUser!.customer!.id,
        action: event.action,
        position: event.position,
        evenType: event.evenType,
      );
    } catch (e) {
      emit(SuggestError(e.toString()));
    }
  }
}
