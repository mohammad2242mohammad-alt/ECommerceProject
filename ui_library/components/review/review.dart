import 'package:flutter/material.dart';

/// Data model for a reusable customer review.
class ReviewItem {
  final String id;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime? date;
  final bool verifiedPurchase;

  const ReviewItem({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    this.userImageUrl,
    this.date,
    this.verifiedPurchase = false,
  });
}

/// Reusable review section. Moderation, pagination and data fetching stay
/// outside the UI library.
class ReviewComponent extends StatelessWidget {
  final List<ReviewItem> reviews;
  final ValueChanged<ReviewItem>? onReviewTap;
  final VoidCallback? onViewAll;
  final String title;
  final String? subtitle;
  final bool showViewAll;
  final int maxVisible;

  const ReviewComponent({
    super.key,
    required this.reviews,
    this.onReviewTap,
    this.onViewAll,
    this.title = 'نظرات کاربران',
    this.subtitle,
    this.showViewAll = true,
    this.maxVisible = 3,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = reviews.take(maxVisible.clamp(1, reviews.length == 0 ? 1 : reviews.length)).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (showViewAll && onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('مشاهده همه'),
                    ),
                ],
              ),
            ),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'هنوز نظری ثبت نشده است.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final review = visible[index];
                  return _ReviewCard(
                    review: review,
                    formattedDate: _formatDate(review.date),
                    onTap: onReviewTap == null ? null : () => onReviewTap!(review),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;
  final String formattedDate;
  final VoidCallback? onTap;

  const _ReviewCard({
    required this.review,
    required this.formattedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = review.rating.clamp(0, 5).toDouble();

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: review.userImageUrl == null
                        ? null
                        : NetworkImage(review.userImageUrl!),
                    child: review.userImageUrl == null
                        ? Text(
                            review.userName.isEmpty
                                ? '?'
                                : review.userName.characters.first,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (formattedDate.isNotEmpty)
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                review.comment,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              if (review.verifiedPurchase) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'خرید تأیید شده',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
