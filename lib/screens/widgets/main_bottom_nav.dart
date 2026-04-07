import 'package:flutter/material.dart';

import '../historial_screen.dart';
import '../home_screen.dart';
import '../mi_reserva_screen.dart';
import '../perfil_screen.dart';
import '../salones_screen.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
      case 1:
        destination = const SalonesScreen();
      case 2:
        destination = const MiReservaScreen();
      case 3:
        destination = const HistorialScreen();
      case 4:
        destination = const PerfilScreen();
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A0A4C),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Mi reserva'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
