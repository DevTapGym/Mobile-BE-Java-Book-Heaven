import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/services/book_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'package:heaven_book_app/services/cart_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;
  final BookService _bookService;

  CartBloc(this._cartService, this._bookService) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<AddToCart>(_onAddToCart);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<ToggleCartItemSelection>(_onToggleCartItemSelection);
    on<ToggleAllCartItemSelection>(_onToggleAllCartItemSelection);
  }

  Future<void> _onToggleAllCartItemSelection(
    ToggleAllCartItemSelection event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoading());
      try {
        for (var id in event.cartItemId) {
          await _cartService.toggleCartItem(id, event.isSelected);
        }
        final updatedCart = await _cartService.getMyCart();
        emit(
          CartLoaded(
            cart: updatedCart,
            relatedBooks: currentState.relatedBooks,
          ),
        );
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onToggleCartItemSelection(
    ToggleCartItemSelection event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoading());
      try {
        await _cartService.toggleCartItem(event.cartItemId, event.isSelected);
        final updatedCart = await _cartService.getMyCart();
        emit(
          CartLoaded(
            cart: updatedCart,
            relatedBooks: currentState.relatedBooks,
          ),
        );
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartService.getMyCart();
      final relatedBooks = await _bookService.getAllBooks();

      // Lấy danh sách ID các sách trong giỏ
      final cartBookIds = cart.items.map((item) => item.bookId).toSet();

      // Lọc bỏ những sách có id trùng với trong giỏ
      final filteredRelatedBooks =
          relatedBooks.where((book) => !cartBookIds.contains(book.id)).toList();

      emit(CartLoaded(cart: cart, relatedBooks: filteredRelatedBooks));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoading());
      try {
        await _cartService.updateCartItemQuantity(
          event.cartItemId,
          event.newQuantity,
        );
        final updatedCart = await _cartService.getMyCart();
        emit(
          CartLoaded(
            cart: updatedCart,
            relatedBooks: currentState.relatedBooks,
          ),
        );
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoading());
      try {
        await _cartService.addToCart(event.bookId, event.quantity);
        final updatedCart = await _cartService.getMyCart();
        emit(
          CartLoaded(
            cart: updatedCart,
            relatedBooks: currentState.relatedBooks,
          ),
        );
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveCartItem(
    RemoveCartItem event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoading());
      try {
        await _cartService.removeCartItem(event.cartItemId);
        final updatedCart = await _cartService.getMyCart();
        emit(
          CartLoaded(
            cart: updatedCart,
            relatedBooks: currentState.relatedBooks,
          ),
        );
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }
}
