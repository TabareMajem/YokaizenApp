import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yokai_quiz_app/util/colors.dart';

/// Collection of skeleton components for progressive loading
/// Uses shimmer effects to provide smooth loading experience
class SkeletonComponents {
  
  /// Base shimmer effect configuration
  static Widget _baseShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }

  /// User profile skeleton (for greeting section)
  static Widget userProfileSkeleton() {
    return _baseShimmer(
      child: Container(
        height: 50,
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Story card skeleton for trending section
  static Widget storyCardSkeleton({
    double? height,
    double? width,
  }) {
    return _baseShimmer(
      child: Container(
        height: height ?? 220,
        width: width ?? 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: indigo50, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
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

  /// Horizontal story list skeleton
  static Widget horizontalStoryListSkeleton({int itemCount = 3}) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: storyCardSkeleton(),
          );
        },
      ),
    );
  }

  /// Character avatar skeleton
  static Widget characterAvatarSkeleton() {
    return _baseShimmer(
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal character list skeleton
  static Widget horizontalCharacterListSkeleton({int itemCount = 5}) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 30),
            child: characterAvatarSkeleton(),
          );
        },
      ),
    );
  }

  /// Challenge card skeleton
  static Widget challengeCardSkeleton() {
    return _baseShimmer(
      child: Container(
        height: 80,
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: indigo50, width: 2),
        ),
        child: Center(
          child: Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal challenge list skeleton
  static Widget horizontalChallengeListSkeleton({int itemCount = 3}) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: challengeCardSkeleton(),
          );
        },
      ),
    );
  }

  /// Todo section skeleton
  static Widget todoSectionSkeleton() {
    return _baseShimmer(
      child: Container(
        width: double.infinity,
        height: 110,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 18,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 10,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(4),
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
    );
  }

  /// Section header skeleton
  static Widget sectionHeaderSkeleton({double width = 120}) {
    return _baseShimmer(
      child: Container(
        height: 16,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Error state widget with retry button
  static Widget errorStateWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Network error specific widget
  static Widget networkErrorWidget({VoidCallback? onRetry}) {
    return errorStateWidget(
      message: 'No internet connection.\nPlease check your network and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }

  /// Generic loading skeleton for any list
  static Widget genericListSkeleton({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
    Axis scrollDirection = Axis.vertical,
    double? height,
  }) {
    Widget listView = ListView.builder(
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );

    if (height != null && scrollDirection == Axis.horizontal) {
      return SizedBox(height: height, child: listView);
    }

    return listView;
  }

  /// Animated loading dots
  static Widget loadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 200)),
              builder: (context, double value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: coral500.withOpacity(value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  /// Skeleton wrapper that handles loading states
  static Widget skeletonWrapper({
    required bool isLoading,
    required bool hasError,
    required Widget skeleton,
    required Widget content,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    if (hasError) {
      return errorStateWidget(
        message: errorMessage ?? 'Something went wrong',
        onRetry: onRetry,
      );
    }

    if (isLoading) {
      return skeleton;
    }

    return content;
  }
} 