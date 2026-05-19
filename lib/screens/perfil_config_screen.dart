import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';
import 'models/user_profile.dart';
import 'services/profile_api_service.dart';
import 'utils/activity_store.dart';

class PerfilConfigScreen extends StatefulWidget {
  const PerfilConfigScreen({super.key});

  @override
  State<PerfilConfigScreen> createState() => _PerfilConfigScreenState();
}

class _PerfilConfigScreenState extends State<PerfilConfigScreen> {
  static const Color _primaryDark = AppColors.bg1;
  static const Color _accentIndigo = AppColors.accent;

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late final ProfileApiService _apiService;

  bool _loading = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _error;
  String _language = 'Español';

  @override
  void initState() {
    super.initState();
    _apiService = ProfileApiService(baseUrl: ApiConfig.baseUrl);
    _loadProfile();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Debes iniciar sesion';
      });
      return;
    }

    try {
      final UserProfile profile = await _apiService.fetchProfile(token: token);
      if (!mounted) {
        return;
      }
      setState(() {
        _usuarioController.text = profile.usuario ?? '';
        _telefonoController.text = profile.telefono ?? '';
        _direccionController.text = profile.direccion ?? '';
        _loading = false;
        _error = null;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Tiempo de espera agotado';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar el perfil';
      });
    }
  }

  Future<void> _saveProfile() async {
    final FormState? form = _profileFormKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      await _openLogin();
      return;
    }

    setState(() {
      _savingProfile = true;
    });

    try {
      await _apiService.updateProfile(
        token: token,
        update: UserProfileUpdate(
          usuario: _usuarioController.text.trim(),
          telefono: _telefonoController.text.trim().isEmpty
              ? null
              : _telefonoController.text.trim(),
          direccion: _direccionController.text.trim().isEmpty
              ? null
              : _direccionController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingProfile = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    final FormState? form = _passwordFormKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      await _openLogin();
      return;
    }

    setState(() {
      _savingPassword = true;
    });

    try {
      final String message = await _apiService.changePassword(
        token: token,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingPassword = false;
        });
      }
    }
  }

  Future<void> _openLogin() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          initialMode: AuthMode.login,
          title: 'Inicia sesion para continuar',
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (value.length < 6) {
      return 'Minimo 6 caracteres';
    }
    if (value.contains(' ')) {
      return 'No puede contener espacios';
    }
    return null;
  }

  Future<void> _openPersonalDataDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Datos personales'),
          content: Form(
            key: _profileFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Telefono'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(labelText: 'Direccion'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _savingProfile
                  ? null
                  : () async {
                      await _saveProfile();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentIndigo,
                foregroundColor: AppColors.bg0,
              ),
              child: _savingProfile
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: _passwordFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                    ),
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                    ),
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      final String? error = _passwordValidator(value);
                      if (error != null) {
                        return error;
                      }
                      if (value != _newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _savingPassword
                  ? null
                  : () async {
                      await _changePassword();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentIndigo,
                foregroundColor: AppColors.bg0,
              ),
              child: _savingPassword
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLanguageDialog() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Español'),
                value: 'Español',
                groupValue: _language,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _language = selected;
      });
    }
  }

  Future<void> _openLoginInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Donde iniciaste sesion'),
          content: const Text('Sesion iniciada en este dispositivo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openActivityDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registro de actividad'),
          content: ValueListenableBuilder<List<ActivityEntry>>(
            valueListenable: ActivityStore.entries,
            builder: (context, entries, _) {
              if (entries.isEmpty) {
                return const Text('Aun no has visto salones.');
              }
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final ActivityEntry entry = entries[index];
                    return ListTile(
                      dense: true,
                      title: Text(entry.name),
                      subtitle: Text(entry.timestamp.toLocal().toString()),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ConfigTile(
                      title: 'Idioma',
                      subtitle: _language,
                      icon: Icons.language,
                      onTap: _openLanguageDialog,
                      primaryDark: _primaryDark,
                      accentIndigo: _accentIndigo,
                    ),
                    _ConfigTile(
                      title: 'Datos personales',
                      subtitle: 'Usuario, telefono y direccion',
                      icon: Icons.badge_outlined,
                      onTap: _openPersonalDataDialog,
                      primaryDark: _primaryDark,
                      accentIndigo: _accentIndigo,
                    ),
                    _ConfigTile(
                      title: 'Cambiar contraseña',
                      subtitle: 'Actualiza tu clave de acceso',
                      icon: Icons.lock_outline,
                      onTap: _openPasswordDialog,
                      primaryDark: _primaryDark,
                      accentIndigo: _accentIndigo,
                    ),
                    _ConfigTile(
                      title: 'Donde iniciaste sesion',
                      subtitle: 'Ver detalle del dispositivo',
                      icon: Icons.devices,
                      onTap: _openLoginInfoDialog,
                      primaryDark: _primaryDark,
                      accentIndigo: _accentIndigo,
                    ),
                    _ConfigTile(
                      title: 'Registro de actividad',
                      subtitle: 'Salones que has visto',
                      icon: Icons.history,
                      onTap: _openActivityDialog,
                      primaryDark: _primaryDark,
                      accentIndigo: _accentIndigo,
                    ),
                  ],
                ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accentIndigo.withAlpha(20),
          child: Icon(icon, color: accentIndigo),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.text1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.text1),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.text1),
        onTap: onTap,
      ),
    );
  }
}
