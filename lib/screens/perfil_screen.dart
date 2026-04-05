import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'salones_screen.dart';
import 'historial_screen.dart';

/// PerfilScreen — Guest profile page with auth actions and account shortcuts.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const Color _primaryDark = Color(0xFF1A0A4C);
  static const Color _accentIndigo = Color(0xFF3D3B8E);

  Future<void> _openAuth(AuthMode mode) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(initialMode: mode, title: 'Tu perfil'),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildActionTile(
            icon: Icons.event_note,
            title: 'Mis reservas',
            subtitle: 'Consulta y administra tus reservas',
            onTap: () {
              if (!AuthController.instance.isLoggedIn) {
                _openAuth(AuthMode.login);
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tus reservas estarán aquí pronto'),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.account_balance_wallet,
            title: 'Mi billetera',
            subtitle: 'Métodos de pago y saldo disponible',
            onTap: () {},
          ),
          _buildActionTile(
            icon: Icons.timeline,
            title: 'Mi actividad',
            subtitle: 'Revisa tus movimientos recientes',
            onTap: () {},
          ),
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Soporte y preguntas frecuentes',
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SalonesScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HistorialScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Salones'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final bool isLoggedIn = AuthController.instance.isLoggedIn;
    final String username =
        AuthController.instance.session?.username ?? 'Invitado';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accentIndigo.withAlpha(60), width: 2),
              color: Colors.grey[100],
            ),
            child: const Icon(
              Icons.person_outline,
              size: 38,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Perfil de $username' : 'Perfil de invitado',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLoggedIn
                      ? 'Ya puedes reservar y administrar tu cuenta'
                      : 'Inicia sesión o regístrate para gestionar tu cuenta',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (!isLoggedIn)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _openAuth(AuthMode.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                      OutlinedButton(
                        onPressed: () => _openAuth(AuthMode.register),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _accentIndigo,
                          side: const BorderSide(color: _accentIndigo),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      AuthController.instance.logout();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _accentIndigo.withAlpha(22),
          child: Icon(icon, color: _accentIndigo),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _primaryDark,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
