import 'package:equatable/equatable.dart';

abstract class SuggestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSuggests extends SuggestEvent {
  final String position;
  LoadSuggests(this.position);
}

class FeedbackSuggest extends SuggestEvent {
  final int action;
  final String position;
  final String evenType;

  FeedbackSuggest({
    required this.action,
    required this.position,
    required this.evenType,
  });

  @override
  List<Object?> get props => [action, position, evenType];
}
