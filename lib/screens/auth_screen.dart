import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'home_screen.dart';
import 'widgets/auth/auth_form_fields.dart';
import 'widgets/auth/forgot_password_dialog.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login, this.title});

  final AuthMode initialMode;
  final String? title;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color _accentIndigo = Color(0xFF3D3B8E);
  static final RegExp _usernameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$');
  static final RegExp _whitespaceRegex = RegExp(r'\s');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AuthMode _mode;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;

  bool get _isSuccessMessage =>
      (_message ?? '').toLowerCase().contains('exitoso');

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _usernameValidator(String? value) {
    final String raw = value ?? '';
    final String normalized = raw.trim();
    if (normalized.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (raw != normalized) {
      return 'Ingrese un usuario valido';
    }
    if (normalized.contains('  ')) {
      return 'Ingrese un usuario valido';
    }
    if (!_usernameRegex.hasMatch(normalized)) {
      return 'Ingrese un usuario valido';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final String password = value ?? '';
    if (password.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (_whitespaceRegex.hasMatch(password)) {
      return 'La contraseña no puede contener espacios';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener mínimo 6 caracteres';
    }
    return null;
  }

  Future<void> _openForgotPassword() async {
    final String? message = await showDialog<String>(
      context: context,
      builder: (_) => ForgotPasswordDialog(
        usernameValidator: _usernameValidator,
        passwordValidator: _passwordValidator,
        accentIndigo: _accentIndigo,
        onSubmit: (username, password) =>
            AuthController.instance.resetPassword(username, password),
      ),
    );

    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    setState(() {
      _message = message;
    });
  }

  Future<void> _openRegister() async {
    final bool? registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.register,
          title: 'Crear cuenta',
        ),
      ),
    );

    if (mounted && registered == true) {
      setState(() {
        _message = 'Registro exitoso. Ahora inicia sesión';
      });
    }
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final bool isLogin = _mode == AuthMode.login;
      final AuthResult result = isLogin
          ? await AuthController.instance.login(username, password)
          : await AuthController.instance.registrar(username, password);

      if (!mounted) {
        return;
      }

      if (result.success) {
        if (isLogin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(username: result.username ?? username),
            ),
            (route) => false,
          );
          return;
        }

        setState(() {
          _message = result.message ?? 'Registro exitoso';
        });

        Navigator.pop(context, true);
        return;
      }

      setState(() {
        _message = result.message ?? 'No se pudo completar la solicitud';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = _mode == AuthMode.login;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? (isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isLogin
                            ? 'Accede para reservar'
                            : 'Regístrate para hacer tu reserva',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: AuthFormFields(
                          mode: _mode,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          obscurePassword: _obscurePassword,
                          obscureConfirmPassword: _obscureConfirmPassword,
                          usernameValidator: _usernameValidator,
                          passwordValidator: _passwordValidator,
                          onTogglePasswordVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onToggleConfirmPasswordVisibility: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentIndigo,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isLogin ? 'Iniciar sesión' : 'Registrarme'),
                      ),
                      const SizedBox(height: 8),
                      if (isLogin)
                        TextButton(
                          onPressed: _isLoading ? null : _openForgotPassword,
                          child: const Text('Has olvidado tu contraseña?'),
                        ),
                      if (isLogin)
                        TextButton(
                          onPressed: _isLoading ? null : _openRegister,
                          child: const Text('¿No tienes cuenta? Regístrate'),
                        )
                      else
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Ya tengo cuenta, volver al login'),
                        ),
                      if (_message != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _message!,
                          style: TextStyle(
                            color: _isSuccessMessage
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
