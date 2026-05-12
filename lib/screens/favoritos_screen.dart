import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'models/salon_view_model.dart';
import 'services/salones_api_service.dart';
import 'utils/favorites_store.dart';
import 'widgets/salones/salon_card.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static const Duration _requestTimeout = Duration(seconds: 12);

  late final SalonesApiService _apiService;
  List<SalonViewModel> _salons = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = SalonesApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Debes iniciar sesion';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<SalonViewModel> loaded = await _apiService.fetchSalons(
        token: token,
      );
      final Set<int> favorites = FavoritesStore.favorites.value;
      if (!mounted) {
        return;
      }
      setState(() {
        _salons = loaded.where((salon) => favorites.contains(salon.id)).toList();
        _loading = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Tiempo de espera agotado';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'No se pudieron cargar los favoritos';
      });
    }
  }

  Future<void> _openLogin() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.login,
          title: 'Inicia sesion para continuar',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ValueListenableBuilder<Set<int>>(
                  valueListenable: FavoritesStore.favorites,
                  builder: (context, favorites, _) {
                    final List<SalonViewModel> visible = _salons
                        .where((salon) => favorites.contains(salon.id))
                        .toList();

                    if (visible.isEmpty) {
                      return Center(
                        child: Text(
                          'Aun no tienes favoritos',
                          style: TextStyle(
                            color: _primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final salon = visible[index];
                        return SalonCard(
                          salon: salon,
                          primaryDark: _primaryDark,
                          accentIndigo: _accentIndigo,
                          isFavorite: favorites.contains(salon.id),
                          onToggleFavorite: () {
                            FavoritesStore.toggle(salon.id);
                          },
                          onReserve: () async {
                            if (!AuthController.instance.isLoggedIn) {
                              await _openLogin();
                            }
                          },
                          onViewDetail: () {},
                        );
                      },
                    );
                  },
                ),
    );
  }
}
