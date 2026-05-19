import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';
import 'salon_detail_screen.dart';
import 'models/catalog_item.dart';
import 'models/reservation_request.dart';
import 'models/salon_view_model.dart';
import 'services/catalogos_api_service.dart';
import 'services/salones_api_service.dart';
import 'utils/activity_store.dart';
import 'utils/favorites_store.dart';
import 'utils/salones_filtering.dart';
import 'widgets/main_bottom_nav.dart';
import 'widgets/salones/reservation_bottom.dart';
import 'widgets/salones/salon_card.dart';

/// SalonesScreen — Reservation-focused catalog with search, filters, sorting,
/// and actionable salon cards.
class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  static const Color _primaryDark = AppColors.bg1;
  static const Color _accentIndigo = AppColors.accent;
  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<String> _sortOptions = [
    'Mejor calificacion',
    'Menor precio',
    'Mayor capacidad',
  ];

  final TextEditingController _searchController = TextEditingController();

  bool _showFilters = false;
  bool _onlyAvailable = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _rangesInitialized = false;
  String _errorMessage = 'No se pudo cargar la búsqueda';

  String _selectedType = 'Todos';
  String _selectedSort = 'Mejor calificacion';
  RangeValues _capacityRange = const RangeValues(20, 200);
  RangeValues _priceRange = const RangeValues(300000, 1300000);
  double _capacityMin = 20;
  double _capacityMax = 200;
  double _priceMin = 300000;
  double _priceMax = 1300000;

  late final CatalogosApiService _catalogosApiService;
  late final SalonesApiService _apiService;
  final List<SalonViewModel> _salons = [];
  final List<CatalogItem> _categorias = [];
  final List<FranjaHorariaItem> _franjas = [];
  List<String> _categoryOptions = ['Todos'];

  @override
  void initState() {
    super.initState();
    _catalogosApiService = CatalogosApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    _apiService = SalonesApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCatalogos();
      _fetchSalons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _ensureAuthenticated() async {
    if (AuthController.instance.isLoggedIn) {
      return true;
    }

    final bool? didLogin = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.login,
          title: 'Accede para reservar',
        ),
      ),
    );

    return didLogin == true && AuthController.instance.isLoggedIn;
  }

  Future<void> _fetchSalons() async {
    final String? token = AuthController.instance.session?.token;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = 'No se pudo cargar la búsqueda';
    });

    try {
      final List<SalonViewModel> loaded = await _apiService.fetchSalons(
        token: token,
      );

      if (!mounted) {
        return;
      }

      RangeValues capacityRange = _capacityRange;
      RangeValues priceRange = _priceRange;
      bool rangesInitialized = _rangesInitialized;

      if (loaded.isNotEmpty) {
        final List<int> capacities =
            loaded.map((salon) => salon.capacity).toList();
        final List<double> prices =
            loaded.map((salon) => salon.price).toList();

        final RangeValues capacityLimits =
            _rangeFromInts(capacities, _capacityRange);
        final RangeValues priceLimits =
            _rangeFromDoubles(prices, _priceRange);

        _capacityMin = capacityLimits.start;
        _capacityMax = capacityLimits.end;
        _priceMin = priceLimits.start;
        _priceMax = priceLimits.end;

        if (!_rangesInitialized) {
          capacityRange = capacityLimits;
          priceRange = priceLimits;
          rangesInitialized = true;
        } else {
          capacityRange = _clampRange(
            _capacityRange,
            _capacityMin,
            _capacityMax,
          );
          priceRange = _clampRange(_priceRange, _priceMin, _priceMax);
        }
      }

      setState(() {
        _salons
          ..clear()
          ..addAll(loaded);
        _capacityRange = capacityRange;
        _priceRange = priceRange;
        _rangesInitialized = rangesInitialized;
        _isLoading = false;
        _hasError = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Tiempo de espera agotado. Revisa tu conexión (${ApiConfig.baseUrl})';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '')
            .trim();
        if (_errorMessage.isEmpty) {
          _errorMessage = 'No se pudo conectar con el servidor';
        }
      });
    }
  }

  Future<void> _runSearch() async {
    setState(() {
      _showFilters = true;
    });

    if (_salons.isEmpty || _hasError) {
      await _fetchSalons();
    }
  }

  Future<String> _createReservation({
    required int salonId,
    required ReservationRequest request,
  }) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para reservar');
    }

    return _apiService.createReservation(
      token: token,
      salonId: salonId,
      request: request,
    );
  }

  Future<void> _handleReserveTap(SalonViewModel salon) async {
    final bool authenticated = await _ensureAuthenticated();
    if (!mounted || !authenticated) {
      return;
    }

    if (_franjas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay franjas horarias disponibles'),
        ),
      );
      return;
    }

    final String? code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReservationBottomSheet(
        salonName: salon.name,
        salonCapacity: salon.capacity,
        franjas: _franjas,
        onSubmit: (request) =>
            _createReservation(salonId: salon.id, request: request),
      ),
    );

    if (!mounted || code == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reserva confirmada: $code')));
  }

  List<String> _searchSuggestions() {
    return SalonesFiltering.searchSuggestions(
      query: _searchController.text,
      salons: _salons,
    );
  }

  List<SalonViewModel> _filteredSalons() {
    return SalonesFiltering.filterAndSort(
      salons: _salons,
      query: _searchController.text,
      selectedType: _selectedType,
      onlyAvailable: _onlyAvailable,
      capacityRange: RangeValuesData(
        start: _capacityRange.start,
        end: _capacityRange.end,
      ),
      priceRange: RangeValuesData(
        start: _priceRange.start,
        end: _priceRange.end,
      ),
      selectedSort: _selectedSort,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'Todos';
      _onlyAvailable = false;
      final List<int> capacities =
          _salons.map((salon) => salon.capacity).toList();
      final List<double> prices =
          _salons.map((salon) => salon.price).toList();

      final RangeValues capacityLimits = _rangeFromInts(
        capacities,
        RangeValues(_capacityMin, _capacityMax),
      );
      final RangeValues priceLimits = _rangeFromDoubles(
        prices,
        RangeValues(_priceMin, _priceMax),
      );

      _capacityMin = capacityLimits.start;
      _capacityMax = capacityLimits.end;
      _priceMin = priceLimits.start;
      _priceMax = priceLimits.end;

      _capacityRange = capacityLimits;
      _priceRange = priceLimits;
    });
  }

  RangeValues _clampRange(RangeValues values, double min, double max) {
    final double start = values.start.clamp(min, max).toDouble();
    final double end = values.end.clamp(min, max).toDouble();
    return RangeValues(start, end < start ? start : end);
  }

  int _divisionsForStep(double min, double max, double step) {
    final double span = max - min;
    if (span <= 0 || step <= 0) {
      return 1;
    }
    return (span / step).round().clamp(1, 1000000).toInt();
  }

  RangeValues _rangeFromInts(List<int> values, RangeValues fallback) {
    if (values.isEmpty) {
      return fallback;
    }
    final int minValue = values.reduce((a, b) => a < b ? a : b);
    final int maxValue = values.reduce((a, b) => a > b ? a : b);
    final double start = minValue.toDouble();
    final double end = (maxValue == minValue)
        ? minValue.toDouble() + 1
        : maxValue.toDouble();
    return RangeValues(start, end);
  }

  RangeValues _rangeFromDoubles(List<double> values, RangeValues fallback) {
    if (values.isEmpty) {
      return fallback;
    }
    final double minValue = values.reduce((a, b) => a < b ? a : b);
    final double maxValue = values.reduce((a, b) => a > b ? a : b);
    final double end = (maxValue == minValue) ? minValue + 1 : maxValue;
    return RangeValues(minValue, end);
  }

  Future<void> _fetchCatalogos() async {
    try {
      final results = await Future.wait([
        _catalogosApiService.fetchCategorias(),
        _catalogosApiService.fetchFranjasHorarias(),
      ]);

      if (!mounted) {
        return;
      }

      final List<CatalogItem> categorias = results[0] as List<CatalogItem>;
      final List<FranjaHorariaItem> franjas =
          results[1] as List<FranjaHorariaItem>;

      final List<String> options = [
        'Todos',
        ...categorias.map((item) => item.name),
      ];

      setState(() {
        _categorias
          ..clear()
          ..addAll(categorias);
        _franjas
          ..clear()
          ..addAll(franjas);
        _categoryOptions = options;
        if (!_categoryOptions.contains(_selectedType)) {
          _selectedType = 'Todos';
        }
      });
    } catch (_) {
      // Keep defaults when catalogs are unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SalonViewModel> salonsToShow = _filteredSalons();

    return Scaffold(
      appBar: AppBar(title: const Text('Salones Disponibles')),
      body: Column(
        children: [
          _buildSearchRow(),
          _buildSearchSuggestions(),
          if (_showFilters) _buildFiltersPanel(),
          _buildSortAndCount(salonsToShow.length),
          Expanded(child: _buildListState(salonsToShow)),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, zona o categoria...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _runSearch,
            icon: const Icon(Icons.tune),
            label: const Text('Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentIndigo,
              foregroundColor: AppColors.bg0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final List<String> suggestions = _searchSuggestions();
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final String value = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(value),
              onPressed: () {
                _searchController.text = value;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
                _runSearch();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, color: _accentIndigo),
              const SizedBox(width: 6),
              const Text(
                'Filtros de reserva',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: _resetFilters, child: const Text('Limpiar')),
              IconButton(
                tooltip: 'Cerrar filtros',
                onPressed: () {
                  setState(() => _showFilters = false);
                },
                icon: const Icon(
                  Icons.expand_less,
                  color: AppColors.text2,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Categoria de salon',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            items: _categoryOptions
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Capacidad'),
              const Spacer(),
              Text(
                '${_capacityRange.start.round()} - ${_capacityRange.end.round()} personas',
                style: const TextStyle(color: AppColors.text3),
              ),
            ],
          ),
          RangeSlider(
            values: _capacityRange,
            min: _capacityMin,
            max: _capacityMax,
            divisions: _divisionsForStep(_capacityMin, _capacityMax, 20),
            labels: RangeLabels(
              _capacityRange.start.round().toString(),
              _capacityRange.end.round().toString(),
            ),
            onChanged: (value) => setState(() => _capacityRange = value),
          ),
          Row(
            children: [
              const Text('Precio'),
              const Spacer(),
              Text(
                '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                style: const TextStyle(color: AppColors.text3),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: _priceMin,
            max: _priceMax,
            divisions: _divisionsForStep(_priceMin, _priceMax, 1000000),
            labels: RangeLabels(
              _priceRange.start.round().toString(),
              _priceRange.end.round().toString(),
            ),
            onChanged: (value) => setState(() => _priceRange = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Solo disponibles'),
            value: _onlyAvailable,
            onChanged: (value) => setState(() => _onlyAvailable = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndCount(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            '$count resultados',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text1,
            ),
          ),
          const Spacer(),
          const Text('Ordenar: '),
          DropdownButton<String>(
            value: _selectedSort,
            items: _sortOptions
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSort = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListState(List<SalonViewModel> salonsToShow) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, _) => _loadingCard(),
      );
    }

    if (_hasError) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.wifi_off, size: 52, color: AppColors.text3),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Intenta nuevamente en unos segundos.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchSalons,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      );
    }

    if (salonsToShow.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.search_off, size: 52, color: AppColors.text3),
          const SizedBox(height: 10),
          const Text(
            'No encontramos salones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: salonsToShow.length,
      itemBuilder: (context, index) {
        final SalonViewModel salon = salonsToShow[index];
        return SalonCard(
          salon: salon,
          primaryDark: _primaryDark,
          accentIndigo: _accentIndigo,
          isFavorite: FavoritesStore.isFavorite(salon.id),
          onToggleFavorite: () {
            setState(() {
              FavoritesStore.toggle(salon.id);
            });
          },
          onReserve: () => _handleReserveTap(salon),
          onViewDetail: () {
            ActivityStore.addView(id: salon.id, name: salon.name);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SalonDetailScreen(
                  salon: salon,
                  onReserve: () => _handleReserveTap(salon),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
