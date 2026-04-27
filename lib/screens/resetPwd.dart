import 'package:flutter/material.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPwd extends StatefulWidget {
  const ResetPwd({super.key});

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  final url = "${AppConfig.baseUrl}/auth/forget-password";
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool code = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> resetPwd() async {
    if (emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el correo';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text}),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        // Registro exitoso — vuelve al login
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Correo enviado")));
          setState(() {
            code = true;
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['detail'] ?? 'Error al registrarse';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> confirmReset() async {
    if (codeController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Complete todos los campos');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/auth/reset-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'code': codeController.text,
          'new_password': newPasswordController.text,
          'confirm_password': confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contraseña actualizada")),
          );
          Navigator.pop(context);
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() => _errorMessage = data['detail'] ?? 'Error');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1117),
              Color.fromARGB(255, 28, 44, 52),
              Color(0xFF0D1117),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: Colores.border,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    !code ? 'Restablecer contraseña' : 'Ingresa el código',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colores.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    !code
                        ? 'Ingresa tu correo para recibir el codigo'
                        : 'Código enviado a ${emailController.text}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colores.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  if (!code) ...[
                    _buildLabel('Correo electrónico'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailController,
                      hint: 'nombre@correo.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null) _buildError(),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : resetPwd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.primaryDark,
                          foregroundColor: Colores.text,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colores.text,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Obtener código',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.send, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancelar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colores.text,
                          side: const BorderSide(color: Colores.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildLabel('Código de verificación'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: codeController,
                      hint: '123456',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Nueva contraseña'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: newPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscureNew,
                      onToggleObscure: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Confirmar contraseña'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: confirmPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null) _buildError(),

                    const SizedBox(height: 8),

                    // Botón restablecer
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : confirmReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.primaryDark,
                          foregroundColor: Colores.text,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colores.text,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Restablecer contraseña',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.check, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colores.text,
                          side: const BorderSide(color: Colores.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => setState(() {
                        code = false;
                        _errorMessage = null;
                      }),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Correo incorrecto? ',
                            style: TextStyle(
                              color: Colores.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Corregir',
                            style: TextStyle(
                              color: Colores.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colores.danger, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colores.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colores.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colores.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colores.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colores.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: Colores.icon, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colores.icon,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colores.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.primary, width: 1.5),
        ),
      ),
    );
  }
}
