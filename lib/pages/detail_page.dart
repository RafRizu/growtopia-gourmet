import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/radial_hero.dart';

class DetailPage extends StatefulWidget {
  final FoodItem item;
  final VoidCallback? onToggleAvailability;

  const DetailPage({
    super.key,
    required this.item,
    this.onToggleAvailability,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  void _handleToggleAvailability() {
    if (widget.onToggleAvailability != null) {
      widget.onToggleAvailability!();
      setState(() {});
    } else {
      setState(() {
        widget.item.tersedia = !widget.item.tersedia;
      });
    }
  }

  Future<void> _openOrderSheet() async {
    final int? orderedQty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return _OrderConfirmationSheet(item: widget.item);
      },
    );

    if (!mounted || orderedQty == null) {
      return;
    }

    final int totalWl = orderedQty * widget.item.hargaWl;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Pesanan dicatat: $orderedQty x ${widget.item.nama} ($totalWl WL).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodItem item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Hidangan'),
        leading: IconButton(
          tooltip: 'Kembali ke katalog',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= 760;
            final double heroSize =
                constraints.maxWidth < 340 ? constraints.maxWidth - 64 : 260;

            final Widget heroCard = Container(
              width: heroSize,
              height: heroSize,
              decoration: BoxDecoration(
                color: AppColors.avatarSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: RadialHeroWidget(
                tag: 'food_${item.id}',
                imageAsset: item.imageAsset,
                semanticLabel: 'Gambar detail ${item.nama}',
                size: heroSize,
                borderRadius: 24,
              ),
            );

            final Widget infoColumn = _DetailInfoSection(
              item: item,
              onOrderPressed: item.tersedia ? _openOrderSheet : null,
              onToggleAvailability: _handleToggleAvailability,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            heroCard,
                            const SizedBox(width: 32),
                            Expanded(child: infoColumn),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(child: heroCard),
                            const SizedBox(height: 24),
                            infoColumn,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailInfoSection extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onOrderPressed;
  final VoidCallback onToggleAvailability;

  const _DetailInfoSection({
    required this.item,
    required this.onOrderPressed,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _StatusTag(tersedia: item.tersedia),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  item.kategori,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.nama,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.harga,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.accentText,
              fontFeatures: <FontFeature>[
                FontFeature.tabularFigures(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          const Text(
            'Deskripsi hidangan',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.deskripsi,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              height: 1.55,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOrderPressed,
              child: Text(
                item.tersedia
                    ? 'Pesan ${item.nama}'
                    : 'Menu sedang habis',
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onToggleAvailability,
              child: Text(
                item.tersedia ? 'Tandai habis' : 'Tandai tersedia lagi',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final bool tersedia;

  const _StatusTag({required this.tersedia});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tersedia ? AppColors.badgeTersediaBg : AppColors.badgeHabisBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tersedia ? 'TERSEDIA' : 'HABIS',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: tersedia
              ? AppColors.badgeTersediaText
              : AppColors.badgeHabisText,
        ),
      ),
    );
  }
}

class _OrderConfirmationSheet extends StatefulWidget {
  final FoodItem item;

  const _OrderConfirmationSheet({required this.item});

  @override
  State<_OrderConfirmationSheet> createState() =>
      _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState extends State<_OrderConfirmationSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final int totalWl = _quantity * widget.item.hargaWl;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Konfirmasi Pesanan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup konfirmasi',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.item.nama} (${widget.item.harga} per porsi)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Jumlah porsi',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                Row(
                  children: <Widget>[
                    IconButton.outlined(
                      tooltip: 'Kurangi jumlah',
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity -= 1)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: 'Tambah jumlah',
                      onPressed: _quantity < 20
                          ? () => setState(() => _quantity += 1)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Total estimasi',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '$totalWl WL',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentText,
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_quantity),
              child: Text('Catat Pesanan ($totalWl WL)'),
            ),
          ],
        ),
      ),
    );
  }
}
