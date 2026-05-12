import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'models/reservation_history.dart';
import 'models/salon_view_model.dart';
import 'salones_screen.dart';
import 'services/salones_api_service.dart';
import 'services/historial_api_service.dart';
import 'utils/screen_formatters.dart';
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

  late final HistorialApiService _historialApiService;
  late final SalonesApiService _salonesApiService;
  HomeNextReservationData? _nextReservation;
  bool _loadingNextReservation = true;
  bool _loadingFeaturedSalons = true;
  String? _featuredError;
  List<HomeFeaturedSalon> _featuredSalons = [];

  @override
  void initState() {
    super.initState();
    _historialApiService = HistorialApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    _salonesApiService = SalonesApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextReservation();
      _loadFeaturedSalons();
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

  Future<void> _loadFeaturedSalons() async {
    setState(() {
      _loadingFeaturedSalons = true;
      _featuredError = null;
    });

    try {
      final List<SalonViewModel> salons = await _salonesApiService.fetchSalons();
      final List<HomeFeaturedSalon> mapped = salons
          .take(6)
          .map(
            (salon) => HomeFeaturedSalon(
              id: salon.id,
              name: salon.name,
              type: salon.category,
              capacity: '${salon.capacity}',
              price: r'$' + ScreenFormatters.formatCurrency(salon.price),
              rating: salon.rating.toStringAsFixed(1),
              colorA: salon.colorA,
              colorB: salon.colorB,
            ),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _featuredSalons = mapped;
        _loadingFeaturedSalons = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _featuredError = 'Tiempo de espera agotado';
        _loadingFeaturedSalons = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _featuredError = 'No se pudieron cargar los salones recomendados';
        _loadingFeaturedSalons = false;
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
            child: _loadingFeaturedSalons
                ? const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _featuredSalons.isEmpty
                ? HomeFeaturedEmpty(
                    message: _featuredError ?? 'Aun no hay salones recomendados',
                    accentIndigo: _accentIndigo,
                    primaryDark: _primaryDark,
                    onRetry: _loadFeaturedSalons,
                  )
                : HomeFeaturedSalons(
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
