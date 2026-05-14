import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String idUsuario;
  final bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.idUsuario,
    required this.leida,
    required this.fecha,
  });

  factory Notificacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Notificacion(
      id:        id,
      titulo:    data['titulo'] ?? '',
      mensaje:   data['mensaje'] ?? '',
      tipo:      data['tipo'] ?? '',
      idUsuario: data['id_usuario'] ?? '',
      leida:     data['leida'] ?? false,
      fecha:     (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo':     titulo,
      'mensaje':    mensaje,
      'tipo':       tipo,
      'id_usuario': idUsuario,
      'leida':      leida,
      'fecha':      FieldValue.serverTimestamp(),
    };
  }
}