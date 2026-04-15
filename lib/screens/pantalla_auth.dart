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
  bool _isLogin = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

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

  Future<void> _onLoginPressed() async {
    final navigator = Navigator.of(context);
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
          _switchTab(true);
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

  @override
  Widget build(BuildContext context) {
    // Negro puro del fondo de la imagen
    const bgColor = Color(0xFF0D1117);
    // Color de los inputs (ligeramente más claro que el fondo)
    const inputBg = Color(0xFF161B22);
    // Borde de inputs y contenedor del tab
    const borderColor = Color(0xFF30363D);
    // Azul del botón Sign In
    const btnBlue = Color(0xFF3D4FE0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo centrado ──────────────────────────────────
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(38, 38),
                        painter: _BoltPainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Título ─────────────────────────────────────────
                const Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Sign in to manage your building resources',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8B949E)),
                  ),
                ),
                const SizedBox(height: 30),

                // ── Tab switcher ───────────────────────────────────
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Log In', _isLogin, () => _switchTab(true)),
                      _buildTab('Sign Up', !_isLogin, () => _switchTab(false)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Campos de registro extra ───────────────────────
                if (!_isLogin) ...[
                  _label('Full Name'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _nameController,
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    inputBg: inputBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Email ──────────────────────────────────────────
                _label('Email Address'),
                const SizedBox(height: 8),
                _inputField(
                  controller: _emailController,
                  hint: 'name@building.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  inputBg: inputBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 20),

                // ── Password label + Forgot ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Password'),
                    if (_isLogin)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResetPwd()),
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF6E8EFB),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _inputField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  inputBg: inputBg,
                  borderColor: borderColor,
                ),

                // ── Confirm password (solo registro) ───────────────
                if (!_isLogin) ...[
                  const SizedBox(height: 20),
                  _label('Confirm Password'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _passwordConfirmController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    inputBg: inputBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),

                  // Terms
                  GestureDetector(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _termsAccepted
                                ? btnBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _termsAccepted ? btnBlue : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: _termsAccepted
                              ? const Icon(
                                  Icons.check,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'I agree to the ',
                          style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Color(0xFF6E8EFB),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Error ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1515),
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

                const SizedBox(height: 26),

                // ── Botón Sign In / Create Account ─────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_isLogin ? _onLoginPressed : _onRegisterPressed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnBlue,
                      foregroundColor: Colors.white,
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin ? 'Sign In' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // ── OR CONTINUE WITH ───────────────────────────────
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xFF21262D), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          color: Color(0xFF484F58),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFF21262D), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Botones sociales ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _socialBtn(
                        label: 'Google',
                        iconWidget: _googleIcon(),
                        inputBg: inputBg,
                        borderColor: borderColor,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _socialBtn(
                        label: 'Apple',
                        iconWidget: const Icon(
                          Icons.apple,
                          color: Colors.white,
                          size: 22,
                        ),
                        inputBg: inputBg,
                        borderColor: borderColor,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // ── Footer ─────────────────────────────────────────
                Center(
                  child: Text(
                    _isLogin
                        ? 'By signing in, you agree to our automated booking\nmanagement guidelines for building residents.'
                        : 'By signing up, you agree to our automated booking\nmanagement guidelines for building residents.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF484F58),
                      fontSize: 11,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab widget ──────────────────────────────────────────────────
  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF21262D) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF8B949E),
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Label ───────────────────────────────────────────────────────
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Input field ─────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color inputBg,
    required Color borderColor,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF484F58), fontSize: 14.5),
        prefixIcon: Icon(icon, color: const Color(0xFF8B949E), size: 20),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3D4FE0), width: 1.5),
        ),
      ),
    );
  }

  // ── Social button ───────────────────────────────────────────────
  Widget _socialBtn({
    required String label,
    required Widget iconWidget,
    required Color inputBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Google icon SVG-like con CustomPaint ────────────────────────
  Widget _googleIcon() {
    return CustomPaint(size: const Size(22, 22), painter: _GoogleIconPainter());
  }
}

// ── Bolt icon painter (rayo outline negro sobre blanco) ─────────────
class _BoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Rayo: parte superior derecha hacia centro, luego inferior izquierda
    path.moveTo(size.width * 0.62, 0);
    path.lineTo(size.width * 0.28, size.height * 0.48);
    path.lineTo(size.width * 0.52, size.height * 0.48);
    path.lineTo(size.width * 0.38, size.height);
    path.lineTo(size.width * 0.78, size.height * 0.44);
    path.lineTo(size.width * 0.52, size.height * 0.44);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Google "G" icon painter ─────────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Arco rojo (top)
    _drawArc(canvas, cx, cy, r, -0.3, 1.9, const Color(0xFFEA4335));
    // Arco amarillo (bottom-right)
    _drawArc(canvas, cx, cy, r, 1.6, 0.9, const Color(0xFFFBBC04));
    // Arco verde (bottom-left)
    _drawArc(canvas, cx, cy, r, 2.5, 0.8, const Color(0xFF34A853));
    // Arco azul (left)
    _drawArc(canvas, cx, cy, r, 3.3, 1.2, const Color(0xFF4285F4));

    // Línea horizontal azul del "G"
    final linePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.85, cy), linePaint);

    // Agujero blanco del centro
    final holePaint = Paint()..color = const Color(0xFF161B22);
    canvas.drawCircle(Offset(cx, cy), r * 0.55, holePaint);
  }

  void _drawArc(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.38
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
