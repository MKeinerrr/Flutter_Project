import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../models/catalog_item.dart';
import '../../models/reservation_request.dart';

class ReservationBottomSheet extends StatefulWidget {
  const ReservationBottomSheet({
    super.key,
    required this.salonName,
    required this.salonCapacity,
    required this.franjas,
    required this.metodos,
    required this.onSubmit,
  });

  final String salonName;
  final int salonCapacity;
  final List<FranjaHorariaItem> franjas;
  final List<MetodoPagoItem> metodos;
  final Future<String> Function(ReservationRequest request) onSubmit;

  @override
  State<ReservationBottomSheet> createState() => _ReservationBottomSheetState();
}

class _ReservationBottomSheetState extends State<ReservationBottomSheet> {
  static const Color _accentIndigo = AppColors.accent;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  int? _selectedFranjaId;
  int? _selectedMetodoId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.franjas.isNotEmpty) {
      _selectedFranjaId = widget.franjas.first.id;
    }
    if (widget.metodos.isNotEmpty) {
      _selectedMetodoId = widget.metodos.first.id;
    }
  }

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

    if (_selectedFranjaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una franja horaria')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final String code = await widget.onSubmit(
        ReservationRequest(
          fecha: _selectedDate!,
          franjaHorariaId: _selectedFranjaId!,
          asistentes: int.parse(_attendeesController.text.trim()),
          notas: _notesController.text.trim(),
          metodoId: _selectedMetodoId,
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
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();
      final bool isDuplicateReservation = message
          .toLowerCase()
          .contains('ya existe una reserva');
      if (isDuplicateReservation) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reserva no disponible'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
              DropdownButtonFormField<int>(
                initialValue: _selectedFranjaId,
                decoration: const InputDecoration(
                  labelText: 'Franja horaria',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Sin franjas disponibles'),
                items: widget.franjas
                    .map(
                      (franja) => DropdownMenuItem(
                        value: franja.id,
                        child: Text(franja.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedFranjaId = value),
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
              Text(
                'Metodo de pago',
                style: TextStyle(
                  color: AppColors.text2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.metodos
                    .map(
                      (metodo) => ChoiceChip(
                        label: Text(metodo.name),
                        selected: _selectedMetodoId == metodo.id,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedMetodoId = metodo.id);
                          }
                        },
                      ),
                    )
                    .toList(),
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
                    foregroundColor: AppColors.bg0,
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
