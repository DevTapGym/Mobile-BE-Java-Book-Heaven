import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/model/book.dart';
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
    on<LoadProductTypeBooks>(_onLoadProductTypeBooks);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final bestSellingBooks =
          (await bookService.getBestSellingBooksInYear())
              .where((book) => book.isActive)
              .toList();
      final allBooks =
          (await bookService.getAllBooks())
              .where((book) => book.isActive)
              .toList();
      final popularBooks =
          allBooks.where((book) => book.categories != null).toList();
      final saleOffBooks =
          allBooks.where((book) => book.categories == null).toList();

      final bannerBooks = allBooks;
      final randomBooks = [...allBooks]..shuffle();

      emit(
        BookLoaded(
          popularBooks: popularBooks.take(10).toList(),
          saleOffBooks: saleOffBooks.take(10).toList(),
          bestSellingBooks: bestSellingBooks.take(3).toList(),
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
      final searchResults =
          (await bookService.searchBooks(
            event.query,
          )).where((book) => book.isActive).toList();
      emit(BookSearchLoaded(searchResults));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadProductTypeBooks(
    LoadProductTypeBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final categoryBooks =
          (await bookService.getBooksByProductType(
            event.productTypeName,
          )).where((book) => book.isActive).toList();
      emit(BookCategoryLoaded(categoryBooks));
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
      final categoryBooks =
          (await bookService.getBooksByCategory(
            event.categoryName,
          )).where((book) => book.isActive).toList();
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
      final allBooks =
          (await bookService.getAllBooks())
              .where((book) => book.isActive)
              .toList();
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
      List<Book> relatedBooks = [];

      // Nếu có category thì mới load sách liên quan
      if (bookDetail.categories != null) {
        relatedBooks =
            (await bookService.getBooksByCategory(
              bookDetail.categories!.name,
            )).where((book) => book.isActive).toList();
      } else {
        relatedBooks =
            (await bookService.getBooksByProductType(
              bookDetail.productTypes!.name,
            )).where((book) => book.isActive).toList();
      }
      emit(BookDetailLoaded(book: bookDetail, relatedBooks: relatedBooks));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }
}
