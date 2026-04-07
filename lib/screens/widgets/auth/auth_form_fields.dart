import 'package:flutter/material.dart';
import '../../auth_screen.dart';

class AuthFormFields extends StatelessWidget {
  const AuthFormFields({
    super.key,
    required this.mode,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.usernameValidator,
    required this.passwordValidator,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
  });

  final AuthMode mode;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? Function(String?) usernameValidator;
  final String? Function(String?) passwordValidator;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final bool isLogin = mode == AuthMode.login;

    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          validator: usernameValidator,
          decoration: const InputDecoration(
            labelText: 'Usuario',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          validator: passwordValidator,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: onTogglePasswordVisibility,
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        if (!isLogin) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            validator: (value) {
              final String? passError = passwordValidator(value);
              if (passError != null) {
                return passError;
              }
              if (value != passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: onToggleConfirmPasswordVisibility,
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
