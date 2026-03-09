/// Widget Minimap per il HUD di Dark Leveling Infinity
/// Mostra una mappa in miniatura del dungeon con posizione player e nemici
library;

import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Dati di un punto sulla minimap
class MinimapPoint {
  final double x;
  final double y;
  final MinimapPointType tipo;

  const MinimapPoint(this.x, this.y, this.tipo);
}

/// Tipo di punto sulla minimap
enum MinimapPointType {
  player,
  nemico,
  boss,
  ombra,
  loot,
  porta,
  gate,
}

/// Widget minimap che mostra il dungeon dall'alto
class MinimapWidget extends StatelessWidget {
  final double playerX;
  final double playerY;
  final List<MinimapPoint> punti;
  final double dimensione;
  final double raggio; // raggio di visualizzazione in unità di gioco
  final List<List<int>>? tilemap; // griglia del dungeon per mostrare muri

  const MinimapWidget({
    super.key,
    required this.playerX,
    required this.playerY,
    this.punti = const [],
    this.dimensione = 100,
    this.raggio = 200,
    this.tilemap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimensione,
      height: dimensione,
      decoration: BoxDecoration(
        color: GameColors.backgroundDark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(dimensione / 2),
        border: Border.all(
          color: GameColors.primaryPurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.primaryPurple.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(dimensione, dimensione),
          painter: _MinimapPainter(
            playerX: playerX,
            playerY: playerY,
            punti: punti,
            raggio: raggio,
          ),
        ),
      ),
    );
  }
}

/// Painter per la minimap
class _MinimapPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final List<MinimapPoint> punti;
  final double raggio;

  _MinimapPainter({
    required this.playerX,
    required this.playerY,
    required this.punti,
    required this.raggio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final scala = size.width / (raggio * 2);

    // Sfondo scuro con gradiente radiale
    final sfondoPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.backgroundMedium.withValues(alpha: 0.8),
          GameColors.backgroundDark.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromCircle(center: centro, radius: size.width / 2));
    canvas.drawCircle(centro, size.width / 2, sfondoPaint);

    // Griglia di riferimento
    final gridPaint = Paint()
      ..color = GameColors.borderDefault.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Cerchi concentrici di distanza
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(centro, (size.width / 2) * (i / 3), gridPaint);
    }

    // Linee croce
    canvas.drawLine(
      Offset(centro.dx, 0),
      Offset(centro.dx, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, centro.dy),
      Offset(size.width, centro.dy),
      gridPaint,
    );

    // Disegna i punti relativi alla posizione del player
    for (final punto in punti) {
      final dx = (punto.x - playerX) * scala;
      final dy = (punto.y - playerY) * scala;

      // Controlla se il punto è nel raggio visibile
      final distanza = sqrt(dx * dx + dy * dy);
      if (distanza > size.width / 2 - 4) continue;

      final pos = Offset(centro.dx + dx, centro.dy + dy);

      // Colore e dimensione basati sul tipo
      Color colore;
      double dim;

      switch (punto.tipo) {
        case MinimapPointType.player:
          colore = GameColors.accentCyan;
          dim = 4;
          break;
        case MinimapPointType.nemico:
          colore = GameColors.healthRed;
          dim = 2;
          break;
        case MinimapPointType.boss:
          colore = GameColors.healthRed;
          dim = 4;
          break;
        case MinimapPointType.ombra:
          colore = GameColors.primaryPurple;
          dim = 2.5;
          break;
        case MinimapPointType.loot:
          colore = GameColors.accentGold;
          dim = 2;
          break;
        case MinimapPointType.porta:
          colore = GameColors.neonBlue;
          dim = 1.5;
          break;
        case MinimapPointType.gate:
          colore = GameColors.neonPurple;
          dim = 3;
          break;
      }

      final pointPaint = Paint()..color = colore;
      canvas.drawCircle(pos, dim, pointPaint);

      // Glow per boss e gate
      if (punto.tipo == MinimapPointType.boss || punto.tipo == MinimapPointType.gate) {
        final glowPaint = Paint()
          ..color = colore.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(pos, dim * 2, glowPaint);
      }
    }

    // Disegna il player al centro (sempre visibile)
    // Triangolo direzionale
    final playerPaint = Paint()..color = GameColors.accentCyan;
    canvas.drawCircle(centro, 3.5, playerPaint);

    // Glow del player
    final playerGlow = Paint()
      ..color = GameColors.accentCyan.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(centro, 6, playerGlow);

    // Anello esterno pulse-like
    final ringPaint = Paint()
      ..color = GameColors.accentCyan.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(centro, 8, ringPaint);

    // Indicatore "N" (nord) in alto
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          fontFamily: 'GameFont',
          fontSize: 7,
          color: GameColors.textDimmed,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centro.dx - textPainter.width / 2, 3),
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) {
    return oldDelegate.playerX != playerX ||
        oldDelegate.playerY != playerY ||
        oldDelegate.punti.length != punti.length;
  }
}
