import 'package:flutter/material.dart';

class Colores {
  // ── Fondos ──────────────────────────────────────────────────────────
  static const Color background = Color.fromRGBO(13, 17, 23, 1); // negro base
  static const Color surface = Color.fromRGBO(22, 27, 34, 1); // cards y paneles
  static const Color surfaceAlt = Color.fromRGBO(
    30,
    36,
    45,
    1,
  ); // superficie elevada
  static const Color border = Color.fromRGBO(48, 54, 61, 1); // bordes sutiles
  static const Color borderLight = Color.fromRGBO(
    62,
    70,
    80,
    1,
  ); // bordes activos

  // ── Acento violeta ──────────────────────────────────────────────────
  static const Color primary = Color.fromRGBO(
    124,
    111,
    247,
    1,
  ); // violeta principal
  static const Color primaryDark = Color.fromRGBO(
    74,
    63,
    199,
    1,
  ); // CTA/botones
  static const Color primarySoft = Color.fromRGBO(
    124,
    111,
    247,
    1,
  ); // alias legible

  // ── Semánticos ──────────────────────────────────────────────────────
  static const Color danger = Color.fromRGBO(
    226,
    75,
    74,
    1,
  ); // error / cancelado
  static const Color success = Color.fromRGBO(52, 199, 120, 1); // activo / OK
  static const Color warning = Color.fromRGBO(
    245,
    158,
    11,
    1,
  ); // pendiente / alerta
  static const Color info = Color.fromRGBO(
    56,
    189,
    248,
    1,
  ); // info / disponible

  // ── Texto ───────────────────────────────────────────────────────────
  static const Color text = Color.fromRGBO(230, 237, 243, 1); // blanco suave
  static const Color textSecondary = Color.fromRGBO(
    139,
    148,
    158,
    1,
  ); // labels/subtítulos
  static const Color textMuted = Color.fromRGBO(72, 79, 88, 1); // deshabilitado

  // ── Iconos ──────────────────────────────────────────────────────────
  static const Color icon = Color.fromRGBO(139, 148, 158, 1);
  static const Color iconActive = Color.fromRGBO(124, 111, 247, 1);
  // ── Variados ──────────────────────────────────────────────────────────
  static final Color categoryGlow = const Color.fromRGBO(124, 111, 247, 0.18);

  static final Color cardOverlay = const Color.fromRGBO(13, 17, 23, 0.72);

  static final Color tagAvailable = const Color.fromRGBO(52, 199, 120, 0.15);

  static final Color tagUnavailable = const Color.fromRGBO(226, 75, 74, 0.15);

  static const List<Color> catColors = [
    Color.fromRGBO(124, 111, 247, 1), // violeta
    Color.fromRGBO(56, 189, 248, 1), // info azul
    Color.fromRGBO(52, 199, 120, 1), // verde
    Color.fromRGBO(245, 158, 11, 1), // ámbar
    Color.fromRGBO(226, 75, 74, 1), // rojo
    Color.fromRGBO(99, 102, 241, 1), // índigo
  ];
}
