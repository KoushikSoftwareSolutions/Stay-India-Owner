import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  final Widget child;
  const ShimmerEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

class Skeleton extends StatelessWidget {
  final double? height, width;
  final double borderRadius;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
    );
  }
}

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Skeleton(height: 20, width: 100),
            SizedBox(height: 12),
            Skeleton(height: 32, width: 60),
            SizedBox(height: 8),
            Skeleton(height: 14, width: 80),
          ],
        ),
      ),
    );
  }
}

class TenantCardSkeleton extends StatelessWidget {
  const TenantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Skeleton(height: 50, width: 50, borderRadius: 25),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(height: 18, width: 150),
                  SizedBox(height: 8),
                  Skeleton(height: 14, width: 100),
                ],
              ),
            ),
            const Skeleton(height: 24, width: 60, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Skeleton(height: 150, width: double.infinity, borderRadius: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(height: 20, width: 200),
                  SizedBox(height: 8),
                  Skeleton(height: 14, width: 150),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Skeleton(height: 24, width: 80),
                      Skeleton(height: 24, width: 100),
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

class DetailsSkeleton extends StatelessWidget {
  const DetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(height: 200, width: double.infinity, borderRadius: 16),
            const SizedBox(height: 24),
            const Skeleton(height: 28, width: 200),
            const SizedBox(height: 12),
            const Skeleton(height: 16, width: 250),
            const SizedBox(height: 32),
            const Skeleton(height: 20, width: 150),
            const SizedBox(height: 12),
            ...List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Skeleton(height: 60, width: double.infinity),
            )),
          ],
        ),
      ),
    );
  }
}
