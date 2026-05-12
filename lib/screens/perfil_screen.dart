import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'auth_screen.dart';
import 'favoritos_screen.dart';
import 'billetera_screen.dart';
import 'perfil_config_screen.dart';
import 'widgets/main_bottom_nav.dart';
import 'widgets/perfil/profile_action.dart';
import 'widgets/perfil/profile_header.dart';

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

  Future<bool> _ensureLoggedIn() async {
    if (AuthController.instance.isLoggedIn) {
      return true;
    }

    await _openAuth(AuthMode.login);
    return AuthController.instance.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeader(
            isLoggedIn: AuthController.instance.isLoggedIn,
            username: AuthController.instance.session?.username ?? 'Invitado',
            primaryDark: _primaryDark,
            accentIndigo: _accentIndigo,
            onLogin: () => _openAuth(AuthMode.login),
            onRegister: () => _openAuth(AuthMode.register),
            onLogout: () {
              AuthController.instance.logout();
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          ProfileActionTile(
            icon: Icons.manage_accounts,
            title: 'Configuración',
            subtitle: 'Idioma, datos personales, contraseñas y más',
            accentIndigo: _accentIndigo,
            primaryDark: _primaryDark,
            onTap: () async {
              if (!await _ensureLoggedIn()) {
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilConfigScreen()),
              );
            },
          ),
          ProfileActionTile(
            icon: Icons.account_balance_wallet,
            title: 'Mi billetera',
            subtitle: 'Métodos de pago para tus reservas',
            accentIndigo: _accentIndigo,
            primaryDark: _primaryDark,
            onTap: () async {
              if (!await _ensureLoggedIn()) {
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BilleteraScreen()),
              );
            },
          ),
          ProfileActionTile(
            icon: Icons.timeline,
            title: 'Mis favoritos',
            subtitle: 'Salones que quieres reservar más rápido',
            accentIndigo: _accentIndigo,
            primaryDark: _primaryDark,
            onTap: () async {
              if (!await _ensureLoggedIn()) {
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritosScreen()),
              );
            },
          ),
          ProfileActionTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Soporte y preguntas frecuentes',
            accentIndigo: _accentIndigo,
            primaryDark: _primaryDark,
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 4),
    );
  }
}
