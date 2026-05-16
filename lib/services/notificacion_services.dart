import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion_model.dart';

class NotificacionService {
  final _db = FirebaseFirestore.instance;
  final String _col = 'notificaciones';

// Crear notificación
Future<void> crearNotificacion({
  required String titulo,
  required String mensaje,
  required String tipo,
  required String idUsuario,
}) async {
  await _db.collection(_col).add({
    'titulo': titulo,
    'mensaje': mensaje,
    'tipo': tipo,
    'id_usuario': idUsuario,
    'leida': false,
    'fecha': Timestamp.now(),
  });
}
  // Leer
  Stream<List<Notificacion>> getNotificaciones(String idUsuario) {
    return _db
        .collection(_col)
        .where('id_usuario', isEqualTo: idUsuario)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Notificacion.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Marcar una como leída
  Future<void> marcarLeida(String id) async {
    await _db.collection(_col).doc(id).update({'leida': true});
  }

  // Marcar todas como leídas
  Future<void> marcarTodasLeidas(String idUsuario) async {
    final snap = await _db
        .collection(_col)
        .where('id_usuario', isEqualTo: idUsuario)
        .where('leida', isEqualTo: false)
        .get();
    for (var doc in snap.docs) {
      await doc.reference.update({'leida': true});
    }
  }

  // Eliminar
  Future<void> eliminarNotificacion(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // Contar no leídas
  Stream<int> contarNoLeidas(String idUsuario) {
    return _db
        .collection(_col)
        .where('id_usuario', isEqualTo: idUsuario)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}