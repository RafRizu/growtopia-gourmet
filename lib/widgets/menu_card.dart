import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import 'radial_hero.dart';

class MenuCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.item,
    required this.onLongPress,
    required this.onTap,
  });

  static const BoxDecoration _cardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        AppColors.cardGradientStart,
        AppColors.cardGradientEnd,
      ],
    ),
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(
      BorderSide(
        color: AppColors.border,
        width: 1.2,
      ),
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = Semantics(
      button: true,
      enabled: item.tersedia,
      label:
          '${item.nama}, harga ${item.harga}, ${item.tersedia ? 'tersedia' : 'habis'}. Tekan lama untuk mengubah status ketersediaan.',
      child: DecoratedBox(
        decoration: _cardDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.tersedia ? onTap : null,
            onLongPress: onLongPress,
            mouseCursor: item.tersedia
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.avatarSurface,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: RadialHeroWidget(
                      tag: 'food_${item.id}',
                      imageAsset: item.imageAsset,
                      semanticLabel: 'Gambar ${item.nama}',
                      size: 64,
                      borderRadius: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.deskripsi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(
                              item.harga,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentText,
                                fontFeatures: <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                item.kategori,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!item.tersedia)
                    const _HabisBadge()
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondaryText,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (item.tersedia) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: cardContent,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _UnavailableOpacityFade(
        key: ValueKey<String>('unavailable_${item.id}'),
        child: cardContent,
      ),
    );
  }
}

class _UnavailableOpacityFade extends StatefulWidget {
  final Widget child;

  const _UnavailableOpacityFade({
    super.key,
    required this.child,
  });

  @override
  State<_UnavailableOpacityFade> createState() =>
      _UnavailableOpacityFadeState();
}

class _UnavailableOpacityFadeState extends State<_UnavailableOpacityFade> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 0.4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: widget.child,
    );
  }
}

class _HabisBadge extends StatelessWidget {
  const _HabisBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badgeHabisBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'HABIS',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AppColors.badgeHabisText,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
