import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RadialHeroWidget extends StatelessWidget {
  final String tag;
  final String imageAsset;
  final String semanticLabel;
  final double size;
  final double borderRadius;
  final double catalogRadius;
  final double detailRadius;

  const RadialHeroWidget({
    super.key,
    required this.tag,
    required this.imageAsset,
    required this.semanticLabel,
    required this.size,
    required this.borderRadius,
    this.catalogRadius = 32.0,
    this.detailRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (Rect? begin, Rect? end) {
        return MaterialRectArcTween(begin: begin, end: end);
      },
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final Widget imageFrame = _FoodImageFrame(
          imageAsset: imageAsset,
          semanticLabel: semanticLabel,
        );

        return AnimatedBuilder(
          animation: animation,
          child: imageFrame,
          builder: (BuildContext context, Widget? child) {
            final double currentRadius =
                ui.lerpDouble(catalogRadius, detailRadius, animation.value) ??
                    detailRadius;
            return ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: child,
            );
          },
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: _FoodImageFrame(
            imageAsset: imageAsset,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

class _FoodImageFrame extends StatelessWidget {
  final String imageAsset;
  final String semanticLabel;

  const _FoodImageFrame({
    required this.imageAsset,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.avatarSurface,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          imageAsset,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.secondaryText,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }
}
