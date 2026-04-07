import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import 'auth_screen.dart';
import 'models/mi_reserva_view_model.dart';
import 'services/historial_api_service.dart';
import 'services/mi_reserva_service.dart';
import 'widgets/main_bottom_nav.dart';
import 'widgets/mi_reserva/mi_reserva_detail.dart';
import 'widgets/mi_reserva/mi_reserva_states.dart';

class MiReservaScreen extends StatefulWidget {
  const MiReservaScreen({super.key});

  @override
  State<MiReservaScreen> createState() => _MiReservaScreenState();
}

class _MiReservaScreenState extends State<MiReservaScreen> {
  static const Duration _requestTimeout = Duration(seconds: 12);
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);

  late final MiReservaService _miReservaService;

  MiReservaViewModel? _viewModel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _miReservaService = MiReservaService(
      historialApiService: HistorialApiService(
        baseUrl: ApiConfig.baseUrl,
        requestTimeout: _requestTimeout,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservation();
    });
  }

  Future<void> _loadReservation() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _viewModel = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activeReservation = await _miReservaService.fetchActiveReservation(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _viewModel = activeReservation == null
            ? null
            : _miReservaService.buildViewModel(activeReservation);
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Tiempo de espera agotado';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No se pudo cargar tu reserva';
        _isLoading = false;
      });
    }
  }

  Future<void> _openLogin() async {
    final bool? didLogin = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.login,
          title: 'Accede para ver tu reserva',
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (didLogin == true && AuthController.instance.isLoggedIn) {
      await _loadReservation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi reserva')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? MiReservaErrorState(message: _error!, onRetry: _loadReservation)
          : !AuthController.instance.isLoggedIn
          ? MiReservaGuestState(onLogin: _openLogin)
          : _viewModel == null
          ? const MiReservaNoReservationState()
          : MiReservaDetail(
              data: _viewModel!,
              primaryDark: _primaryDark,
              accentIndigo: _accentIndigo,
            ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }
}
