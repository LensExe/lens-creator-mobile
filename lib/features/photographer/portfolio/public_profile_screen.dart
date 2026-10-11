import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_avatar.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import '../../../core/widgets/creator_media_surface.dart';
import '../../../core/widgets/review_item.dart';
import '../../../domain/models/models.dart';
import '../../../domain/models/review.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart' show formatDong;
import '../reviews/review_provider.dart';
import '../packages/booking_plan_repository.dart';
import 'api_portfolio_repository.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final plans = ref.watch(bookingPlansProvider);
    final portfolio = ref.watch(photographerPortfolioProvider);
    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9FA),
        body: Center(child: Text('Không tìm thấy hồ sơ')),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FA),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF1A1C1D),
            ),
            tooltip: 'Quay lại',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Hồ sơ nhiếp ảnh',
            style: TextStyle(
              color: Color(0xFF1A1C1D),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              icon: const Icon(
                Icons.edit_outlined,
                size: 22,
                color: Color(0xFF5F5E60),
              ),
              onPressed: () => context.push('/photographer_home/portfolio'),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PublicProfileHeroHeader(profile: profile),
                      const _PublicProfileTabBar(),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _PortfolioTab(
                    profile: profile,
                    portfolio: portfolio,
                    onRetry: () =>
                        ref.invalidate(photographerPortfolioProvider),
                  ),
                  _AboutTab(
                    profile: profile,
                    plans: plans,
                    onRetry: () => ref.invalidate(bookingPlansProvider),
                  ),
                  _ProfileReviewsTab(
                    profile: profile,
                    onSeeAll: () => context.push('/photographer_home/reviews'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. HERO COVER & PROFILE CARD
// ============================================================================
class _PublicProfileHeroHeader extends StatelessWidget {
  const _PublicProfileHeroHeader({required this.profile});

  final Photographer profile;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (profile.cover.isNotEmpty)
                  Image.network(
                    profile.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _PublicCoverPlaceholder(),
                  )
                else
                  const _PublicCoverPlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x30000000),
                        Color(0x99000000),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating Profile Card (Overlapping Cover)
        Padding(
          padding: const EdgeInsets.only(top: 130, left: 4, right: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar & Rating Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar with checkmark
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CreatorAvatar(
                              name: profile.name,
                              imageUrl: profile.avatar,
                              size: 72,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F4),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFE5A000),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF1A1C1D),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${profile.reviewCount})',
                            style: const TextStyle(
                              color: Color(0xFF5F5E60),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1A1C1D),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Location & Experience
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 15,
                      color: Color(0xFF5D5E66),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${profile.city} · ${profile.experienceYears} năm kinh nghiệm',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5F5E60),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Stats line
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${profile.rating.toStringAsFixed(1)} ★',
                      style: const TextStyle(
                        color: Color(0xFF1A1C1D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(${profile.reviewCount} đánh giá)',
                      style: const TextStyle(
                        color: Color(0xFF5F5E60),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
                    ),
                    Text(
                      '${profile.portfolio.length} bộ ảnh hoàn thành',
                      style: const TextStyle(
                        color: Color(0xFF5F5E60),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Style tags
                if (profile.styles.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final style in profile.styles)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEF),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            style,
                            style: const TextStyle(
                              color: Color(0xFF5F5E60),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// 2. SEGMENTED TAB BAR
// ============================================================================
class _PublicProfileTabBar extends StatelessWidget {
  const _PublicProfileTabBar();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEF),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        labelColor: const Color(0xFF1A1C1D),
        unselectedLabelColor: const Color(0xFF5F5E60),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Tác phẩm'),
          Tab(text: 'Giới thiệu'),
          Tab(text: 'Đánh giá'),
        ],
      ),
    ),
  );
}

// ============================================================================
// 3. TAB 1: TÁC PHẨM (PORTFOLIO LOOKBOOK)
// ============================================================================
class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({
    required this.profile,
    required this.portfolio,
    required this.onRetry,
  });

  final Photographer profile;
  final AsyncValue<PortfolioWorkspace> portfolio;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => portfolio.when(
    loading: () => const CreatorLoadingState(label: 'Đang tải portfolio…'),
    error: (error, _) => CreatorEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Không thể tải portfolio',
      description: '$error',
      actionLabel: 'Thử lại',
      onAction: onRetry,
    ),
    data: (workspace) => _gallery(
      context,
      profile.copyWith(
        portfolio: workspace.assets.map((asset) => asset.url).toList(),
      ),
    ),
  );

  Widget _gallery(BuildContext context, Photographer profile) =>
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tác phẩm tiêu biểu (${profile.portfolio.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5F5E60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.portfolio.isEmpty)
              const CreatorEmptyState(
                icon: Icons.photo_library_outlined,
                title: 'Chưa có tác phẩm',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profile.portfolio.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CreatorMediaSurface(
                            imageUrl: profile.portfolio[index],
                            radius: 14,
                            placeholderIcon: Icons.broken_image_outlined,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x15000000),
                                  Color(0xB3000000),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            left: 8,
                            child: Text(
                              'Tác phẩm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
}

// ============================================================================
// 4. TAB 2: GIỚI THIỆU & GÓI DỊCH VỤ
// ============================================================================
class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.profile,
    required this.plans,
    required this.onRetry,
  });

  final Photographer profile;
  final AsyncValue<List<PhotographerPackage>> plans;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Về tôi" Card
        _PublicProfileSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFA83900), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Về tôi',
                    style: TextStyle(
                      color: Color(0xFF1A1C1D),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile.bio,
                style: const TextStyle(
                  color: Color(0xFF5F5E60),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        plans.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => CreatorEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không thể tải gói dịch vụ',
            description: '$error',
            actionLabel: 'Thử lại',
            onAction: onRetry,
          ),
          data: (plans) => _PlansSection(
            plans: plans.where((plan) => plan.isActive).toList(),
          ),
        ),
      ],
    ),
  );
}

