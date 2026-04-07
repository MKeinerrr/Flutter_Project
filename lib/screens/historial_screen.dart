import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'models/reservation_history.dart';
import 'salones_screen.dart';
import 'services/historial_api_service.dart';
import 'widgets/historial/history_grouped_list.dart';
import 'widgets/historial/history_search_bar.dart';
import 'widgets/historial/history_status_filters.dart';
import 'widgets/main_bottom_nav.dart';

/// HistorialScreen — Searchable and filterable reservation history
/// with monthly groups and actionable reservation cards.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  static const Color primaryDark = Color(0xFF1A0A4C);
  static const Color accentIndigo = Color(0xFF3D3B8E);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<String> _statusFilters = [
    'Todas',
    'Confirmada',
    'Completada',
    'Pendiente',
    'Cancelada',
  ];

  final TextEditingController _searchController = TextEditingController();
  final List<ReservationHistoryItem> _reservations = [];

  String _selectedStatus = 'Todas';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = 'No se pudo cargar el historial';

  late final HistorialApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = HistorialApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = false;
        _errorMessage = 'No se pudo cargar el historial';
        _reservations.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = 'No se pudo cargar el historial';
    });

    try {
      final List<ReservationHistoryItem> loaded = await _apiService.fetchHistory(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reservations
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

  Future<void> _openLogin() async {
    final bool? didLogin = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.login,
          title: 'Accede para ver tu historial',
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (didLogin == true && AuthController.instance.isLoggedIn) {
      await _fetchHistory();
    }
  }

  List<ReservationHistoryItem> _filteredReservations() {
    final String query = _searchController.text.trim().toLowerCase();
    return _reservations.where((reservation) {
      final bool statusMatch =
          _selectedStatus == 'Todas' || reservation.status == _selectedStatus;
      final bool searchMatch =
          query.isEmpty ||
          reservation.salon.toLowerCase().contains(query) ||
          reservation.id.toLowerCase().contains(query);

      return statusMatch && searchMatch;
    }).toList();
  }

  Map<String, List<ReservationHistoryItem>> _groupByMonth(
    List<ReservationHistoryItem> data,
  ) {
    final Map<String, List<ReservationHistoryItem>> grouped = {};
    for (final reservation in data) {
      grouped.putIfAbsent(reservation.month, () => <ReservationHistoryItem>[]);
      grouped[reservation.month]!.add(reservation);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthController.instance.isLoggedIn;
    final List<ReservationHistoryItem> filtered = _filteredReservations();
    final Map<String, List<ReservationHistoryItem>> grouped =
        _groupByMonth(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Reservas')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          HistorySearchBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          HistoryStatusFilters(
            filters: _statusFilters,
            selected: _selectedStatus,
            onSelect: (value) {
              setState(() => _selectedStatus = value);
            },
            primaryDark: HistorialScreen.primaryDark,
            accentIndigo: HistorialScreen.accentIndigo,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Text(
              'Mis Reservas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistorialScreen.primaryDark,
              ),
            ),
          ),
          Expanded(
            child: !isLoggedIn
                ? _buildGuestState()
                : _isLoading
                    ? _buildLoadingState()
                    : _hasError
                        ? _buildErrorState()
                        : filtered.isEmpty
                            ? _buildEmptyState()
                            : HistoryGroupedList(
                                grouped: grouped,
                                primaryDark: HistorialScreen.primaryDark,
                                accentIndigo: HistorialScreen.accentIndigo,
                                onReceiptTap: (reservation) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Comprobante ${reservation.id} en desarrollo',
                                      ),
                                    ),
                                  );
                                },
                                onRepeatTap: (_) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SalonesScreen(),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (_, _) {
        return Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off, size: 58, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'No encontramos reservas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = 'Todas';
                  _searchController.clear();
                });
              },
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Inicia sesión para ver tu historial de reservas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openLogin,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HistorialScreen.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _fetchHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
