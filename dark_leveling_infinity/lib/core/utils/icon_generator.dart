/// Generatore dell'icona dell'app Dark Leveling Infinity
/// Crea l'icona programmaticamente con canvas
library;

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Genera l'icona dell'app e la salva come file PNG
class IconGenerator {
  /// Genera l'icona dell'app con dimensione specificata
  static Future<ui.Image> generaIcona({int dimensione = 1024}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    // === SFONDO ===
    // Gradiente scuro con viola
    final sfondoPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(d * 0.5, d * 0.4),
        d * 0.8,
        [
          const Color(0xFF1A1A3E),
          const Color(0xFF0A0A1A),
          const Color(0xFF050510),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), sfondoPaint);

    // === CERCHIO PORTALE/GATE ===
    // Cerchio esterno glow
    final glowPaint = Paint()
      ..color = const Color(0x447B2FF7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(d * 0.5, d * 0.48), d * 0.35, glowPaint);

    // Cerchio portale viola
    final portalePaint = Paint()
      ..color = const Color(0xFF7B2FF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.03;
    canvas.drawCircle(Offset(d * 0.5, d * 0.48), d * 0.3, portalePaint);

    // Cerchio interno blu
    final internoPaint = Paint()
      ..color = const Color(0xFF3D5AFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.015;
    canvas.drawCircle(Offset(d * 0.5, d * 0.48), d * 0.22, internoPaint);

    // Centro del portale (glow)
    final centroPaint = Paint()
      ..color = const Color(0x557B2FF7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(d * 0.5, d * 0.48), d * 0.18, centroPaint);

    // === SILHOUETTE GUERRIERO ===
    // Corpo
    final guerrieroPaint = Paint()..color = const Color(0xFF0A0A1A);
    
    // Testa
    canvas.drawRect(
      Rect.fromLTWH(d * 0.44, d * 0.25, d * 0.12, d * 0.1),
      guerrieroPaint,
    );
    
    // Corpo
    canvas.drawRect(
      Rect.fromLTWH(d * 0.40, d * 0.35, d * 0.20, d * 0.25),
      guerrieroPaint,
    );
    
    // Gambe
    canvas.drawRect(
      Rect.fromLTWH(d * 0.41, d * 0.60, d * 0.08, d * 0.15),
      guerrieroPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(d * 0.51, d * 0.60, d * 0.08, d * 0.15),
      guerrieroPaint,
    );

    // Spada (lato destro, inclinata)
    final spadaPaint = Paint()..color = const Color(0xFFBBDEFB);
    canvas.drawRect(
      Rect.fromLTWH(d * 0.62, d * 0.18, d * 0.03, d * 0.40),
      spadaPaint,
    );
    
    // Elsa spada
    final elsaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(
      Rect.fromLTWH(d * 0.58, d * 0.38, d * 0.10, d * 0.025),
      elsaPaint,
    );

    // === OCCHI LUMINOSI ===
    final occhiPaint = Paint()
      ..color = const Color(0xFF448AFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(
      Rect.fromLTWH(d * 0.46, d * 0.29, d * 0.03, d * 0.015),
      occhiPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(d * 0.51, d * 0.29, d * 0.03, d * 0.015),
      occhiPaint,
    );

    // Glow degli occhi
    final glowOcchiPaint = Paint()
      ..color = const Color(0x66448AFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
      Rect.fromLTWH(d * 0.44, d * 0.27, d * 0.12, d * 0.04),
      glowOcchiPaint,
    );

    // === AURA DELLE OMBRE ===
    // Particelle di ombra intorno al guerriero
    final ombraPaint = Paint()
      ..color = const Color(0x447B2FF7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    // Fiamme d'ombra ai lati
    canvas.drawRect(
      Rect.fromLTWH(d * 0.32, d * 0.40, d * 0.06, d * 0.20),
      ombraPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(d * 0.62, d * 0.40, d * 0.06, d * 0.20),
      ombraPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(d * 0.35, d * 0.50, d * 0.04, d * 0.15),
      ombraPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(d * 0.61, d * 0.50, d * 0.04, d * 0.15),
      ombraPaint,
    );

    // === TESTO "DL" ===
    // Bordo inferiore con le iniziali
    final testoPaint = Paint()..color = const Color(0xFFFFD700);
    
    // Lettera D (semplificata con rettangoli)
    // Barra verticale
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.80, d * 0.025, d * 0.10), testoPaint);
    // Barre orizzontali
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.80, d * 0.06, d * 0.02), testoPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.88, d * 0.06, d * 0.02), testoPaint);
    // Barra verticale destra
    canvas.drawRect(Rect.fromLTWH(d * 0.37, d * 0.81, d * 0.02, d * 0.08), testoPaint);

    // Lettera L
    canvas.drawRect(Rect.fromLTWH(d * 0.42, d * 0.80, d * 0.025, d * 0.10), testoPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.42, d * 0.88, d * 0.06, d * 0.02), testoPaint);

    // Simbolo ∞ (semplificato)
    final infPaint = Paint()
      ..color = const Color(0xFF7B2FF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.012;
    canvas.drawCircle(Offset(d * 0.56, d * 0.85), d * 0.03, infPaint);
    canvas.drawCircle(Offset(d * 0.64, d * 0.85), d * 0.03, infPaint);

    // === BORDO DECORATIVO ===
    final bordoPaint = Paint()
      ..color = const Color(0xFF7B2FF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.008;
    
    // Angoli decorativi
    final cornerSize = d * 0.08;
    // Top-left
    canvas.drawLine(Offset(d * 0.05, d * 0.05), Offset(d * 0.05 + cornerSize, d * 0.05), bordoPaint);
    canvas.drawLine(Offset(d * 0.05, d * 0.05), Offset(d * 0.05, d * 0.05 + cornerSize), bordoPaint);
    // Top-right
    canvas.drawLine(Offset(d * 0.95, d * 0.05), Offset(d * 0.95 - cornerSize, d * 0.05), bordoPaint);
    canvas.drawLine(Offset(d * 0.95, d * 0.05), Offset(d * 0.95, d * 0.05 + cornerSize), bordoPaint);
    // Bottom-left
    canvas.drawLine(Offset(d * 0.05, d * 0.95), Offset(d * 0.05 + cornerSize, d * 0.95), bordoPaint);
    canvas.drawLine(Offset(d * 0.05, d * 0.95), Offset(d * 0.05, d * 0.95 - cornerSize), bordoPaint);
    // Bottom-right
    canvas.drawLine(Offset(d * 0.95, d * 0.95), Offset(d * 0.95 - cornerSize, d * 0.95), bordoPaint);
    canvas.drawLine(Offset(d * 0.95, d * 0.95), Offset(d * 0.95, d * 0.95 - cornerSize), bordoPaint);

    final picture = recorder.endRecording();
    return picture.toImage(dimensione, dimensione);
  }

  /// Salva l'icona come file PNG
  static Future<void> salvaIcona(String percorso, {int dimensione = 1024}) async {
    final image = await generaIcona(dimensione: dimensione);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final file = File(percorso);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }
}
