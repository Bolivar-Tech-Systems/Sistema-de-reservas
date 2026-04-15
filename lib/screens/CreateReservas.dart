import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class PantallaCreateReserva extends StatefulWidget {
  PantallaCreateReserva({super.key});

  @override
  State<PantallaCreateReserva> createState() => _PantallaCreateReservaState();
}

class _PantallaCreateReservaState extends State<PantallaCreateReserva> {
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  String? _errorMSG;
  bool _cargando = false;

  File? _imagenSeleccionada;
  Uint8List? _imagenBytes;
  final ImagePicker _picker = ImagePicker();

  final String baseUrl = AppConfig.baseUrl;

  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagenSeleccionada = File(picked.path);
        _imagenBytes = bytes;
      });
    }
  }

  Future<void> crearReserva() async {
    if (nombre.text.isEmpty || descripcion.text.isEmpty) {
      setState(() => _errorMSG = "Por favor completa todos los campos");
      return;
    }

    setState(() {
      _cargando = true;
      _errorMSG = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        setState(() => _errorMSG = "Sesión expirada, inicia sesión nuevamente");
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/reservas/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nombre.text,
          "description": descripcion.text,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        setState(
          () => _errorMSG = "Error al crear reserva: ${response.statusCode}",
        );
        return;
      }

      final reservaData = jsonDecode(response.body);
      final int reservaId = reservaData["id"];

      if (_imagenSeleccionada != null) {
        final fileName = _imagenSeleccionada!.path.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'png' : 'jpeg';

        final uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse("$baseUrl/images/upload"),
        );

        uploadRequest.headers["Authorization"] = "Bearer $token";

        uploadRequest.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _imagenBytes!,
            filename: fileName,
            contentType: MediaType('image', mimeType),
          ),
        );

        uploadRequest.fields['file_name'] = fileName;
        uploadRequest.fields['reserva_id'] = reservaId.toString();

        final uploadResponse = await uploadRequest.send();

        if (uploadResponse.statusCode != 200 &&
            uploadResponse.statusCode != 201) {
          setState(
            () => _errorMSG =
                "Reserva creada, pero falló la imagen (${uploadResponse.statusCode})",
          );
          return;
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMSG = "No se pudo conectar al servidor");
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colores.background, Colors.black],
          ),
        ),
        padding: EdgeInsets.only(top: 25, left: 10, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.primaryDark,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colores.text,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Crea tu Recurso",
                style: TextStyle(
                  fontSize: 25,
                  color: Colores.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nombre,
                style: TextStyle(color: Colores.text),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                  labelText: "Nombre del recurso",
                  labelStyle: TextStyle(color: Colores.textSecondary),
                  prefixIcon: Icon(Icons.add, color: Colores.primary),
                  fillColor: Colores.surface,
                  filled: true,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descripcion,
                style: TextStyle(color: Colores.text),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                  labelText: "Descripción del recurso",
                  labelStyle: TextStyle(color: Colores.textSecondary),
                  prefixIcon: Icon(Icons.add, color: Colores.primary),
                  fillColor: Colores.surface,
                  filled: true,
                ),
              ),
              SizedBox(height: 20),

              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _imagenSeleccionada != null
                          ? Colores.primary
                          : Colores.textSecondary,
                      width: 1.5,
                    ),
                  ),
                  child: _imagenSeleccionada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: kIsWeb
                              ? Image.memory(_imagenBytes!, fit: BoxFit.cover)
                              : Image.file(
                                  _imagenSeleccionada!,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colores.primary,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Toca para agregar una imagen",
                              style: TextStyle(
                                color: Colores.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "JPG, PNG",
                              style: TextStyle(
                                color: Colores.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              if (_imagenSeleccionada != null)
                TextButton.icon(
                  onPressed: () => setState(() => _imagenSeleccionada = null),
                  icon: Icon(Icons.close, color: Colores.danger, size: 16),
                  label: Text(
                    "Quitar imagen",
                    style: TextStyle(color: Colores.danger, fontSize: 13),
                  ),
                ),

              SizedBox(height: 20),
              if (_errorMSG != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMSG!,
                    style: const TextStyle(color: Colores.danger, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primaryDark,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _cargando ? null : crearReserva,
                child: _cargando
                    ? const CircularProgressIndicator(color: Colores.primary)
                    : const Text(
                        "Crear Recurso",
                        style: TextStyle(fontSize: 16, color: Colores.text),
                      ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
