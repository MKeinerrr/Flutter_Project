import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'models/reservation_request.dart';
import 'models/salon_view_model.dart';
import 'services/salones_api_service.dart';
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
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<String> _types = [
    'Todos',
    'Fiestas',
    'Corporativo',
    'Reuniones',
    'Conferencias',
  ];

  static const List<String> _sortOptions = [
    'Mejor calificacion',
    'Menor precio',
    'Mayor capacidad',
    'Mas cercano',
  ];

  final TextEditingController _searchController = TextEditingController();

  bool _showFilters = false;
  bool _onlyAvailable = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = 'No se pudo cargar la búsqueda';

  String _selectedType = 'Todos';
  String _selectedSort = 'Mejor calificacion';
  RangeValues _capacityRange = const RangeValues(20, 200);
  RangeValues _priceRange = const RangeValues(300000, 1300000);

  late final SalonesApiService _apiService;
  final List<SalonViewModel> _salons = [];

  @override
  void initState() {
    super.initState();
    _apiService = SalonesApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      setState(() {
        _salons
          ..clear()
          ..addAll(loaded);
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

    final String? code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReservationBottomSheet(
        salonName: salon.name,
        salonCapacity: salon.capacity,
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
      _capacityRange = const RangeValues(20, 200);
      _priceRange = const RangeValues(300000, 1300000);
    });
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
                hintText: 'Buscar por nombre, zona o tipo...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
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
            label: const Text('Buscar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentIndigo,
              foregroundColor: Colors.white,
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
        color: Colors.white,
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
                  color: _primaryDark,
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
                  color: Color.fromARGB(255, 26, 26, 61),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo de salon',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            items: _types
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
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          RangeSlider(
            values: _capacityRange,
            min: 20,
            max: 250,
            divisions: 23,
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
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 200000,
            max: 1500000,
            divisions: 13,
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
              color: _primaryDark,
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
          const Icon(Icons.wifi_off, size: 52, color: Colors.grey),
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
          const Icon(Icons.search_off, size: 52, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'No encontramos salones con esos filtros',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
                _resetFilters();
              },
              child: const Text('Limpiar filtros'),
            ),
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
          onReserve: () => _handleReserveTap(salon),
          onViewDetail: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detalle de ${salon.name} en desarrollo')),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
