import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'home_screen.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login, this.title});

  final AuthMode initialMode;
  final String? title;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final String? requiredMessage = _requiredValidator(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if ((value ?? '').length < 6) {
      return 'La contraseña debe tener mínimo 6 caracteres';
    }
    return null;
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
                            : 'Regístrate para comprar y reservar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              validator: _requiredValidator,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _passwordValidator,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLogin) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) {
                                  final String? passError = _passwordValidator(
                                    value,
                                  );
                                  if (passError != null) {
                                    return passError;
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Confirmar contraseña',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
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
                            color: _message!.toLowerCase().contains('exitoso')
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
