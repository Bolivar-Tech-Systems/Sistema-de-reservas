import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaPagoWompi extends StatefulWidget {
  final int reservaId;
  final double montoTotal;
  final String recursoNombre;

  const PantallaPagoWompi({
    super.key,
    required this.reservaId,
    required this.montoTotal,
    required this.recursoNombre,
  });

  @override
  State<PantallaPagoWompi> createState() => _PantallaPagoWompiState();
}

class _PantallaPagoWompiState extends State<PantallaPagoWompi> {
  bool _procesando = false;
  bool _pagoExitoso = false;
  String _metodoSeleccionado = 'tarjeta'; // tarjeta, pse, nequi
  String _errorMsg = '';

  // Controladores de tarjeta simulada
  final _numeroCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _fechaCtrl = TextEditingController(text: '12/29');
  final _cvvCtrl = TextEditingController(text: '123');
  final _nombreCtrl = TextEditingController(text: 'JUAN PEREZ');

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _fechaCtrl.dispose();
    _cvvCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _procesarPago() async {
    setState(() {
      _procesando = true;
      _errorMsg = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      // Primero creamos el registro de pago en backend (estado: Pendiente)
      final createRes = await http.post(
        Uri.parse('${AppConfig.baseUrl}/pagos/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reserva_id': widget.reservaId,
          'monto': widget.montoTotal,
          'metodo_pago': _metodoSeleccionado,
          'estado_pago': 'Pendiente',
          'referencia_transaccion': 'WOMPI-REF-${widget.reservaId}-${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (createRes.statusCode != 200 && createRes.statusCode != 201) {
        throw Exception('Error al registrar el pago en el sistema.');
      }

      // Ahora simulamos el pago exitoso en Wompi
      final simRes = await http.post(
        Uri.parse('${AppConfig.baseUrl}/pagos/simular-wompi/${widget.reservaId}?exitoso=true'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (simRes.statusCode == 200) {
        setState(() {
          _procesando = false;
          _pagoExitoso = true;
        });

        // Esperar 2 segundos para mostrar la animación de éxito
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMsg = 'Error en la respuesta de Wompi Sandbox.';
          _procesando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error al procesar el pago: ${e.toString()}';
          _procesando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromRGBO(18, 16, 32, 1), Colores.background],
          ),
        ),
        child: SafeArea(
          child: _pagoExitoso ? _buildExitoView() : _buildPagoForm(),
        ),
      ),
    );
  }

  Widget _buildExitoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colores.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colores.success.withOpacity(0.4), width: 3),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colores.success,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Pago Aprobado!',
            style: TextStyle(
              color: Colores.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu transacción con Wompi fue exitosa.',
            style: TextStyle(
              color: Colores.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colores.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colores.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colores.text, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pasarela Wompi',
                      style: TextStyle(
                          color: Colores.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text('Sandbox de pagos seguros',
                      style: TextStyle(
                          color: Colores.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tarjeta resumen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colores.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colores.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recursoNombre,
                      style: const TextStyle(
                          color: Colores.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Reserva confirmada',
                        style: TextStyle(
                            color: Colores.textSecondary, fontSize: 11)),
                  ],
                ),
                Text(
                  '\$${widget.montoTotal.toStringAsFixed(0)} COP',
                  style: const TextStyle(
                      color: Colores.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Selecciona método de pago',
              style: TextStyle(
                  color: Colores.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // Métodos de pago chips
          Row(
            children: [
              _metodoChip('tarjeta', 'Tarjeta de Crédito', Icons.credit_card_rounded),
              const SizedBox(width: 10),
              _metodoChip('pse', 'PSE / Ahorros', Icons.account_balance_rounded),
            ],
          ),
          const SizedBox(height: 24),

          if (_metodoSeleccionado == 'tarjeta') _buildTarjetaForm(),
          if (_metodoSeleccionado == 'pse') _buildPseForm(),

          const SizedBox(height: 24),

          if (_errorMsg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMsg,
                style: const TextStyle(color: Colores.danger, fontSize: 13),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _procesando ? null : _procesarPago,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E28D9), // Color morado característico de Wompi
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _procesando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Pagar con Wompi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metodoChip(String value, String label, IconData icon) {
    final selected = _metodoSeleccionado == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _metodoSeleccionado = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6E28D9).withOpacity(0.12) : Colores.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF6E28D9) : Colores.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? const Color(0xFF6E28D9) : Colores.textMuted, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colores.text : Colores.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detalles de Tarjeta',
              style: TextStyle(color: Colores.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _inputField(_numeroCtrl, 'Número de tarjeta', Icons.credit_card_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField(_fechaCtrl, 'MM/AA', Icons.calendar_today_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _inputField(_cvvCtrl, 'CVV', Icons.lock_outline_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _inputField(_nombreCtrl, 'Nombre del tarjetahabiente', Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildPseForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PSE / Transferencia Bancaria',
              style: TextStyle(color: Colores.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            dropdownColor: Colores.surfaceAlt,
            style: const TextStyle(color: Colores.text, fontSize: 13),
            decoration: const InputDecoration(
              icon: Icon(Icons.account_balance_rounded, color: Colores.primary),
              labelText: 'Selecciona tu Banco',
              labelStyle: TextStyle(color: Colores.textMuted),
              border: InputBorder.none,
            ),
            items: const [
              DropdownMenuItem(value: 'bancolombia', child: Text('Bancolombia')),
              DropdownMenuItem(value: 'davivienda', child: Text('Banco Davivienda')),
              DropdownMenuItem(value: 'bogota', child: Text('Banco de Bogotá')),
              DropdownMenuItem(value: 'nequi', child: Text('Nequi')),
            ],
            onChanged: (val) {},
          ),
          const SizedBox(height: 12),
          _inputField(TextEditingController(), 'Correo electrónico de PSE', Icons.email_outlined),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colores.text, fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colores.textMuted, size: 18),
        labelText: label,
        labelStyle: const TextStyle(color: Colores.textMuted, fontSize: 13),
        filled: true,
        fillColor: Colores.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colores.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colores.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colores.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
