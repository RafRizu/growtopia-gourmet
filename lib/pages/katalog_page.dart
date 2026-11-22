import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/menu_card.dart';
import '../widgets/rotating_cup_header.dart';
import 'detail_page.dart';

enum _AvailabilityFilter { semua, tersedia, habis }

class KatalogPage extends StatefulWidget {
  const KatalogPage({
    super.key,
    this.initialItems,
    this.initialError,
  });

  final List<FoodItem>? initialItems;
  final String? initialError;

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  late List<FoodItem> _items;
  final TextEditingController _searchController = TextEditingController();
  _AvailabilityFilter _filter = _AvailabilityFilter.semua;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems != null
        ? List<FoodItem>.from(widget.initialItems!)
        : createInitialGrowtopiaFoods();
    _errorMessage = widget.initialError;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _availableCount => _items.where((FoodItem e) => e.tersedia).length;
  int get _unavailableCount => _items.length - _availableCount;

  List<FoodItem> get _filteredItems {
    final String normalizedQuery = _query.trim().toLowerCase();
    return _items.where((FoodItem item) {
      final bool matchesFilter = switch (_filter) {
        _AvailabilityFilter.semua => true,
        _AvailabilityFilter.tersedia => item.tersedia,
        _AvailabilityFilter.habis => !item.tersedia,
      };
      if (!matchesFilter) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return item.nama.toLowerCase().contains(normalizedQuery) ||
          item.deskripsi.toLowerCase().contains(normalizedQuery) ||
          item.kategori.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  void _toggleAvailability(FoodItem item) {
    setState(() {
      item.tersedia = !item.tersedia;
    });

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          item.tersedia
              ? '${item.nama} ditandai tersedia.'
              : '${item.nama} ditandai habis.',
        ),
        action: SnackBarAction(
          label: 'Batal',
          textColor: AppColors.accentWarm,
          onPressed: () {
            if (!mounted) {
              return;
            }
            setState(() {
              item.tersedia = !item.tersedia;
            });
          },
        ),
      ),
    );
  }

  Future<void> _openDetail(FoodItem item) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return DetailPage(
            item: item,
            onToggleAvailability: () => _toggleAvailability(item),
          );
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _reloadCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }
    setState(() {
      _items = createInitialGrowtopiaFoods();
      _filter = _AvailabilityFilter.semua;
      _query = '';
      _searchController.clear();
      _isLoading = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _filter = _AvailabilityFilter.semua;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> visibleItems = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Growtopia Gourmet'),
            SizedBox(height: 2),
            Text(
              'Katalog kuliner',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RotatingCupHeader(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CatalogControls(
                  searchController: _searchController,
                  query: _query,
                  filter: _filter,
                  totalCount: _items.length,
                  availableCount: _availableCount,
                  unavailableCount: _unavailableCount,
                  onQueryChanged: (String value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  onClearQuery: () {
                    setState(() {
                      _query = '';
                      _searchController.clear();
                    });
                  },
                  onFilterChanged: (_AvailabilityFilter next) {
                    setState(() {
                      _filter = next;
                    });
                  },
                ),
                Expanded(
                  child: _buildBody(visibleItems),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<FoodItem> visibleItems) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: AppColors.primaryText),
            SizedBox(height: 16),
            Text(
              'Memuat katalog menu Growtopia...',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _CatalogStatePanel(
        icon: Icons.error_outline_rounded,
        title: 'Katalog gagal dimuat',
        message: _errorMessage!,
        actionLabel: 'Muat ulang katalog',
        onAction: _reloadCatalog,
      );
    }

    if (visibleItems.isEmpty) {
      final bool isFilteringUnavailable =
          _filter == _AvailabilityFilter.habis && _query.trim().isEmpty;
      return _CatalogStatePanel(
        icon: Icons.restaurant_menu_rounded,
        title: isFilteringUnavailable
            ? 'Belum ada menu yang habis'
            : 'Menu tidak ditemukan',
        message: isFilteringUnavailable
            ? 'Semua 10 hidangan masih tersedia. Tekan lama salah satu kartu menu untuk menandainya habis.'
            : 'Tidak ada hidangan yang cocok dengan filter atau kata kunci saat ini.',
        actionLabel: 'Tampilkan semua menu',
        onAction: _resetFilters,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryText,
      onRefresh: _reloadCatalog,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: visibleItems.length,
        itemBuilder: (BuildContext context, int index) {
          final FoodItem item = visibleItems[index];
          return MenuCard(
            key: ValueKey<String>(item.id),
            item: item,
            onTap: () => _openDetail(item),
            onLongPress: () => _toggleAvailability(item),
          );
        },
      ),
    );
  }
}

class _CatalogControls extends StatelessWidget {
  final TextEditingController searchController;
  final String query;
  final _AvailabilityFilter filter;
  final int totalCount;
  final int availableCount;
  final int unavailableCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<_AvailabilityFilter> onFilterChanged;

  const _CatalogControls({
    required this.searchController,
    required this.query,
    required this.filter,
    required this.totalCount,
    required this.availableCount,
    required this.unavailableCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Cari hidangan',
              hintText: 'Contoh: Arroz, Crepes, Gemonade',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.secondaryText,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: onClearQuery,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.secondaryText,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _FilterTab(
                    label: 'Semua ($totalCount)',
                    selected: filter == _AvailabilityFilter.semua,
                    onTap: () => onFilterChanged(_AvailabilityFilter.semua),
                  ),
                  const SizedBox(width: 20),
                  _FilterTab(
                    label: 'Tersedia ($availableCount)',
                    selected: filter == _AvailabilityFilter.tersedia,
                    onTap: () => onFilterChanged(_AvailabilityFilter.tersedia),
                  ),
                  const SizedBox(width: 20),
                  _FilterTab(
                    label: 'Habis ($unavailableCount)',
                    selected: filter == _AvailabilityFilter.habis,
                    onTap: () => onFilterChanged(_AvailabilityFilter.habis),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primaryText : Colors.transparent,
                width: 2.2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.primaryText : AppColors.secondaryText,
              fontFeatures: const <FontFeature>[
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CatalogStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 36, color: AppColors.secondaryText),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
