import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.isLoggedIn,
    required this.username,
    required this.primaryDark,
    required this.accentIndigo,
    required this.onLogin,
    required this.onRegister,
    required this.onLogout,
  });

  final bool isLoggedIn;
  final String username;
  final Color primaryDark;
  final Color accentIndigo;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
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
              border: Border.all(color: accentIndigo.withAlpha(60), width: 2),
              color: AppColors.bg3,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 38,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Perfil de $username' : 'Perfil de invitado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLoggedIn
                      ? 'Ya puedes reservar y administrar tu cuenta'
                      : 'Inicia sesión o regístrate para gestionar tu cuenta',
                  style: const TextStyle(color: AppColors.text2),
                ),
                const SizedBox(height: 12),
                if (!isLoggedIn)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.bg0,
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                      OutlinedButton(
                        onPressed: onRegister,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(color: AppColors.accent),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onLogout,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.bg0,
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
}
