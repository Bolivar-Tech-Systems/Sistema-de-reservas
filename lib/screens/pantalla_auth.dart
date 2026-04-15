import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_de_reservas/screens/resetPwd.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'home.dart';

class PantallaAuth extends StatefulWidget {
  const PantallaAuth({super.key});

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  // ── Estado del tab ──────────────────────────────────────────────
  bool _isLogin = true;

  // ── Campos compartidos ──────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── Campos solo de registro ─────────────────────────────────────
  final _nameController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // ── UI state ────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _errorMessage;

  // ── URLs ────────────────────────────────────────────────────────
  static const _loginUrl = "${AppConfig.baseUrl}/auth/login";
  static const _registerUrl = "${AppConfig.baseUrl}/auth/register";

  void _switchTab(bool toLogin) {
    setState(() {
      _isLogin = toLogin;
      _errorMessage = null;
    });
  }

  // ── Login ───────────────────────────────────────────────────────
  Future<void> _onLoginPressed() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (result.statusCode == 200) {
        final body = jsonDecode(result.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', body['access_token']);
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const PantallaHome()),
        );
      } else if (result.statusCode == 400) {
        setState(() => _errorMessage = 'Correo o contraseña incorrectos');
      } else {
        setState(
          () => _errorMessage = 'Error del servidor ${result.statusCode}',
        );
      }
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar al servidor');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Register ─────────────────────────────────────────────────────
  Future<void> _onRegisterPressed() async {
    if (!_termsAccepted) {
      setState(
        () => _errorMessage = 'Debes aceptar los términos y condiciones',
      );
      return;
    }
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor completa todos los campos');
      return;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      setState(() => _errorMessage = 'Ingresa un correo válido');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(
        () => _errorMessage = 'La contraseña debe tener mínimo 6 caracteres',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordConfirmController.text,
        }),
      );

      if (result.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada exitosamente! Inicia sesión.'),
            ),
          );
          _switchTab(true); // volver al login
        }
      } else {
        final data = jsonDecode(result.body);
        setState(
          () => _errorMessage = data['detail'] ?? 'Error al registrarse',
        );
      }
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar al servidor');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colores.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 40,
                  color: Colores.background,
                ),
              ),
              const SizedBox(height: 20),

              // Título dinámico
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colores.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin
                    ? 'Sign in to manage your building resources'
                    : 'Register to manage your building resources',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colores.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Tab switcher
              Container(
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colores.border, width: 1),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab(
                      label: 'Log In',
                      active: _isLogin,
                      onTap: () => _switchTab(true),
                    ),
                    _buildTab(
                      label: 'Sign Up',
                      active: !_isLogin,
                      onTap: () => _switchTab(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Formulario dinámico
              if (!_isLogin) ...[
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 18),
              ],

              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'name@building.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              // Password label + forgot (solo en login)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Password'),
                  if (_isLogin)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ResetPwd()),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colores.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: true,
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 18),
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordConfirmController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 16),

                // Terms checkbox
                GestureDetector(
                  onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _termsAccepted
                              ? Colores.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _termsAccepted
                                ? Colores.primary
                                : Colores.border,
                            width: 1.5,
                          ),
                        ),
                        child: _termsAccepted
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: Colores.background,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'I agree to the ',
                        style: TextStyle(
                          color: Colores.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Colores.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colores.danger, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colores.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colores.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isLogin ? _onLoginPressed : _onRegisterPressed),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? 'Sign In' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: Colores.border, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        color: Colores.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colores.border, thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),

              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      iconColor: Colores.danger,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Apple',
                      icon: Icons.apple,
                      iconColor: Colores.text,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                _isLogin
                    ? 'By signing in, you agree to our automated booking\nmanagement guidelines for building residents.'
                    : 'By signing up, you agree to our automated booking\nmanagement guidelines for building residents.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colores.textMuted,
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets helper ───────────────────────────────────────────────

  Widget _buildTab({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colores.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colores.text : Colores.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
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

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colores.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colores.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colores.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
