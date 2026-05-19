import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';
import 'models/mi_reserva_view_model.dart';
import 'models/rating_state.dart';
import 'models/reservation_history.dart';
import 'services/historial_api_service.dart';
import 'services/mi_reserva_service.dart';
import 'services/salones_api_service.dart';
import 'widgets/main_bottom_nav.dart';
import 'widgets/mi_reserva/mi_reserva_detail.dart';
import 'widgets/mi_reserva/mi_reserva_multiple.dart';
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
  List<ReservationHistoryItem> _activeReservations = [];
  bool _isLoading = true;
  String? _error;
  bool _isSubmittingRating = false;
  bool _isCancelling = false;
  final Map<int, RatingState> _submittedRatings = {};

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
      final List<ReservationHistoryItem> activeReservations =
          await _miReservaService.fetchActiveReservations(
        token: token,
      );

      if (!mounted) {
        return;
      }

      if (activeReservations.isEmpty) {
        setState(() {
          _viewModel = null;
          _activeReservations = [];
          _isLoading = false;
        });
        return;
      }

      if (activeReservations.length == 1) {
        final MiReservaViewModel viewModel =
            await _miReservaService.buildViewModel(
          reservation: activeReservations.first,
          token: token,
        );
        await _loadRatingState(viewModel.salon.id);
        if (!mounted) {
          return;
        }
        setState(() {
          _viewModel = viewModel;
          _activeReservations = activeReservations;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _viewModel = null;
        _activeReservations = activeReservations;
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

  Future<void> _submitRating(int salonId, int score, String comment) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return;
    }

    if (_submittedRatings.containsKey(salonId)) {
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      await _salonesApiService.submitRating(
        token: token,
        salonId: salonId,
        score: score,
        comment: comment,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificacion registrada')),
      );
      setState(() {
        _submittedRatings[salonId] = RatingState(
          score: score,
          comment: comment,
        );
      });
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
    final bool hasMultipleReservations = _activeReservations.length > 1;
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
          : hasMultipleReservations
          ? MiReservaMultipleList(
              reservations: _activeReservations,
              accentIndigo: _accentIndigo,
              onOpenReservation: _openReservationDetail,
            )
          : _viewModel == null
          ? const MiReservaNoReservationState()
          : MiReservaDetail(
              data: _viewModel!,
              primaryDark: _primaryDark,
              accentIndigo: _accentIndigo,
              isSubmittingRating: _isSubmittingRating,
              ratingState: _submittedRatings[_viewModel!.salon.id],
              onSubmitRating: (score, comment) =>
                  _submitRating(_viewModel!.salon.id, score, comment),
            ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }

  Future<void> _openReservationDetail(ReservationHistoryItem reservation) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final MiReservaViewModel viewModel =
          await _miReservaService.buildViewModel(
        reservation: reservation,
        token: token,
      );
      await _loadRatingState(viewModel.salon.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });

      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => _ReservationDetailScreen(
            data: viewModel,
            primaryDark: _primaryDark,
            accentIndigo: _accentIndigo,
            isSubmittingRating: _isSubmittingRating,
            ratingState: _submittedRatings[viewModel.salon.id],
            onSubmitRating: (score, comment) =>
                _submitRating(viewModel.salon.id, score, comment),
            onCancelReservation: () async {
              final bool success =
                  await _cancelReservation(reservation.reservationId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = 'No se pudo cargar tu reserva';
      });
    }
  }

  Future<void> _loadRatingState(int salonId) async {
    if (_submittedRatings.containsKey(salonId)) {
      return;
    }

    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final RatingState? rating = await _salonesApiService.fetchMyRating(
        token: token,
        salonId: salonId,
      );
      if (rating != null && mounted) {
        setState(() {
          _submittedRatings[salonId] = rating;
        });
      }
    } catch (_) {
      // Ignore rating fetch errors to avoid blocking UI.
    }
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text ('Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _cancelReservation(model.reservation.reservationId);
  }

  Future<bool> _cancelReservation(int reservationId) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      return false;
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
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada')),
      );
      await _loadReservation();
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'No se pudo cancelar' : message)),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
    return false;
  }
}

class _ReservationDetailScreen extends StatefulWidget {
  const _ReservationDetailScreen({
    required this.data,
    required this.primaryDark,
    required this.accentIndigo,
    required this.isSubmittingRating,
    required this.ratingState,
    required this.onSubmitRating,
    required this.onCancelReservation,
  });

  final MiReservaViewModel data;
  final Color primaryDark;
  final Color accentIndigo;
  final bool isSubmittingRating;
  final RatingState? ratingState;
  final Future<void> Function(int score, String comment) onSubmitRating;
  final Future<void> Function() onCancelReservation;

  @override
  State<_ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<_ReservationDetailScreen> {
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    setState(() {
      _isCancelling = true;
    });

    await widget.onCancelReservation();
    if (!mounted) {
      return;
    }

    setState(() {
      _isCancelling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canCancel =
        widget.data.reservation.status == 'Pendiente' ||
            widget.data.reservation.status == 'Confirmada';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi reserva'),
        actions: [
          if (canCancel)
            TextButton(
              onPressed: _isCancelling ? null : _handleCancel,
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
      body: MiReservaDetail(
        data: widget.data,
        primaryDark: widget.primaryDark,
        accentIndigo: widget.accentIndigo,
        isSubmittingRating: widget.isSubmittingRating,
        ratingState: widget.ratingState,
        onSubmitRating: widget.onSubmitRating,
      ),
    );
  }
}