class _PlansSection extends StatelessWidget {
  const _PlansSection({required this.plans});

  final List<PhotographerPackage> plans;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          const title = Text(
            'Gói dịch vụ nhiếp ảnh',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF1A1C1D),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          );
          final count = Text(
            '${plans.length} gói đang hoạt động',
            style: const TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
          );
          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 4), count],
            );
          }
          return Row(
            children: [
              const Expanded(child: title),
              const SizedBox(width: 8),
              count,
            ],
          );
        },
      ),
      const SizedBox(height: 10),
      if (plans.isEmpty)
        const CreatorEmptyState(
          icon: Icons.camera_alt_outlined,
          title: 'Chưa có gói dịch vụ đang hoạt động',
        )
      else
        for (final plan in plans) ...[
          _PublicPackageCard(package: plan),
          const SizedBox(height: 12),
        ],
    ],
  );
}

class _PublicPackageCard extends StatelessWidget {
  const _PublicPackageCard({required this.package});

  final PhotographerPackage package;

  @override
  Widget build(BuildContext context) => _PublicProfileSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final titleAndDescription = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (package.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    style: const TextStyle(
                      color: Color(0xFF5F5E60),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            );
            final price = Text(
              formatDong(package.price),
              style: const TextStyle(
                color: Color(0xFFFF5A00),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            );
            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleAndDescription,
                  const SizedBox(height: 6),
                  price,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleAndDescription),
                const SizedBox(width: 10),
                price,
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Fact strip
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image, size: 15, color: Color(0xFF5D5E66)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${package.photoCount} ảnh, ${package.retouchedPhotoCount} ảnh chỉnh sửa',
                    style: const TextStyle(
                      color: Color(0xFF5F5E60),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 15, color: Color(0xFF5D5E66)),
                const SizedBox(width: 4),
                Text(
                  '${_formatHours(package.durationHours)} giờ chụp',
                  style: const TextStyle(
                    color: Color(0xFF5F5E60),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            for (final feature in package.features)
              Text(
                feature,
                style: const TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
              ),
          ],
        ),
      ],
    ),
  );

  String _formatHours(double hours) => hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toStringAsFixed(1);
}

// ============================================================================
// 5. TAB 3: ĐÁNH GIÁ (REVIEWS)
// ============================================================================
class _ProfileReviewsTab extends ConsumerWidget {
  const _ProfileReviewsTab({required this.profile, required this.onSeeAll});

  final Photographer profile;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(photographerReviewsProvider);
    return reviewState.when(
      loading: () => const CreatorLoadingState(label: 'Đang tải đánh giá…'),
      error: (error, _) => CreatorEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải đánh giá',
        actionLabel: 'Thử lại',
        onAction: () => ref.invalidate(photographerReviewsProvider),
      ),
      data: (reviews) => _reviewsContent(context, profile, reviews),
    );
  }

  Widget _reviewsContent(
    BuildContext context,
    Photographer profile,
    List<Review> reviews,
  ) {
    final recentReviews = [...reviews]
      ..sort((first, second) => second.date.compareTo(first.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rating Summary Card
          _PublicProfileSurfaceCard(
            child: Column(
              children: [
                Text(
                  profile.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 5; i++)
                      const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: Color(0xFFE5A000),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Từ ${profile.reviewCount} đánh giá',
                  style: const TextStyle(
                    color: Color(0xFF5F5E60),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section Title
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhận xét mới nhất',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sắp xếp theo gần đây',
                style: TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (recentReviews.isEmpty)
            const CreatorEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'Chưa có đánh giá nào',
            )
          else
            for (final review in recentReviews.take(2)) ...[
              _PublicProfileSurfaceCard(
                child: ReviewItemWidget(review: review, showDivider: false),
              ),
              const SizedBox(height: 10),
            ],

          OutlinedButton(
            onPressed: onSeeAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1C1D),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFEEEEEF)),
              minimumSize: const Size(0, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Xem tất cả đánh giá',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMMON SURFACE CARD
// ============================================================================
class _PublicProfileSurfaceCard extends StatelessWidget {
  const _PublicProfileSurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _PublicCoverPlaceholder extends StatelessWidget {
  const _PublicCoverPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFE8E8E9),
    child: Center(
      child: Icon(
        Icons.photo_camera_back_outlined,
        color: Color(0xFFA1A1AA),
        size: 40,
      ),
    ),
  );
}
