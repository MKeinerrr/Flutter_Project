import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';
import 'models/mi_reserva_view_model.dart';
import 'services/historial_api_service.dart';
import 'services/mi_reserva_service.dart';
import 'services/salones_api_service.dart';
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
  static const Color _primaryDark = AppColors.bg1;
  static const Color _accentIndigo = AppColors.accent;

  late final MiReservaService _miReservaService;
  late final SalonesApiService _salonesApiService;

  MiReservaViewModel? _viewModel;
  bool _isLoading = true;
  String? _error;
  bool _isSubmittingRating = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _miReservaService = MiReservaService(
      historialApiService: HistorialApiService(
        baseUrl: ApiConfig.baseUrl,
        requestTimeout: _requestTimeout,
      ),
      salonesApiService: SalonesApiService(
        baseUrl: ApiConfig.baseUrl,
        requestTimeout: _requestTimeout,
      ),
    );
    _salonesApiService = SalonesApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
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

      if (activeReservation == null) {
        setState(() {
          _viewModel = null;
          _isLoading = false;
        });
        return;
      }

      final MiReservaViewModel viewModel =
          await _miReservaService.buildViewModel(
        reservation: activeReservation,
        token: token,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _viewModel = viewModel;
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

  Future<void> _submitRating(int score, String comment) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return;
    }
    final MiReservaViewModel? model = _viewModel;
    if (model == null) {
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      await _salonesApiService.submitRating(
        token: token,
        salonId: model.salon.id,
        score: score,
        comment: comment,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificacion registrada')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'No se pudo calificar' : message)),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmittingRating = false;
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
    final bool canCancel = _viewModel != null &&
        (_viewModel!.reservation.status == 'Pendiente' ||
            _viewModel!.reservation.status == 'Confirmada');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi reserva'),
        actions: [
          if (canCancel)
            TextButton(
              onPressed: _isCancelling ? null : _confirmCancel,
              child: Text(
                _isCancelling ? 'Cancelando...' : 'Cancelar reserva',
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
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
              isSubmittingRating: _isSubmittingRating,
              onSubmitRating: _submitRating,
            ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }

  Future<void> _confirmCancel() async {
    final MiReservaViewModel? model = _viewModel;
    if (model == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('Esta accion no se puede deshacer. Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _cancelReservation(model.reservation.reservationId);
  }

  Future<void> _cancelReservation(int reservationId) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await _salonesApiService.cancelReservation(
        token: token,
        reservationId: reservationId,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada')),
      );
      await _loadReservation();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'No se pudo cancelar' : message)),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCancelling = false;
      });
    }
  }
}
