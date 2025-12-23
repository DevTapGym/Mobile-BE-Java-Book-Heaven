import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_event.dart';
import 'package:heaven_book_app/bloc/book/book_state.dart';
import 'package:heaven_book_app/bloc/category/category_bloc.dart';
import 'package:heaven_book_app/bloc/category/category_state.dart';
import 'package:heaven_book_app/bloc/product_type/product_type_bloc.dart';
import 'package:heaven_book_app/bloc/product_type/product_type_state.dart';
import 'package:heaven_book_app/interceptors/app_session.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/themes/format_price.dart';

class ResultScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? sectionTitle;

  const ResultScreen({
    super.key,
    this.searchQuery,
    this.category,
    this.sectionTitle,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _selectedSortOption = 'Phổ biến';
  String _selectedViewType = 'grid';
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;
  String _selectedProductType = 'All';
  String _selectedCategory = 'All';
  bool _categoryInitialized = false;

  final List<String> _sortOptions = [
    'Phổ biến',
    'Giá: Thấp đến Cao',
    'Giá: Cao đến Thấp',
    'Mới nhất',
    'Tên A-Z',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _selectedCategory = widget.category ?? 'All';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      // CategoryBloc đã được provide từ HomeScreen, không cần load lại

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        final type = args['type'];
        final query = args['query'];

        if (type == 'search' && query != null) {
          context.read<BookBloc>().add(LoadSearchBooks(query));
        } else if (type == 'filter' && query != null) {
          context.read<BookBloc>().add(LoadProductTypeBooks(query));
        } else {
          context.read<BookBloc>().add(LoadAllBooks());
        }
      } else {
        context.read<BookBloc>().add(LoadAllBooks());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPageTitle() {
    if (widget.searchQuery?.isNotEmpty == true) {
      //return 'Search Results';
      return 'Kết quả tìm kiếm';
    } else if (widget.category != null) {
      return widget.category!;
    } else if (widget.sectionTitle != null) {
      return widget.sectionTitle!;
    } else if (_selectedCategory != 'All') {
      return _selectedCategory;
    }
    //return 'Books';
    return 'Sách';
  }

  String _getPageSubtitle() {
    if (widget.searchQuery?.isNotEmpty == true) {
      //return 'for "${widget.searchQuery}"';
      return 'Kết quả cho "${widget.searchQuery}"';
    } else if (widget.category != null) {
      //return 'books found';
      return 'Sách được tìm thấy';
    } else if (_selectedCategory != 'All') {
      //return 'Books in this category';
      return 'Sách trong danh mục này';
    }
    //return 'Books available';
    return 'Sách có sẵn';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<BookBloc>().add(LoadBooks());
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<BookBloc>().add(LoadBooks());
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPageTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getPageSubtitle(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _selectedViewType == 'grid' ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedViewType =
                      _selectedViewType == 'grid' ? 'list' : 'grid';
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilterBar(),

            // Results
            Expanded(
              child: BlocBuilder<BookBloc, BookState>(
                builder: (context, state) {
                  if (state is BookLoading) {
                    return _buildLoadingWidget();
                  } else if (state is BookSearchLoaded) {
                    final books = state.searchResults;
                    return _buildBooksResult(books);
                  } else if (state is BookLoadAll) {
                    final books = state.allBooks;
                    return _buildBooksResult(books);
                  } else if (state is BookCategoryLoaded) {
                    final books = state.categoryBooks;
                    return _buildBooksResult(books);
                  } else if (state is BookError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading books',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildLoadingWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksResult(List<Book> books) {
    // Filter books based on search query
    List<Book> filteredBooks = books;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredBooks =
          books.where((book) {
            return book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query) ||
                (book.description?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    // Sort books
    _sortBooks(filteredBooks);

    if (filteredBooks.isEmpty) {
      return _buildEmptyWidget();
    }

    return _selectedViewType == 'grid'
        ? _buildGridView(filteredBooks)
        : _buildListView(filteredBooks);
  }

  void _sortBooks(List<Book> books) {
    switch (_selectedSortOption) {
      case 'Giá: Thấp đến Cao':
        books.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá: Cao đến Thấp':
        books.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Mới nhất':
        // Simulate newest first (using id as proxy)
        books.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'Tên A-Z':
        books.sort((a, b) => a.title.compareTo(b.title));
        break;
      default: // Phổ biến
        books.sort((a, b) => b.sold.compareTo(a.sold));
        break;
    }
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                //hintText: 'Search books, authors, categories...',
                hintText: 'Tìm kiếm sách, tác giả, danh mục...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryDark,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          const SizedBox(height: 12),

          // Product Type and Sort Row
          Row(
            children: [
              // Product Type Filter
              Expanded(
                flex: 5,
                child: BlocBuilder<ProductTypeBloc, ProductTypeState>(
                  builder: (context, state) {
                    List<String> productTypeNames = ['All'];

                    if (state is ProductTypeLoaded) {
                      productTypeNames.addAll(
                        state.productTypes
                            .map((productType) => productType.name)
                            .toList(),
                      );

                      // Kiểm tra xem có cần cập nhật selected product type từ arguments không
                      final args =
                          ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>?;
                      if (args != null &&
                          args['type'] == 'filter' &&
                          args['query'] != null &&
                          !_categoryInitialized) {
                        final productTypeName = args['query'] as String;
                        final matchedProductTypes = state.productTypes.where(
                          (pt) => pt.name == productTypeName,
                        );
                        final matchedProductType =
                            matchedProductTypes.isNotEmpty
                                ? matchedProductTypes.first
                                : null;
                        if (matchedProductType != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _selectedProductType = matchedProductType.name;
                                _categoryInitialized = true;
                              });
                            }
                          });
                        }
                      }
                    }

                    // Chỉ reset về 'All' nếu _selectedProductType thực sự không hợp lệ
                    if (!productTypeNames.contains(_selectedProductType) &&
                        state is ProductTypeLoaded &&
                        _categoryInitialized) {
                      _selectedProductType = 'All';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedProductType,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          items:
                              productTypeNames.map((productType) {
                                return DropdownMenuItem(
                                  value: productType,
                                  child: Text(
                                    productType,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProductType = value!;
                              _selectedCategory =
                                  'All'; // Reset category khi đổi product type
                              _categoryInitialized = true;

                              // Thực hiện filtering theo product type
                              if (_selectedProductType == 'All') {
                                // Load tất cả sách
                                context.read<BookBloc>().add(LoadAllBooks());
                              } else {
                                // Load sách theo product type name
                                context.read<BookBloc>().add(
                                  LoadProductTypeBooks(_selectedProductType),
                                );
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Sort Filter
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSortOption,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.sort,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                      items:
                          _sortOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSortOption = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Category Filter (chỉ hiển thị khi chọn Product Type là "Sách")
          if (_selectedProductType == 'Sách') ...[
            const SizedBox(height: 12),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                List<String> categoryNames = ['All'];

                if (state is CategoryLoaded) {
                  categoryNames.addAll(
                    state.categories.map((category) => category.name).toList(),
                  );
                }

                // Reset category về 'All' nếu không tồn tại
                if (!categoryNames.contains(_selectedCategory)) {
                  _selectedCategory = 'All';
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Thể loại:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                            items:
                                categoryNames.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;

                                // Thực hiện filtering theo category
                                if (_selectedCategory == 'All') {
                                  // Load lại theo product type
                                  context.read<BookBloc>().add(
                                    LoadProductTypeBooks(_selectedProductType),
                                  );
                                } else {
                                  // Load sách theo category name
                                  context.read<BookBloc>().add(
                                    LoadCategoryBooks(_selectedCategory),
                                  );
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading books...',
            style: TextStyle(fontSize: 16, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No books found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedProductType = 'All';
                  _selectedCategory = 'All';
                  // Load lại tất cả sách khi clear filters
                  context.read<BookBloc>().add(LoadAllBooks());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.52,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return _buildBookGridCard(books[index]);
        },
      ),
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookListCard(books[index]);
      },
    );
  }

  Widget _buildBookGridCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: {'bookId': book.id, 'from': 'result'},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Stack(
              children: [
                Container(
                  height: 160,
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
                              '${AppSession.baseUrlImg}${book.thumbnail}',
                              width: double.infinity,
                              height: 160,
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
                // Discount Badge
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
                // Favorite Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Book Info
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
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '4.5', // Since Book model doesn't have rating, using placeholder
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 1,
                          height: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${book.sold} sold',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          FormatPrice.formatPrice(book.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        if (book.saleOff > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              FormatPrice.formatPrice(
                                book.price * (1 + book.saleOff / 100),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildBookListCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: {'bookId': book.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book Cover
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        book.thumbnail.isNotEmpty
                            ? Image.network(
                              '${AppSession.baseUrlImg}${book.thumbnail}',
                              width: 100,
                              height: 160,
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
                                    size: 40,
                                    color: AppColors.primaryDark,
                                  ),
                                );
                              },
                            )
                            : const Center(
                              child: Icon(
                                Icons.book,
                                size: 40,
                                color: AppColors.primaryDark,
                              ),
                            ),
                  ),
                ),
                if (book.saleOff > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
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

            const SizedBox(width: 12),

            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.description ?? 'No description',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.5 (${book.sold})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Container(width: 1, height: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${book.sold} sold',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        FormatPrice.formatPrice(
                          book.price * (1 - book.saleOff / 100),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      if (book.saleOff > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            FormatPrice.formatPrice(book.price),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
