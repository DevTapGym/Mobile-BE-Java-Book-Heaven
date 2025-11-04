import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';

class ReviewSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final Map<String, dynamic> bookData;
  final String Function(int) formatReviewCount;

  const ReviewSectionWidget({
    super.key,
    required this.reviews,
    required this.bookData,
    required this.formatReviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final displayedReviews = reviews.take(2).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                //'Reviews',
                'Đánh giá',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${bookData['rating']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'review (${formatReviewCount(bookData['reviewCount'])})',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reviews
          ...displayedReviews.map(
            (review) => ReviewCard(
              review: review,
              primaryColor: AppColors.primary,
              onLikePressed: () {},
              onMorePressed: () {},
            ),
          ),

          // Nút xem tất cả reviews
          if (reviews.length > 2)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/detail-review');
                },
                icon: Text(
                  //'View All Reviews',
                  'Xem tất cả đánh giá',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                label: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final Color primaryColor;
  final VoidCallback? onLikePressed;
  final VoidCallback? onMorePressed;

  const ReviewCard({
    super.key,
    required this.review,
    required this.primaryColor,
    this.onLikePressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final int rating =
        (review['rating'] is num) ? (review['rating'] as num).floor() : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: primaryColor,
                radius: 20,
                child: Text(
                  (review['name'] as String).isNotEmpty
                      ? review['name'][0]
                      : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          rating,
                          (i) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['date'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Likes and more
              Row(
                children: [
                  IconButton(
                    onPressed: onLikePressed,
                    icon: Icon(
                      Icons.thumb_up,
                      color:
                          (review['liked'] == true)
                              ? Colors.blue
                              : Colors.grey[600],
                      size: 18,
                    ),
                  ),
                  Text(
                    '${review['likes'] ?? 0}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),
          if (review['images'] != null && review['images'].isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: (review['images'] as List).length,
                itemBuilder: (context, imageIndex) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
