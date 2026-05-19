import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';
import 'models/catalog_item.dart';
import 'models/wallet_method.dart';
import 'services/catalogos_api_service.dart';
import 'services/wallet_api_service.dart';

class BilleteraScreen extends StatefulWidget {
  const BilleteraScreen({super.key});

  @override
  State<BilleteraScreen> createState() => _BilleteraScreenState();
}

class _BilleteraScreenState extends State<BilleteraScreen> {
  static const Color _primaryDark = AppColors.bg1;
  static const Color _accentIndigo = AppColors.accent;
  static const Duration _requestTimeout = Duration(seconds: 12);

  late final WalletApiService _walletApiService;
  late final CatalogosApiService _catalogosApiService;

  List<WalletMethod> _methods = [];
  List<MetodoPagoItem> _catalog = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _walletApiService = WalletApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    _catalogosApiService = CatalogosApiService(
      baseUrl: ApiConfig.baseUrl,
      requestTimeout: _requestTimeout,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Debes iniciar sesion';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _walletApiService.fetchMethods(token: token),
        _catalogosApiService.fetchMetodos(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _methods = results[0] as List<WalletMethod>;
        _catalog = results[1] as List<MetodoPagoItem>;
        _loading = false;
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
        _error = 'No se pudo cargar la billetera';
      });
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

  Future<void> _addMetodo() async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      await _openLogin();
      return;
    }
    final _AddMetodoDialogResult? result = await showDialog<_AddMetodoDialogResult>(
      context: context,
      builder: (context) => _AddMetodoDialog(catalog: _catalog),
    );

    if (result == null) {
      return;
    }

    try {
      await _walletApiService.addMethod(
        token: token,
        metodoId: result.metodo.id,
        alias: result.alias,
        numero: result.numero,
      );
      if (!mounted) {
        return;
      }
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _deleteMetodo(int metodoId) async {
    final String? token = AuthController.instance.session?.token;
    if (token == null || token.isEmpty) {
      await _openLogin();
      return;
    }

    try {
      await _walletApiService.deleteMethod(token: token, id: metodoId);
      if (!mounted) {
        return;
      }
      await _loadData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi billetera')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMetodo,
        icon: const Icon(Icons.add),
        label: const Text('Agregar metodo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _methods.isEmpty
                  ? Center(
                      child: Text(
                        'No tienes metodos guardados',
                        style: TextStyle(
                          color: AppColors.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _methods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final WalletMethod method = _methods[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _accentIndigo.withAlpha(24),
                              child: Icon(Icons.credit_card, color: _accentIndigo),
                            ),
                            title: Text(method.metodo),
                            subtitle: Text(
                              [method.alias, method.numero]
                                  .where((value) => value != null && value.isNotEmpty)
                                  .join(' · '),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteMetodo(method.id),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _AddMetodoDialogResult {
  const _AddMetodoDialogResult({
    required this.metodo,
    this.alias,
    this.numero,
  });

  final MetodoPagoItem metodo;
  final String? alias;
  final String? numero;
}

class _AddMetodoDialog extends StatefulWidget {
  const _AddMetodoDialog({required this.catalog});

  final List<MetodoPagoItem> catalog;

  @override
  State<_AddMetodoDialog> createState() => _AddMetodoDialogState();
}

class _AddMetodoDialogState extends State<_AddMetodoDialog> {
  MetodoPagoItem? _selected;
  late final TextEditingController _aliasController;
  late final TextEditingController _numeroController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
    _numeroController = TextEditingController();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) {
      return;
    }
    final String alias = _aliasController.text.trim();
    final String numero = _numeroController.text.trim();
    Navigator.pop(
      context,
      _AddMetodoDialogResult(
        metodo: _selected!,
        alias: alias.isEmpty ? null : alias,
        numero: numero.isEmpty ? null : numero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar metodo de pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MetodoPagoItem>(
              initialValue: _selected,
              items: widget.catalog
                  .map(
                    (item) => DropdownMenuItem<MetodoPagoItem>(
                      value: item,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _selected = value;
              }),
              decoration: const InputDecoration(
                labelText: 'Metodo',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aliasController,
              decoration: const InputDecoration(
                labelText: 'Alias (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Numero o referencia',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selected == null ? null : _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
