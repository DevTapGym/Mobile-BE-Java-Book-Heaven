import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_state.dart';
import 'package:heaven_book_app/bloc/cart/cart_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_event.dart';
import 'package:heaven_book_app/bloc/category/category_bloc.dart';
import 'package:heaven_book_app/bloc/category/category_event.dart';
import 'package:heaven_book_app/bloc/category/category_state.dart';
import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/model/category.dart';
import 'package:heaven_book_app/services/category_service.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import '../../widgets/book_section_widget.dart';
import 'result_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  final _categoryBloc = CategoryBloc(CategoryService());

  @override
  void initState() {
    super.initState();

    // Set up timer for auto-scrolling every 3 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_bannerController.hasClients) {
          if (_currentPage < 3) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _bannerController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });

    // Load dữ liệu

    _categoryBloc.add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _timer?.cancel();
    _categoryBloc.close();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoryBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),

              Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Banner Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildBanner(),
                    ),
                    const SizedBox(height: 24),

                    // Categories Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCategoriesSection(),
                    ),
                    const SizedBox(height: 24),

                    // Bestsellers This Year Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<BookBloc, BookState>(
                        builder: (context, state) {
                          if (state is BookLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is BookLoaded) {
                            return _buildBestsellersSection(
                              state.bestSellingBooks,
                            );
                          } else if (state is BookError) {
                            return Text('Lỗi: ${state.message}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recommended Books Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildRecommendedBooksSection(),
                    ),
                    const SizedBox(height: 24),
                    // Books on Sale Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<BookBloc, BookState>(
                        builder: (context, state) {
                          if (state is BookLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is BookLoaded) {
                            return BookSectionWidget(
                              //title: 'Books on Sale',
                              title: 'Sách Giảm Giá\nKhông Mua Đừng Tiếc Nhá',
                              books: state.saleOffBooks,
                              onViewAll: () {},
                              onBookTap: (book) {
                                Navigator.pushNamed(
                                  context,
                                  '/detail',
                                  arguments: {'bookId': book.id},
                                );
                              },
                            );
                          } else if (state is BookError) {
                            return Text('Lỗi: ${state.message}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Popular Books Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<BookBloc, BookState>(
                        builder: (context, state) {
                          if (state is BookLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is BookLoaded) {
                            return BookSectionWidget(
                              //title: 'Popular Books',
                              title: 'Xu Hướng Đọc Hiện Nay',
                              books: state.popularBooks,
                              onViewAll: () {},
                              onBookTap: (book) {
                                Navigator.pushNamed(
                                  context,
                                  '/detail',
                                  arguments: {'bookId': book.id},
                                );
                              },
                            );
                          } else if (state is BookError) {
                            return Text('Lỗi: ${state.message}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top + 12,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Book Heaven',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          //hintText: 'Search books...',
          hintText: 'Tìm sách bạn yêu thích...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryDark),
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider.value(
                          value: _categoryBloc,
                          child: const ResultScreen(),
                        ),
                    settings: RouteSettings(
                      arguments: {'type': 'search', 'query': query},
                    ),
                  ),
                );
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        List<Book> bannerBooks = [];

        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookLoaded) {
          try {
            bannerBooks = state.bannerBooks.take(4).toList();
          } catch (e) {
            bannerBooks = state.popularBooks.take(4).toList();
          }

          final List<Map<String, dynamic>> banners = [
            {
              'title': 'Sách mới mỗi ngày',
              'subtitle': 'Khám phá sách mới nào!',
              'icon': Icons.book,
              'gradient': const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigoAccent, Colors.indigo],
              ),
              'color': Colors.indigo,
              'book_id': bannerBooks.isNotEmpty ? bannerBooks[0].id : null,
              'books':
                  bannerBooks.isNotEmpty
                      ? 'http://10.0.2.2:8000${bannerBooks[0].thumbnail}'
                      : null,
            },
            {
              'title': 'Best Sellers 2025',
              'subtitle': 'Khám phá sách bán chạy',
              'icon': Icons.star,
              'gradient': const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple, Colors.deepPurple],
              ),
              'color': Colors.deepPurple,
              'book_id': bannerBooks.isNotEmpty ? bannerBooks[1].id : null,
              'books':
                  bannerBooks.length > 1
                      ? 'http://10.0.2.2:8000${bannerBooks[1].thumbnail}'
                      : null,
            },
            {
              'title': 'Mới nhập nóng hỏi',
              'subtitle': 'Cập nhật xu hướng mới',
              'icon': Icons.new_releases,
              'gradient': const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 25, 188, 31),
                  Color.fromARGB(255, 0, 150, 45),
                ],
              ),
              'color': Color.fromARGB(255, 0, 150, 45),
              'book_id': bannerBooks.isNotEmpty ? bannerBooks[2].id : null,
              'books':
                  bannerBooks.length > 2
                      ? 'http://10.0.2.2:8000${bannerBooks[2].thumbnail}'
                      : null,
            },
            {
              'title': 'Ưu đãi độc quyền',
              'subtitle': 'Săn ngay kẻo lỡ',
              'icon': Icons.local_offer,
              'gradient': const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange, Colors.deepOrange],
              ),
              'color': Colors.deepOrange,
              'book_id': bannerBooks.isNotEmpty ? bannerBooks[3].id : null,
              'books':
                  bannerBooks.length > 3
                      ? 'http://10.0.2.2:8000${bannerBooks[3].thumbnail}'
                      : null,
            },
          ];

          return SizedBox(
            height: 210,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: banner['gradient'] as LinearGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 40,
                            bottom: -30,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      banner['icon'] as IconData,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      banner['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      banner['subtitle'] as String,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (banner['book_id'] == null) return;
                                        Navigator.pushNamed(
                                          context,
                                          '/detail',
                                          arguments: {
                                            'bookId': banner['book_id'],
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: banner['color'],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        //'Explore Now',
                                        'Khám Phá Ngay',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Hình ảnh
                                Container(
                                  width: 112,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        bannerBooks.length > index &&
                                                bannerBooks[index]
                                                    .thumbnail
                                                    .isNotEmpty
                                            ? Image.network(
                                              banner['books']
                                                  as String, // URL đã được tạo sẵn
                                              width: 112,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                      ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Center(
                                                  child: Icon(
                                                    banner['icon'] as IconData,
                                                    size: 80,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                  ),
                                                );
                                              },
                                            )
                                            : Center(
                                              child: Icon(
                                                banner['icon'] as IconData,
                                                size: 80,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Dots indicator
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is BookError) {
          return Text('Lỗi: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoriesSection() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              //'Categories',
              'Thể Loại Sách',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 100, child: _buildCategoriesList(state)),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with personalized message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, Color.fromARGB(255, 173, 206, 255)],
              stops: [0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      //'Just for You',
                      'Chỉ mình bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      //'Personalized recommendations',
                      'Gợi ý rành\nriêng cho bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'AI Powered',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BookLoaded) {
              return SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.randomBooks.length,
                  padding: const EdgeInsets.only(right: 8),
                  itemBuilder: (context, index) {
                    final book = state.randomBooks[index];
                    return _buildRecommendedBookCard(book);
                  },
                ),
              );
            } else if (state is BookError) {
              return Text('Lỗi: ${state.message}');
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: {'bookId': book.id});
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover with discount badge
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.3),
                        AppColors.primaryDark.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child:
                      book.thumbnail.isNotEmpty
                          ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Center(
                              child: Image.network(
                                'http://10.0.2.2:8000${book.thumbnail}',
                                width: 120,
                                height: 160,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: double.infinity,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primaryDark.withValues(
                                            alpha: 0.3,
                                          ),
                                          AppColors.primaryDark.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primaryDark.withValues(
                                            alpha: 0.3,
                                          ),
                                          AppColors.primaryDark.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.book,
                                        size: 60,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          : Center(
                            child: Icon(
                              Icons.book,
                              size: 60,
                              color: AppColors.primaryDark,
                            ),
                          ),
                ),
                // Discount badge
                if (book.saleOff > 0) ...[
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
              ],
            ),

            // Book info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommendation reason
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.features.isNotEmpty
                              ? book.features.first.featureName
                              : 'Recommended',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Book title
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

                    // Author
                    Text(
                      'by ${book.author}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Rating and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FormatPrice.formatPrice(book.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              4.5.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ],
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

  Widget _buildBestsellersSection(List<Book> bestSellingBooks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with trophy design
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.amber.shade400, Colors.orange.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Bestsellers của năm',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        //'Top selling books in 2025',
                        'Những cuốn sách bán chạy nhất năm 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      //'Updated Daily',
                      'Cập nhật hàng ngày',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bestsellers List
        ...bestSellingBooks.asMap().entries.map((entry) {
          final index = entry.key;
          final book = entry.value;
          return _buildBestsellerCard(book, index + 1); // rank = index + 1
        }),
      ],
    );
  }

  Widget _buildBestsellerCard(Book book, int rank) {
    // Định nghĩa màu cho từng rank
    Color getColorForRank(int rank) {
      switch (rank) {
        case 1:
          return Colors.deepPurple;
        case 2:
          return Colors.pink;
        case 3:
          return Colors.orange;
        default:
          return AppColors.primaryDark;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: {'bookId': book.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: rank == 1 ? Colors.amber : Colors.grey.shade200,
            width: rank == 1 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  rank == 1
                      ? Colors.amber.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
              blurRadius: rank == 1 ? 15 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Book Cover
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          book.thumbnail.isNotEmpty
                              ? Image.network(
                                'http://10.0.2.2:8000${book.thumbnail}',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          getColorForRank(
                                            rank,
                                          ).withValues(alpha: 0.3),
                                          getColorForRank(
                                            rank,
                                          ).withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          getColorForRank(
                                            rank,
                                          ).withValues(alpha: 0.3),
                                          getColorForRank(
                                            rank,
                                          ).withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.menu_book,
                                        size: 40,
                                        color: getColorForRank(rank),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      getColorForRank(
                                        rank,
                                      ).withValues(alpha: 0.3),
                                      getColorForRank(
                                        rank,
                                      ).withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book,
                                    size: 40,
                                    color: getColorForRank(rank),
                                  ),
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Book Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Badge "HOT" cho top 3
                            if (rank <= 3)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: rank == 1 ? Colors.red : Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  rank == 1 ? 'HOT' : 'TOP $rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (rank <= 3) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '5.0 (${book.sold} sold)',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.red.shade400,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Best Seller',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hiển thị giá với logic sale off
                                if (book.saleOff > 0) ...[
                                  Text(
                                    FormatPrice.formatPrice(
                                      book.price * (1 + (book.saleOff / 100)),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    FormatPrice.formatPrice(book.price),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    FormatPrice.formatPrice(book.price),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<CartBloc>().add(
                                  AddToCart(bookId: book.id, quantity: 1),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${book.title} added to cart!',
                                    ),
                                    backgroundColor: AppColors.primaryDark,
                                  ),
                                );
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 20,
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

            // Rank Badge
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        rank == 1
                            ? [Colors.amber.shade400, Colors.orange.shade600]
                            : rank == 2
                            ? [Colors.grey.shade300, Colors.grey.shade500]
                            : [
                              Colors.orange.shade300,
                              Colors.deepOrange.shade500,
                            ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(CategoryState state) {
    if (state is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CategoryLoaded) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return _buildCategoryItem(category, index);
        },
      );
    } else if (state is CategoryError) {
      return Center(
        child: Text(
          'Lỗi: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCategoryItem(Category category, int index) {
    final List<IconData> categoryIcons = [
      Icons.auto_stories,
      Icons.science,
      Icons.history_edu,
      Icons.psychology,
      Icons.architecture_sharp,
      Icons.business_center,
      Icons.child_care_outlined,
      Icons.sports_esports,
      Icons.restaurant_menu,
      Icons.travel_explore,
    ];

    // Lấy icon theo index, nếu vượt quá thì lặp lại
    final icon = categoryIcons[index % categoryIcons.length];

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider.value(
                    value: _categoryBloc,
                    child: const ResultScreen(),
                  ),
              settings: RouteSettings(
                arguments: {'type': 'filter', 'query': category.id},
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
