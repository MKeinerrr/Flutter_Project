import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'models/reservation_history.dart';
import 'salones_screen.dart';
import 'services/historial_api_service.dart';
import 'widgets/main_bottom_nav.dart';
import 'widgets/home/home_sections.dart';

/// HomeScreen — Airbnb-inspired landing with discovery sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.username = 'Invitado'});

  final String username;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<HomeFeaturedSalon> _featuredSalons = [
    HomeFeaturedSalon(
      name: 'Salón Caribe',
      type: 'Fiestas',
      capacity: '80',
      price: r'$500.000',
      rating: '4.9',
      colorA: Color(0xFF3146B8),
      colorB: Color(0xFF5E77FF),
    ),
    HomeFeaturedSalon(
      name: 'Salón Ejecutivo',
      type: 'Corporativo',
      capacity: '50',
      price: r'$350.000',
      rating: '4.7',
      colorA: Color(0xFF3B8AA3),
      colorB: Color(0xFF7EC8E3),
    ),
    HomeFeaturedSalon(
      name: 'Vista Mar Rooftop',
      type: 'Eventos',
      capacity: '120',
      price: r'$800.000',
      rating: '5.0',
      colorA: Color(0xFF111C62),
      colorB: Color(0xFF3D3B8E),
    ),
  ];

  late final HistorialApiService _historialApiService;
  HomeNextReservationData? _nextReservation;
  bool _loadingNextReservation = true;

  @override
  void initState() {
    super.initState();
    _historialApiService = HistorialApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextReservation();
    });
  }

  Future<void> _loadNextReservation() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nextReservation = null;
        _loadingNextReservation = false;
      });
      return;
    }

    try {
      final List<ReservationHistoryItem> history = await _historialApiService
          .fetchHistory(token: token);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final List<ReservationHistoryItem> confirmedUpcoming =
          history
              .where(
                (item) =>
                    item.status == 'Confirmada' &&
                    !item.sortDate.isBefore(today),
              )
              .toList()
            ..sort((a, b) => a.sortDate.compareTo(b.sortDate));

      final ReservationHistoryItem? next = confirmedUpcoming.isEmpty
          ? null
          : confirmedUpcoming.first;

      if (!mounted) {
        return;
      }
      setState(() {
        _nextReservation = next == null
            ? null
            : HomeNextReservationData(
                salonName: next.salon,
                dateLabel: next.dateLabel,
                status: next.status,
              );
        _loadingNextReservation = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _nextReservation = null;
        _loadingNextReservation = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nextReservation = null;
        _loadingNextReservation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, ${AuthController.instance.session?.username ?? widget.username}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeroSection(
              primaryDark: _primaryDark,
              accentIndigo: _accentIndigo,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeNextReservationSection(
              primaryDark: _primaryDark,
              accentIndigo: _accentIndigo,
              isLoading: _loadingNextReservation,
              nextReservation: _nextReservation,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeFeaturedHeader(
              accentIndigo: _accentIndigo,
              primaryDark: _primaryDark,
              onViewMore: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SalonesScreen()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: HomeFeaturedSalons(
              salons: _featuredSalons,
              primaryDark: _primaryDark,
              accentIndigo: _accentIndigo,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
