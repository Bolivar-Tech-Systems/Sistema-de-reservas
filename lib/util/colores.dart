import 'package:flutter/material.dart';

class Colores {
  // Fondos 
  static const Color background    = Color.fromRGBO( 13,  17,  23, 1); // negro base (fondo principal)
  static const Color surface       = Color.fromRGBO( 22,  27,  34, 1); // cards y paneles
  static const Color border        = Color.fromRGBO( 48,  54,  61, 1); // bordes sutiles

  // Acento violeta — solo para CTAs, badges, highlights
  static const Color primary       = Color.fromRGBO(124, 111, 247, 1); // violeta principal
  static const Color primaryDark   = Color.fromRGBO( 74,  63, 199, 1); // botones/fondo de CTA

  // Texto
  static const Color text          = Color.fromRGBO(230, 237, 243, 1); // texto principal (blanco suave)
  static const Color textSecondary = Color.fromRGBO(139, 148, 158, 1); // texto secundario/labels
  static const Color textMuted     = Color.fromRGBO( 72,  79,  88, 1); // texto deshabilitado/placeholders

  // Iconos
  static const Color icon          = Color.fromRGBO(139, 148, 158, 1); // iconos por defecto
  static const Color iconActive    = Color.fromRGBO(124, 111, 247, 1); // iconos activos

  // Semánticos
  static const Color danger        = Color.fromRGBO(226,  75,  74, 1); // errores / no disponible
}