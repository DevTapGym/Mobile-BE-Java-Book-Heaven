import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_event.dart';
import 'package:heaven_book_app/bloc/cart/cart_state.dart';
import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/model/cart_item.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/custom_circle_checkbox.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Calculate total price of selected items
  double _calculateTotalPrice(List<CartItem> cartItems) {
    return cartItems.fold<double>(0, (sum, item) {
      if (item.isSelected) {
        return sum + (item.unitPrice * item.quantity);
      }
      return sum;
    });
  }

  // Calculate total savings
  double _calculateTotalSavings(List<CartItem> cartItems) {
    return cartItems.fold<double>(0, (sum, item) {
      if (item.isSelected) {
        // Tính tiền tiết kiệm được từ sale
        final savings = (item.unitPrice * item.sale / 100) * item.quantity;
        return sum + savings;
      }
      return sum;
    });
  }

  // Show total price popup using BottomSheet
  void _showTotalPricePopup(BuildContext context, List<CartItem> cartItems) {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    final subtotal = _calculateTotalPrice(cartItems);
    final totalSavings = _calculateTotalSavings(cartItems);
    final shipping = 30000.0; // Fixed shipping cost
    final finalAmount = subtotal + shipping - totalSavings;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 48),
                  Text(
                    //'Order Summary',
                    'Tóm tắt đơn hàng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              // Main title
              Divider(),
              SizedBox(height: 4),
              // Subtitle
              Center(
                child: Text(
                  //'Please review your order before checkout (${selectedItems.length} items)',
                  'Vui lòng kiểm tra đơn hàng của bạn trước khi thanh toán (${selectedItems.length} sản phẩm)',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ),
              SizedBox(height: 18),

              // Order summary details với dữ liệu thật
              _buildSummaryRow('Tạm tính', FormatPrice.formatPrice(subtotal)),
              _buildSummaryRow(
                'Phí vận chuyển',
                FormatPrice.formatPrice(shipping),
              ),

              // Hiển thị discounts nếu có savings
              if (totalSavings > 0) ...[
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'Giảm giá:',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: _buildSummaryRow(
                    '- Giảm giá sản phẩm',
                    '-${FormatPrice.formatPrice(totalSavings)}',
                  ),
                ),
                SizedBox(height: 8),
                Divider(),
                _buildSummaryRow(
                  'Tổng tiết kiệm',
                  '-${FormatPrice.formatPrice(totalSavings)}',
                  isBold: true,
                ),
              ],

              // Final amount
              _buildSummaryRow(
                'Tổng cộng',
                FormatPrice.formatPrice(finalAmount),
                isBold: true,
              ),
              SizedBox(height: 18),

              // Checkout button
              Container(
                margin: EdgeInsets.only(bottom: 32),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedItems.isNotEmpty
                          ? () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, '/check-out');
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedItems.isNotEmpty
                            ? AppColors.primaryDark
                            : AppColors.primaryDark.withAlpha(125),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedItems.isNotEmpty
                        ?
                        //'Check out (${selectedItems.length} items)'
                        'Thanh toán (${selectedItems.length} sản phẩm)'
                        :
                        //'Select items to checkout',
                        'Chọn sản phẩm để thanh toán',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
              color: isBold ? AppColors.primaryDark : AppColors.black70,
              fontSize: isBold ? 17 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.primaryDark : AppColors.black70,
              fontSize: isBold ? 16 : 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CartLoaded) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 70,
              backgroundColor: AppColors.primary,
              automaticallyImplyLeading: false,
              title: Text(
                //'Shopping Cart (${state.cart.totalItems})',
                'Giỏ hàng (${state.cart.totalItems})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(color: AppColors.background),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartItemsSection(),
                    _buildRecommendedHeader(),
                    _buildRecommendedItemsGrid(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        } else if (state is CartError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Widget for the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded) {
          return const SizedBox.shrink();
        }

        final cartItems = state.cart.items;
        final hasSelected = cartItems.any((item) => item.isSelected);

        return Container(
          width: double.infinity,
          height: 100,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Row(
                children: [
                  CustomCircleCheckbox(
                    value: cartItems.every((item) => item.isSelected),
                    onChanged: (value) {
                      final List<int> allCartItemIds =
                          cartItems.map((item) => item.id).toList();

                      context.read<CartBloc>().add(
                        ToggleAllCartItemSelection(allCartItemIds, value!),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    //'All',
                    'Tất cả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap:
                    hasSelected
                        ? () => _showTotalPricePopup(context, cartItems)
                        : null, // ← Truyền cartItems
                child: Opacity(
                  opacity: hasSelected ? 1.0 : 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            FormatPrice.formatPrice(
                              _calculateTotalPrice(cartItems),
                            ), // ← Truyền cartItems
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                      Text(
                        //'Save ${FormatPrice.formatPrice(_calculateTotalSavings(cartItems))}', // ← Truyền cartItems
                        'Tiết kiệm ${FormatPrice.formatPrice(_calculateTotalSavings(cartItems))}', // ← Truyền cartItems
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: 140,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    if (hasSelected) {
                      Navigator.pushNamed(context, '/check-out');
                    }
                  },
                  child: Text(
                    //'Check out (${state.cart.items.where((item) => item.isSelected).length})', // ← Truyền cartItems
                    'Thanh toán (${cartItems.where((item) => item.isSelected).length})', // ← Truyền cartItems
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for the cart items section
  Widget _buildCartItemsSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CartLoaded) {
          final cartItems = state.cart.items;
          if (cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      //'Your cart is empty',
                      'Giỏ hàng của bạn trống',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      //'Looks like you haven\'t added anything yet.',
                      'Có vẻ như bạn chưa thêm gì vào giỏ hàng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item);
            },
          );
        } else if (state is CartError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Widget for a single cart item
  Widget _buildCartItem(CartItem items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, top: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            CustomCircleCheckbox(
              value: items.isSelected,
              onChanged: (value) {
                setState(() {
                  items.isSelected = value!;
                });

                context.read<CartBloc>().add(
                  ToggleCartItemSelection(items.id, items.isSelected),
                );
              },
            ),
            SizedBox(width: 10),
            Container(
              height: 160,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black60,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(8),
                ),
                child:
                    items.bookThumbnail.isNotEmpty
                        ? Image.network(
                          'http://10.0.2.2:8000${items.bookThumbnail}',
                          width: 100,
                          height: 160,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.book,
                                size: 60,
                                color: AppColors.primaryDark,
                              ),
                            );
                          },
                        )
                        : const Center(
                          child: Icon(
                            Icons.book,
                            size: 60,
                            color: AppColors.primaryDark,
                          ),
                        ),
              ),
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items.bookName,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'by ${items.bookAuthor}',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        Text(
                          FormatPrice.formatPrice(items.unitPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Row(
                          children: [
                            if (items.sale > 0)
                              Text(
                                FormatPrice.formatPrice(
                                  items.unitPrice * (1 + (items.sale / 100)),
                                ),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            SizedBox(width: 8),
                            if (items.sale > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.discountRed,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '-${items.sale.toInt()}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          //'In stock: ${items.inStock}',
                          'Còn hàng: ${items.inStock}',
                          style: TextStyle(
                            color: AppColors.black70,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 30),
                        Container(
                          height: 32,
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black54,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.remove, size: 18),
                                  onPressed:
                                      items.quantity > 1
                                          ? () {
                                            setState(() {
                                              items.quantity--;
                                            });
                                            context.read<CartBloc>().add(
                                              UpdateCartItemQuantity(
                                                items.id,
                                                items.quantity,
                                              ),
                                            );
                                          }
                                          : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  items.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.add, size: 18),
                                  onPressed:
                                      items.quantity < items.inStock
                                          ? () {
                                            setState(() {
                                              items.quantity++;
                                            });
                                            // Có thể gọi API cập nhật số lượng ở đây
                                            context.read<CartBloc>().add(
                                              UpdateCartItemQuantity(
                                                items.id,
                                                items.quantity,
                                              ),
                                            );
                                          }
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 50),
            Container(
              width: 100,
              height: 192,
              decoration: BoxDecoration(
                color: AppColors.discountRed,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white, size: 38),
                onPressed: () {
                  context.read<CartBloc>().add(RemoveCartItem(items.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        //'Item removed from cart'
                        'Sản phẩm đã được xóa khỏi giỏ hàng',
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the recommended items header
  Widget _buildRecommendedHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: Container(height: 2, color: AppColors.black60)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              //'You Might Also Like',
              'Bạn cũng có thể thích',
              style: TextStyle(
                color: AppColors.black60,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Container(height: 2, color: AppColors.black60)),
        ],
      ),
    );
  }

  // Widget for the recommended items grid
  Widget _buildRecommendedItemsGrid() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CartLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: state.relatedBooks.length,
              itemBuilder:
                  (context, index) =>
                      _buildRecommendedItem(state.relatedBooks[index]),
            ),
          );
        } else if (state is CartError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Widget for a single recommended item
  Widget _buildRecommendedItem(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: {'bookId': book.id});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        book.thumbnail.isNotEmpty
                            ? Image.network(
                              'http://10.0.2.2:8000${book.thumbnail}',
                              width: double.infinity,
                              height: 170,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 60,
                                    color: AppColors.primaryDark,
                                  ),
                                );
                              },
                            )
                            : const Center(
                              child: Icon(
                                Icons.book,
                                size: 60,
                                color: AppColors.primaryDark,
                              ),
                            ),
                  ),
                ),
                if (book.saleOff > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${book.saleOff.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '5',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black70,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(
                          width: 12,
                          height: 16,
                          child: VerticalDivider(
                            color: AppColors.black70,
                            thickness: 1.5,
                          ),
                        ),
                        Text(
                          //'${book.sold} sold',
                          '${book.sold} đã bán',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      FormatPrice.formatPrice(book.price),
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
