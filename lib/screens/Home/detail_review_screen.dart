import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/widgets/review_section_widget.dart';

class DetailReviewScreen extends StatefulWidget {
  const DetailReviewScreen({super.key});

  @override
  State<DetailReviewScreen> createState() => _DetailReviewScreenState();
}

class _DetailReviewScreenState extends State<DetailReviewScreen> {
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Tanjinka',
      'rating': 4.5,
      'date': '2024-06-07',
      'comment':
          'Every page is filled with wisdom, innocence, and a gentle reminder of what truly matters.',
      'likes': 3,
      'images': [1, 2],
    },
    {
      'name': 'Toshima',
      'rating': 4.5,
      'date': '2024-08-12',
      'comment':
          'A beautiful story that reminds us of the simple yet profound truths we often forget in adulthood.',
      'likes': 3,
      'images': [1, 2, 3],
    },
    {
      'name': 'Toshima',
      'rating': 4.5,
      'date': '2024-08-12',
      'comment':
          'A beautiful story that reminds us of the simple yet profound truths we often forget in adulthood.',
      'likes': 3,
      'images': [1, 2, 3, 4, 5],
    },
  ];

  // Filter state
  bool filterHasImages = false;
  int? filterStar;
  String sortOption = 'Most Helpful';

  List<Map<String, dynamic>> get filteredReviews {
    List<Map<String, dynamic>> list = List.from(reviews);

    // Filter by images
    if (filterHasImages) {
      list =
          list
              .where(
                (r) => r['images'] != null && (r['images'] as List).isNotEmpty,
              )
              .toList();
    }

    // Filter by star
    if (filterStar != null) {
      list =
          list
              .where(
                (r) =>
                    (r['rating'] is num) &&
                    (r['rating'] as num).floor() == filterStar,
              )
              .toList();
    }

    // Sort
    if (sortOption == 'Most Helpful') {
      list.sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));
    } else if (sortOption == 'Newest') {
      list.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    } else if (sortOption == 'Oldest') {
      list.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
    }

    return list;
  }

  void _showStarSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // All option
                  InkWell(
                    onTap: () {
                      setState(() {
                        filterStar = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'All',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (filterStar == null)
                            Icon(Icons.check, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),

                  // Star options (5..1) with number + N star icons
                  for (var s = 5; s >= 1; s--)
                    InkWell(
                      onTap: () {
                        setState(() {
                          filterStar = s;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$s',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: List.generate(
                                s,
                                (_) => const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (filterStar == s)
                              Icon(Icons.check, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review (312)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    // Toggle include visuals
                    FilterChip(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      label: const Text(
                        'Include visuals',
                        style: TextStyle(fontSize: 14),
                      ),
                      backgroundColor: Colors.white,
                      selected: filterHasImages,
                      onSelected: (v) => setState(() => filterHasImages = v),
                      selectedColor: AppColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Star filter
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => _showStarSelector(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            filterStar == null ? 'All' : '$filterStar',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: SizedBox(
                        width: 110,
                        child: DropdownButton<String>(
                          isDense: true,
                          underline: const SizedBox(),
                          value: sortOption,
                          items: const [
                            DropdownMenuItem(
                              value: 'Most Helpful',
                              child: Text(
                                'Most Helpful',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Newest',
                              child: Text(
                                'Newest',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Oldest',
                              child: Text(
                                'Oldest',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                          onChanged:
                              (v) => setState(() {
                                if (v != null) sortOption = v;
                              }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Clear filters
                    TextButton.icon(
                      onPressed:
                          () => setState(() {
                            filterHasImages = false;
                            filterStar = null;
                            sortOption = 'Most Helpful';
                          }),
                      label: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      icon: Icon(Icons.clear, size: 16, color: Colors.red),
                    ),

                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Reviews list
            Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                itemCount: filteredReviews.length,
                itemBuilder: (context, index) {
                  final r = filteredReviews[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReviewCard(
                      review: r,
                      primaryColor: AppColors.primary,
                      onLikePressed: () {
                        setState(() {
                          r['liked'] = !(r['liked'] == true);
                          r['likes'] =
                              (r['likes'] ?? 0) + (r['liked'] == true ? 1 : -1);
                        });
                      },
                      onMorePressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder:
                              (_) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    ListTile(title: Text('Report')),
                                    ListTile(title: Text('Share')),
                                  ],
                                ),
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

Widget _buildBottomBar() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          // Add to cart button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Buy now button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
