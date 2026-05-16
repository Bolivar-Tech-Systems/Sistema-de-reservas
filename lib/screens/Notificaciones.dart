import 'package:flutter/material.dart';
import '../services/notificacion_services.dart';
import '../models/notificacion_model.dart';

class NotificacionesScreen extends StatelessWidget {
  final String idUsuario;
  final _service = NotificacionService();

  NotificacionesScreen({required this.idUsuario, super.key});

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'confirmada':  return Icons.check_circle;
      case 'cancelada':   return Icons.cancel;
      case 'pendiente':   return Icons.hourglass_empty;
      case 'disponible':  return Icons.inventory;
      case 'devuelto':    return Icons.assignment_return;
      case 'dano':        return Icons.warning;
      case 'bienvenida':  return Icons.celebration;
      case 'perfil':      return Icons.account_circle;
      case 'seguridad':   return Icons.lock;
      default:            return Icons.notifications;
    }
  }

  Color _color(String tipo) {
    switch (tipo) {
      case 'confirmada':  return Colors.green;
      case 'cancelada':   return Colors.red;
      case 'pendiente':   return Colors.orange;
      case 'disponible':  return Colors.blue;
      case 'devuelto':    return Colors.purple;
      case 'dano':        return Colors.red[800]!;
      case 'bienvenida':  return Colors.teal;
      case 'perfil':      return Colors.indigo;
      case 'seguridad':   return Colors.amber[800]!;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () => _service.marcarTodasLeidas(idUsuario),
            child: const Text('Marcar todas leídas',
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
body: idUsuario.isEmpty
    ? const Center(child: CircularProgressIndicator())
    : StreamBuilder<List<Notificacion>>(
        stream: _service.getNotificaciones(idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sin notificaciones'));
          }
          final notifs = snapshot.data!;
          return ListView.builder(
  itemCount: notifs.length,
  itemBuilder: (context, i) {
    final n = notifs[i];
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _service.eliminarNotificacion(n.id),
      child: ListTile(
        tileColor: n.leida ? null : Colors.blue[50],
        leading: CircleAvatar(
          backgroundColor: _color(n.tipo),
          child: Icon(_icono(n.tipo), color: Colors.white, size: 20),
        ),
        title: Text(
          n.titulo,
          style: TextStyle(
            fontWeight: n.leida ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(n.mensaje),
        trailing: Text(
          '${n.fecha.day}/${n.fecha.month}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () => _service.marcarLeida(n.id),
      ),
    );
  },
);
        }
    )
    );
  }
}
