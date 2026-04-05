import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';
import 'salones_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'Todas';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = 'No se pudo cargar el historial';

  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<String> _statusFilters = [
    'Todas',
    'Confirmada',
    'Completada',
    'Pendiente',
    'Cancelada',
  ];

  final List<Map<String, dynamic>> _reservations = [];

  String get _baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  String _monthNameEs(int month) {
    const List<String> names = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return names[month - 1];
  }

  String _monthLabel(DateTime value) {
    return '${_monthNameEs(value.month)} ${value.year}';
  }

  String _formatDateLabel(DateTime value, String periodo) {
    return '${value.day.toString().padLeft(2, '0')} ${_monthNameEs(value.month)} ${value.year} · $periodo';
  }

  String _normalizeStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmada':
        return 'Confirmada';
      case 'completada':
        return 'Completada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      default:
        if (status.isEmpty) {
          return 'Pendiente';
        }
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  Color _avatarColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E7D32);
      case 'Cancelada':
        return const Color(0xFFC62828);
      case 'Pendiente':
        return const Color(0xFFF57C00);
      default:
        return HistorialScreen.accentIndigo;
    }
  }

  Map<String, dynamic> _mapReservationFromApi(Map<String, dynamic> raw) {
    final String salon = (raw['salon'] as String?) ?? 'Salon';
    final String codigo = (raw['codigo'] as String?) ?? 'RES-000';
    final DateTime fecha = DateTime.tryParse('${raw['fecha']}') ?? DateTime.now();
    final String hora = (raw['hora'] as String?) ?? 'Mañana';
    final String estado = _normalizeStatus((raw['estado'] as String?) ?? 'Pendiente');

    final String trimmedSalon = salon.trim();
    final String initial = trimmedSalon.isEmpty
      ? '?'
      : trimmedSalon.substring(0, 1).toUpperCase();

    return {
      'id': codigo,
      'salon': salon,
      'initial': initial,
      'color': _avatarColor(estado),
      'date': _formatDateLabel(fecha, hora),
      'month': _monthLabel(fecha),
      'guests': _asInt(raw['asistentes']),
      'status': estado,
      'payment': 'No registrado',
      'amount': _asInt(raw['precio']),
      'notes': (raw['notas'] as String?)?.trim().isNotEmpty == true
          ? (raw['notas'] as String).trim()
          : 'Sin notas',
      'sortDate': fecha,
    };
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

    final Uri url = Uri.parse('$_baseUrl/reservas/mis');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(_requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic parsed = json.decode(response.body);
        final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];

        final List<Map<String, dynamic>> loaded = list
            .whereType<Map<String, dynamic>>()
            .map(_mapReservationFromApi)
            .toList();

        loaded.sort((a, b) {
          final DateTime aDate = a['sortDate'] as DateTime;
          final DateTime bDate = b['sortDate'] as DateTime;
          return bDate.compareTo(aDate);
        });

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
            (payload['detail'] as String?) ?? 'No se pudo cargar el historial';
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Tiempo de espera agotado. Revisa tu conexión ($_baseUrl)';
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmada':
        return Colors.blue;
      case 'Completada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Confirmada':
        return Icons.verified;
      case 'Completada':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.schedule;
      case 'Cancelada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalonesScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PerfilScreen()),
      );
    }
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

  List<Map<String, dynamic>> _filteredReservations() {
    final String query = _searchController.text.trim().toLowerCase();
    return _reservations.where((reservation) {
      final String salon = (reservation['salon'] as String).toLowerCase();
      final String id = (reservation['id'] as String).toLowerCase();
      final String status = reservation['status'] as String;

      final bool statusMatch = _selectedStatus == 'Todas' || status == _selectedStatus;
      final bool searchMatch = query.isEmpty || salon.contains(query) || id.contains(query);

      return statusMatch && searchMatch;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByMonth(List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final reservation in data) {
      final String month = reservation['month'] as String;
      grouped.putIfAbsent(month, () => <Map<String, dynamic>>[]);
      grouped[month]!.add(reservation);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthController.instance.isLoggedIn;
    final List<Map<String, dynamic>> filtered = _filteredReservations();
    final Map<String, List<Map<String, dynamic>>> grouped = _groupByMonth(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Reservas')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildSearchBar(),
          _buildStatusFilters(),
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
                            : _buildGroupedList(grouped),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: HistorialScreen.primaryDark,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar por salón o código (ej. RES-001)',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final String filter = _statusFilters[index];
          final bool selected = _selectedStatus == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              selectedColor: HistorialScreen.accentIndigo,
              labelStyle: TextStyle(
                color: selected ? Colors.white : HistorialScreen.primaryDark,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() => _selectedStatus = filter);
              },
            ),
          );
        },
      ),
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

  Widget _buildGroupedList(Map<String, List<Map<String, dynamic>>> grouped) {
    final List<String> months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: months.length,
      itemBuilder: (context, monthIndex) {
        final String month = months[monthIndex];
        final List<Map<String, dynamic>> reservations = grouped[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text(
                month,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: HistorialScreen.primaryDark,
                ),
              ),
            ),
            ...reservations.map(_reservationCard),
          ],
        );
      },
    );
  }

  Widget _reservationCard(Map<String, dynamic> reservation) {
    final String status = reservation['status'] as String;
    final Color color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: CircleAvatar(
            backgroundColor: reservation['color'] as Color,
            child: Text(
              reservation['initial'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            reservation['salon'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: HistorialScreen.primaryDark,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                reservation['date'] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                '${reservation['guests']} asistentes · ${reservation['id']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            avatar: Icon(_statusIcon(status), color: color, size: 14),
            backgroundColor: color.withAlpha(22),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          children: [
            const Divider(height: 10),
            _detailRow('Pago', reservation['payment'] as String),
            _detailRow('Valor', '\$${_formatCurrency(reservation['amount'] as int)}'),
            _detailRow('Notas', reservation['notes'] as String),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comprobante ${reservation['id']} en desarrollo')),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Comprobante'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SalonesScreen()),
                      );
                    },
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Repetir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HistorialScreen.accentIndigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: HistorialScreen.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
