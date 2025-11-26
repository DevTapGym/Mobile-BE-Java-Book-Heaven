import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/book.dart';

abstract class SuggestState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SuggestInitial extends SuggestState {}

class SuggestLoading extends SuggestState {}

class SuggestLoaded extends SuggestState {
  final List<Book> suggestions;

  SuggestLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class SuggestError extends SuggestState {
  final String message;

  SuggestError(this.message);

  @override
  List<Object?> get props => [message];
}
