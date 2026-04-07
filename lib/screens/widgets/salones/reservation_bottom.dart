import 'package:flutter/material.dart';
import '../../models/reservation_request.dart';

class ReservationBottomSheet extends StatefulWidget {
  const ReservationBottomSheet({
    super.key,
    required this.salonName,
    required this.salonCapacity,
    required this.onSubmit,
  });

  final String salonName;
  final int salonCapacity;
  final Future<String> Function(ReservationRequest request) onSubmit;

  @override
  State<ReservationBottomSheet> createState() => _ReservationBottomSheetState();
}

class _ReservationBottomSheetState extends State<ReservationBottomSheet> {
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
        ReservationRequest(
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
