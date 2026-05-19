import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpItem(
            question: 'Como reservo un salon?',
            answer:
                'Entra a Salones, elige uno, ajusta fecha y franja horaria, y confirma la reserva.',
          ),
          _HelpItem(
            question: 'No veo mi reserva, que hago?',
            answer:
                'Verifica que hayas iniciado sesion y que la reserva no este cancelada.',
          ),
          _HelpItem(
            question: 'Como cancelo una reserva?',
            answer:
                'Ve a Mi reserva y usa el boton Cancelar reserva si esta Pendiente o Confirmada.',
          ),
          _HelpItem(
            question: 'Como agrego metodos de pago?',
            answer:
                'En Perfil > Mi billetera puedes registrar tus metodos para futuras reservas.',
          ),
          _HelpItem(
            question: 'Problemas con fotos o contenido?',
            answer:
                'Intenta recargar la pantalla y verifica tu conexion. Si el problema persiste, contacta soporte.',
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Text(
            answer,
            style: const TextStyle(color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}
