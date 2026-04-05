import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'historial_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';

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

  final TextEditingController _searchController = TextEditingController();

  bool _showFilters = false;
  bool _onlyAvailable = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = 'No se pudo cargar la búsqueda';

  DateTime? _selectedDate;
  String _selectedTime = 'Cualquiera';
  String _selectedType = 'Todos';
  String _selectedSort = 'Mejor calificacion';
  RangeValues _capacityRange = const RangeValues(20, 200);
  RangeValues _priceRange = const RangeValues(300000, 1300000);

  static const List<String> _types = [
    'Todos',
    'Fiestas',
    'Corporativo',
    'Reuniones',
    'Conferencias',
  ];

  static const List<String> _timeOptions = [
    'Cualquiera',
    'Mañana',
    'Tarde',
    'Noche',
  ];

  static const List<String> _sortOptions = [
    'Mejor calificacion',
    'Menor precio',
    'Mayor capacidad',
    'Mas cercano',
  ];

  static const Duration _requestTimeout = Duration(seconds: 12);
  final List<Map<String, dynamic>> _salons = [];

  String get _baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSalons();
    });
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

    final Uri url = Uri.parse('$_baseUrl/salones');

    try {
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(_requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic parsed = json.decode(response.body);
        final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];

        final List<Map<String, dynamic>> loaded = list
            .whereType<Map<String, dynamic>>()
            .map(_mapSalonFromApi)
            .toList();

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
        return;
      }

      final dynamic parsed = json.decode(response.body);
      final Map<String, dynamic> payload = parsed is Map<String, dynamic>
          ? parsed
          : <String, dynamic>{};

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            (payload['detail'] as String?) ?? 'No se pudo cargar la búsqueda';
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Tiempo de espera agotado. Revisa tu conexión ($_baseUrl)';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No se pudo conectar con el servidor';
      });
    }
  }

  Map<String, Color> _resolveTypeColors(String type) {
    switch (type) {
      case 'Corporativo':
        return const {'colorA': Color(0xFF3B8AA3), 'colorB': Color(0xFF7EC8E3)};
      case 'Conferencias':
        return const {'colorA': Color(0xFF522B8A), 'colorB': Color(0xFF8A61C7)};
      case 'Reuniones':
        return const {'colorA': Color(0xFF27585A), 'colorB': Color(0xFF4AA1A6)};
      default:
        return const {'colorA': Color(0xFF3146B8), 'colorB': Color(0xFF5E77FF)};
    }
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? fallback;
  }

  Map<String, dynamic> _mapSalonFromApi(Map<String, dynamic> raw) {
    final String type = (raw['tipo'] as String?) ?? 'Fiestas';
    final Map<String, Color> colors = _resolveTypeColors(type);
    final dynamic badgesRaw = raw['badges'];

    final List<String> badges = badgesRaw is List<dynamic>
        ? badgesRaw.map((badge) => '$badge').toList()
        : const [];

    return {
      'id': _asInt(raw['id']),
      'name': (raw['nombre'] as String?) ?? '',
      'zone': (raw['zona'] as String?) ?? '',
      'capacity': _asInt(raw['capacidad']),
      'price': _asInt(raw['precio']),
      'type': type,
      'available': raw['disponible'] == true,
      'rating': _asDouble(raw['calificacion']),
      'distance': _asDouble(raw['distancia_km']),
      'badges': badges,
      'colorA': colors['colorA'],
      'colorB': colors['colorB'],
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistorialScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PerfilScreen()),
      );
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

  Future<void> _handleReserveTap(Map<String, dynamic> salon) async {
    final bool authenticated = await _ensureAuthenticated();
    if (!mounted || !authenticated) {
      return;
    }

    final String? code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReservationBottomSheet(
        salonName: salon['name'] as String,
        salonCapacity: salon['capacity'] as int,
        onSubmit: (request) => _createReservation(
          salonId: salon['id'] as int,
          fecha: request.fecha,
          hora: request.hora,
          asistentes: request.asistentes,
          notas: request.notas,
        ),
      ),
    );

    if (!mounted || code == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reserva confirmada: $code')));
  }

  String _formatDateForApi(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<String> _createReservation({
    required int salonId,
    required DateTime fecha,
    required String hora,
    required int asistentes,
    required String? notas,
  }) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para reservar');
    }

    final Uri url = Uri.parse('$_baseUrl/reservas');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'salon_id': salonId,
            'fecha': _formatDateForApi(fecha),
            'hora': hora,
            'asistentes': asistentes,
            'notas': (notas?.trim().isNotEmpty ?? false) ? notas!.trim() : null,
          }),
        )
        .timeout(_requestTimeout);

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final String code = (payload['codigo'] as String?) ?? '';
      if (code.isNotEmpty) {
        return code;
      }
      final int id = _asInt(payload['id']);
      return 'RES-${id.toString().padLeft(3, '0')}';
    }

    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo confirmar la reserva',
    );
  }

  String _formatCurrency(int value) {
    final String text = value.toString();
    final StringBuffer out = StringBuffer();
    int count = 0;
    for (int i = text.length - 1; i >= 0; i--) {
      out.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        out.write('.');
      }
    }
    return out.toString().split('').reversed.join();
  }

  List<String> _searchSuggestions() {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    final Set<String> suggestions = <String>{};
    for (final salon in _salons) {
      final String name = (salon['name'] as String);
      final String zone = (salon['zone'] as String);
      final String type = (salon['type'] as String);

      if (name.toLowerCase().contains(query)) {
        suggestions.add(name);
      }
      if (zone.toLowerCase().contains(query)) {
        suggestions.add(zone);
      }
      if (type.toLowerCase().contains(query)) {
        suggestions.add(type);
      }
    }

    return suggestions.take(4).toList();
  }

  List<Map<String, dynamic>> _filteredSalons() {
    final String query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> result = _salons.where((salon) {
      final String name = (salon['name'] as String).toLowerCase();
      final String zone = (salon['zone'] as String).toLowerCase();
      final String type = (salon['type'] as String).toLowerCase();

      final int capacity = salon['capacity'] as int;
      final int price = salon['price'] as int;
      final bool available = salon['available'] as bool;

      final bool queryMatch =
          query.isEmpty ||
          name.contains(query) ||
          zone.contains(query) ||
          type.contains(query);
      final bool typeMatch =
          _selectedType == 'Todos' || salon['type'] == _selectedType;
      final bool availabilityMatch = !_onlyAvailable || available;
      final bool capacityMatch =
          capacity >= _capacityRange.start.round() &&
          capacity <= _capacityRange.end.round();
      final bool priceMatch =
          price >= _priceRange.start.round() &&
          price <= _priceRange.end.round();

      return queryMatch &&
          typeMatch &&
          availabilityMatch &&
          capacityMatch &&
          priceMatch;
    }).toList();

    result.sort((a, b) {
      if (_selectedSort == 'Menor precio') {
        return (a['price'] as int).compareTo(b['price'] as int);
      }
      if (_selectedSort == 'Mayor capacidad') {
        return (b['capacity'] as int).compareTo(a['capacity'] as int);
      }
      if (_selectedSort == 'Mas cercano') {
        return (a['distance'] as double).compareTo(b['distance'] as double);
      }
      return (b['rating'] as double).compareTo(a['rating'] as double);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> salonsToShow = _filteredSalons();

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                    _selectedTime = 'Cualquiera';
                    _selectedType = 'Todos';
                    _onlyAvailable = false;
                    _capacityRange = const RangeValues(20, 200);
                    _priceRange = const RangeValues(300000, 1300000);
                  });
                },
                child: const Text('Limpiar'),
              ),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                      initialDate: _selectedDate ?? now,
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate == null
                        ? 'Fecha'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedTime,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                  ),
                  items: _timeOptions
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTime = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                '\$${_formatCurrency(_priceRange.start.round())} - \$${_formatCurrency(_priceRange.end.round())}',
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
              _formatCurrency(_priceRange.start.round()),
              _formatCurrency(_priceRange.end.round()),
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

  Widget _buildListState(List<Map<String, dynamic>> salonsToShow) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, _) => _loadingCard(),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 52, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text('Intenta nuevamente en unos segundos.'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _fetchSalons,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (salonsToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 52, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'No encontramos salones con esos filtros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedType = 'Todos';
                    _onlyAvailable = false;
                    _capacityRange = const RangeValues(20, 200);
                    _priceRange = const RangeValues(300000, 1300000);
                  });
                },
                child: const Text('Limpiar filtros'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: salonsToShow.length,
      itemBuilder: (context, index) => _salonCard(salonsToShow[index]),
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

  Widget _salonCard(Map<String, dynamic> salon) {
    final bool available = salon['available'] as bool;
    final String price = _formatCurrency(salon['price'] as int);
    final List<dynamic> badges = salon['badges'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 116,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [salon['colorA'] as Color, salon['colorB'] as Color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          salon['type'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Desde \$$price',
                          style: const TextStyle(
                            color: _accentIndigo,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (salon['rating'] as double).toStringAsFixed(1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: available ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          available ? 'Disponible hoy' : 'No disponible',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon['name'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${salon['zone']} · ${(salon['distance'] as double).toStringAsFixed(1)} km',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${salon['capacity']} personas',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: badges
                      .map(
                        (badge) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge as String,
                            style: const TextStyle(
                              color: _accentIndigo,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: available
                            ? () {
                                _handleReserveTap(salon);
                              }
                            : null,
                        icon: const Icon(Icons.bolt),
                        label: const Text('Reservar ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentIndigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Detalle de ${salon['name']} en desarrollo',
                              ),
                            ),
                          );
                        },
                        child: const Text('Ver detalle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationRequest {
  const _ReservationRequest({
    required this.fecha,
    required this.hora,
    required this.asistentes,
    this.notas,
  });

  final DateTime fecha;
  final String hora;
  final int asistentes;
  final String? notas;
}

class _ReservationBottomSheet extends StatefulWidget {
  const _ReservationBottomSheet({
    required this.salonName,
    required this.salonCapacity,
    required this.onSubmit,
  });

  final String salonName;
  final int salonCapacity;
  final Future<String> Function(_ReservationRequest request) onSubmit;

  @override
  State<_ReservationBottomSheet> createState() =>
      _ReservationBottomSheetState();
}

class _ReservationBottomSheetState extends State<_ReservationBottomSheet> {
  static const Color _accentIndigo = Color(0xFF3D3B8E);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedHora = 'Mañana';
  bool _submitting = false;

  @override
  void dispose() {
    _attendeesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _submit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una fecha para la reserva')),
        );
      }
      return;
    }

    setState(() => _submitting = true);

    try {
      final String code = await widget.onSubmit(
        _ReservationRequest(
          fecha: _selectedDate!,
          hora: _selectedHora,
          asistentes: int.parse(_attendeesController.text.trim()),
          notas: _notesController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, code);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reserva en ${widget.salonName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : _formatDate(_selectedDate!),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedHora,
                decoration: const InputDecoration(
                  labelText: 'Franja horaria',
                  border: OutlineInputBorder(),
                ),
                items: const ['Mañana', 'Tarde', 'Noche']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedHora = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _attendeesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Asistentes (max ${widget.salonCapacity})',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final int? attendees = int.tryParse((value ?? '').trim());
                  if (attendees == null || attendees <= 0) {
                    return 'Ingresa un número válido de asistentes';
                  }
                  if (attendees > widget.salonCapacity) {
                    return 'No puede superar la capacidad del salón';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _submitting ? 'Confirmando...' : 'Confirmar reserva',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
