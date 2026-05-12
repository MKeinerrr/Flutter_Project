import 'package:flutter/material.dart';
import '../../auth_screen.dart';

class AuthFormFields extends StatelessWidget {
  const AuthFormFields({
    super.key,
    required this.mode,
    required this.usernameController,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.loginIdentifierValidator,
    required this.usernameValidator,
    required this.nameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
  });

  final AuthMode mode;
  final TextEditingController usernameController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? Function(String?) loginIdentifierValidator;
  final String? Function(String?) usernameValidator;
  final String? Function(String?) nameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final bool isLogin = mode == AuthMode.login;

    return Column(
      children: [
        if (!isLogin) ...[
          TextFormField(
            controller: firstNameController,
            validator: nameValidator,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: lastNameController,
            validator: nameValidator,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: usernameController,
          validator: isLogin ? loginIdentifierValidator : usernameValidator,
          decoration: InputDecoration(
            labelText: isLogin ? 'Usuario o correo' : 'Usuario',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        if (!isLogin) ...[
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
            decoration: const InputDecoration(
              labelText: 'Correo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
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
