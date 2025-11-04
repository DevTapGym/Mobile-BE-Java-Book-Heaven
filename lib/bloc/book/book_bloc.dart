import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_event.dart';
import 'book_state.dart';
import '../../services/book_service.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookService bookService;

  BookBloc(this.bookService) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadSearchBooks>(_onLoadSearchBooks);
    on<LoadCategoryBooks>(_onLoadCategoryBooks);
    on<LoadAllBooks>(_onLoadAllBooks);
    on<LoadBookDetail>(_onLoadBookDetail);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final popularBooks = await bookService.getPopularBooks();
      final saleOffBooks = await bookService.getSaleOffBooks();
      final bestSellingBooks = await bookService.getBestSellingBooksInYear();
      final bannerBooks = await bookService.getBannerBooks();
      final randomBooks = await bookService.getRandomBooks();
      emit(
        BookLoaded(
          popularBooks: popularBooks,
          saleOffBooks: saleOffBooks,
          bestSellingBooks: bestSellingBooks,
          bannerBooks: bannerBooks,
          randomBooks: randomBooks,
        ),
      );
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadSearchBooks(
    LoadSearchBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final searchResults = await bookService.searchBooks(event.query);
      emit(BookSearchLoaded(searchResults));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryBooks(
    LoadCategoryBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final categoryBooks = await bookService.getBooksByCategory(
        event.categoryId,
      );
      emit(BookCategoryLoaded(categoryBooks));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadAllBooks(
    LoadAllBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final allBooks = await bookService.getAllBooks();
      emit(BookLoadAll(allBooks));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadBookDetail(
    LoadBookDetail event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final bookDetail = await bookService.getBookDetail(event.id);
      final relatedBooks = await bookService.getBooksByCategory(
        bookDetail.categories.first.id,
      );
      relatedBooks.removeWhere((book) => book.id == bookDetail.id);

      emit(BookDetailLoaded(book: bookDetail, relatedBooks: relatedBooks));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }
}
