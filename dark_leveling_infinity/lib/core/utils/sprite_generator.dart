/// Generatore di sprite procedurale per Dark Leveling Infinity
/// Crea sprite pixel art programmaticamente per tutti gli elementi del gioco
library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Generatore di sprite pixel art procedurali
/// Ogni sprite è generato algoritmicamente con variazioni casuali
class SpriteGenerator {
  static final Random _rng = Random();

  /// Crea una texture rettangolare con un colore e pattern
  static Future<Sprite> creaSpriteSolido(
    double larghezza,
    double altezza,
    Color colore, {
    bool conBordo = true,
    Color coloreBordo = Colors.black,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = larghezza.toInt();
    final h = altezza.toInt();

    // Riempimento principale
    final paint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), paint);

    // Bordo opzionale
    if (conBordo) {
      final borderPaint =
          Paint()
            ..color = coloreBordo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        borderPaint,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    return Sprite(image);
  }

  /// Genera sprite del player - guerriero stilizzato
  static Future<Sprite> generaPlayer({int dimensione = 32}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    // Corpo principale - armatura scura
    final corpoPaint = Paint()..color = const Color(0xFF2C2C44);
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.25, d * 0.4, d * 0.5), corpoPaint);

    // Testa
    final testaPaint = Paint()..color = const Color(0xFFE8C4A0);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.1, d * 0.3, d * 0.2), testaPaint);

    // Capelli scuri
    final capelliPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(d * 0.33, d * 0.08, d * 0.34, d * 0.08), capelliPaint);

    // Occhi luminosi (stile Solo Leveling - blu brillante)
    final occhiPaint = Paint()..color = const Color(0xFF448AFF);
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.18, d * 0.06, d * 0.04), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.56, d * 0.18, d * 0.06, d * 0.04), occhiPaint);

    // Aura viola
    final auraPaint =
        Paint()
          ..color = const Color(0x447B2FF7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.15, d * 0.6, d * 0.65), auraPaint);

    // Spada (lato destro)
    final spadaPaint = Paint()..color = const Color(0xFFBBDEFB);
    canvas.drawRect(Rect.fromLTWH(d * 0.72, d * 0.15, d * 0.06, d * 0.55), spadaPaint);

    // Elsa della spada
    final elsaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(d * 0.68, d * 0.40, d * 0.14, d * 0.04), elsaPaint);

    // Gambe
    final gambePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.75, d * 0.15, d * 0.2), gambePaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.53, d * 0.75, d * 0.15, d * 0.2), gambePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  /// Genera sprite nemico generico con variazioni basate sul tipo
  static Future<Sprite> generaNemico({
    required String tipo,
    int dimensione = 32,
    Color? coloreBase,
    double scala = 1.0,
  }) async {
    final dim = (dimensione * scala).toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dim.toDouble();

    final colore = coloreBase ?? _getColoreNemico(tipo);

    switch (tipo) {
      case 'melee':
        _disegnaNemicoMelee(canvas, d, colore);
        break;
      case 'ranged':
        _disegnaNemicoRanged(canvas, d, colore);
        break;
      case 'flyer':
        _disegnaNemicoVolante(canvas, d, colore);
        break;
      case 'tank':
        _disegnaNemicoTank(canvas, d, colore);
        break;
      case 'boss':
        _disegnaBoss(canvas, d, colore);
        break;
      default:
        _disegnaNemicoBase(canvas, d, colore);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  /// Genera tile per il dungeon
  static Future<Sprite> generaTile({
    required String tipo,
    int dimensione = 32,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    switch (tipo) {
      case 'pavimento':
        _disegnaPavimento(canvas, d);
        break;
      case 'muro':
        _disegnaMuro(canvas, d);
        break;
      case 'porta':
        _disegnaPorta(canvas, d);
        break;
      case 'scale':
        _disegnaScale(canvas, d);
        break;
      case 'vuoto':
        _disegnaVuoto(canvas, d);
        break;
      default:
        _disegnaPavimento(canvas, d);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  /// Genera sprite per gli effetti particellari
  static Future<Sprite> generaParticella({
    Color colore = Colors.white,
    int dimensione = 8,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    final paint =
        Paint()
          ..color = colore
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(d / 2, d / 2), d / 3, paint);

    final innerPaint = Paint()..color = colore.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(d / 2, d / 2), d / 5, innerPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  /// Genera sprite per item/loot
  static Future<Sprite> generaItem({
    required String tipo,
    required Color coloreRarita,
    int dimensione = 24,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    // Sfondo con glow della rarità
    final glowPaint =
        Paint()
          ..color = coloreRarita.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), glowPaint);

    // Bordo rarità
    final borderPaint =
        Paint()
          ..color = coloreRarita
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(1, 1, d - 2, d - 2), borderPaint);

    // Icona in base al tipo
    final itemPaint = Paint()..color = coloreRarita;
    switch (tipo) {
      case 'spada':
        canvas.drawRect(Rect.fromLTWH(d * 0.45, d * 0.1, d * 0.1, d * 0.6), itemPaint);
        canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.55, d * 0.4, d * 0.08), itemPaint);
        break;
      case 'scudo':
        canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.2, d * 0.5, d * 0.6), itemPaint);
        break;
      case 'pozione':
        canvas.drawCircle(Offset(d / 2, d * 0.55), d * 0.2, itemPaint);
        canvas.drawRect(Rect.fromLTWH(d * 0.42, d * 0.2, d * 0.16, d * 0.25), itemPaint);
        break;
      default:
        canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.3, d * 0.4, d * 0.4), itemPaint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  /// Genera icona per le ombre (Shadow Army)
  static Future<Sprite> generaOmbra({
    required Color colore,
    int dimensione = 32,
    double scala = 1.0,
  }) async {
    final dim = (dimensione * scala).toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dim.toDouble();

    // Aura scura
    final auraPaint =
        Paint()
          ..color = const Color(0x44311B92)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(Rect.fromLTWH(d * 0.1, d * 0.1, d * 0.8, d * 0.8), auraPaint);

    // Corpo ombra (semi-trasparente)
    final corpoPaint = Paint()..color = colore.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.2, d * 0.4, d * 0.55), corpoPaint);

    // Testa
    final testaPaint = Paint()..color = colore.withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.1, d * 0.3, d * 0.15), testaPaint);

    // Occhi rossi brillanti
    final occhiPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.15, d * 0.06, d * 0.04), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.56, d * 0.15, d * 0.06, d * 0.04), occhiPaint);

    // Effetto fumo ombra (parti inferiori sbiadite)
    final fumoPaint =
        Paint()
          ..color = colore.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.7, d * 0.6, d * 0.25), fumoPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  // --- Metodi privati per disegnare tipi specifici di nemici ---

  static void _disegnaNemicoBase(Canvas canvas, double d, Color colore) {
    final paint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.2, d * 0.5, d * 0.6), paint);

    // Occhi
    final occhiPaint = Paint()..color = const Color(0xFFFF0000);
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.3, d * 0.08, d * 0.06), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.6, d * 0.3, d * 0.08, d * 0.06), occhiPaint);
  }

  static void _disegnaNemicoMelee(Canvas canvas, double d, Color colore) {
    // Corpo muscoloso
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.25, d * 0.55, d * 0.5), corpoPaint);

    // Testa
    final testaPaint = Paint()..color = colore.withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.1, d * 0.35, d * 0.2), testaPaint);

    // Arma
    final armaPaint = Paint()..color = const Color(0xFFBDBDBD);
    canvas.drawRect(Rect.fromLTWH(d * 0.75, d * 0.15, d * 0.08, d * 0.5), armaPaint);

    // Occhi rossi
    final occhiPaint = Paint()..color = const Color(0xFFFF0000);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.18, d * 0.06, d * 0.04), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.54, d * 0.18, d * 0.06, d * 0.04), occhiPaint);
  }

  static void _disegnaNemicoRanged(Canvas canvas, double d, Color colore) {
    // Corpo snello
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.2, d * 0.4, d * 0.5), corpoPaint);

    // Testa con cappuccio
    final cappuccioPaint = Paint()..color = colore.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(d * 0.28, d * 0.08, d * 0.44, d * 0.2), cappuccioPaint);

    // Arco
    final arcoPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTWH(d * 0.72, d * 0.15, d * 0.04, d * 0.55), arcoPaint);

    // Occhi verdi
    final occhiPaint = Paint()..color = const Color(0xFF76FF03);
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.15, d * 0.05, d * 0.04), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.57, d * 0.15, d * 0.05, d * 0.04), occhiPaint);
  }

  static void _disegnaNemicoVolante(Canvas canvas, double d, Color colore) {
    // Ali
    final aliPaint = Paint()..color = colore.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(d * 0.05, d * 0.2, d * 0.25, d * 0.3), aliPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.7, d * 0.2, d * 0.25, d * 0.3), aliPaint);

    // Corpo
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.25, d * 0.4, d * 0.4), corpoPaint);

    // Occhi gialli
    final occhiPaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.3, d * 0.07, d * 0.05), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.58, d * 0.3, d * 0.07, d * 0.05), occhiPaint);
  }

  static void _disegnaNemicoTank(Canvas canvas, double d, Color colore) {
    // Corpo largo e pesante
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.15, d * 0.2, d * 0.7, d * 0.6), corpoPaint);

    // Armatura
    final armaturaPaint = Paint()..color = const Color(0xFF616161);
    canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.25, d * 0.6, d * 0.5), armaturaPaint);

    // Testa piccola
    final testaPaint = Paint()..color = colore.withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.08, d * 0.3, d * 0.18), testaPaint);

    // Occhi arancioni
    final occhiPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.13, d * 0.06, d * 0.05), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.56, d * 0.13, d * 0.06, d * 0.05), occhiPaint);
  }

  static void _disegnaBoss(Canvas canvas, double d, Color colore) {
    // Aura potente
    final auraPaint =
        Paint()
          ..color = const Color(0x44FF1744)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRect(Rect.fromLTWH(d * 0.05, d * 0.05, d * 0.9, d * 0.9), auraPaint);

    // Corpo massiccio
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.15, d * 0.15, d * 0.7, d * 0.7), corpoPaint);

    // Corona/corna
    final coronaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.03, d * 0.08, d * 0.15), coronaPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.67, d * 0.03, d * 0.08, d * 0.15), coronaPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.03, d * 0.5, d * 0.06), coronaPaint);

    // Occhi boss (grandi e brillanti)
    final occhiPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.25, d * 0.12, d * 0.08), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.63, d * 0.25, d * 0.12, d * 0.08), occhiPaint);

    // Glow occhi
    final glowPaint =
        Paint()
          ..color = const Color(0x66FF1744)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromLTWH(d * 0.22, d * 0.22, d * 0.18, d * 0.14), glowPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.60, d * 0.22, d * 0.18, d * 0.14), glowPaint);
  }

  // --- Metodi per disegnare tiles ---

  static void _disegnaPavimento(Canvas canvas, double d) {
    // Base scura
    final basePaint = Paint()..color = const Color(0xFF2C2C44);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), basePaint);

    // Texture pietra
    final dettaglioPaint = Paint()..color = const Color(0xFF363652);
    for (int i = 0; i < 3; i++) {
      final x = _rng.nextDouble() * d * 0.8;
      final y = _rng.nextDouble() * d * 0.8;
      canvas.drawRect(
        Rect.fromLTWH(x, y, d * 0.15, d * 0.1),
        dettaglioPaint,
      );
    }

    // Bordo tile
    final bordoPaint =
        Paint()
          ..color = const Color(0xFF1A1A2E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), bordoPaint);
  }

  static void _disegnaMuro(Canvas canvas, double d) {
    // Muro pieno scuro
    final basePaint = Paint()..color = const Color(0xFF12121A);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), basePaint);

    // Mattoni
    final mattonePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(1, 1, d * 0.45, d * 0.45), mattonePaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.5, 1, d * 0.45, d * 0.45), mattonePaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.5, d * 0.45, d * 0.45), mattonePaint);

    // Bordo
    final bordoPaint =
        Paint()
          ..color = const Color(0xFF0A0A0F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), bordoPaint);
  }

  static void _disegnaPorta(Canvas canvas, double d) {
    // Sfondo
    _disegnaPavimento(canvas, d);

    // Porta
    final portaPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.1, d * 0.6, d * 0.8), portaPaint);

    // Maniglia
    final manigliaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(d * 0.6, d * 0.45, d * 0.08, d * 0.08), manigliaPaint);

    // Glow porta
    final glowPaint =
        Paint()
          ..color = const Color(0x337B2FF7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromLTWH(d * 0.15, d * 0.05, d * 0.7, d * 0.9), glowPaint);
  }

  static void _disegnaScale(Canvas canvas, double d) {
    _disegnaPavimento(canvas, d);

    // Scale
    final scalePaint = Paint()..color = const Color(0xFF455A64);
    for (int i = 0; i < 4; i++) {
      final y = d * 0.2 + (i * d * 0.15);
      final w = d * 0.8 - (i * d * 0.1);
      canvas.drawRect(Rect.fromLTWH((d - w) / 2, y, w, d * 0.12), scalePaint);
    }
  }

  static void _disegnaVuoto(Canvas canvas, double d) {
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), paint);
  }

  /// Ottieni colore base per tipo di nemico
  static Color _getColoreNemico(String tipo) {
    switch (tipo) {
      case 'melee':
        return const Color(0xFF8B0000);
      case 'ranged':
        return const Color(0xFF1B5E20);
      case 'flyer':
        return const Color(0xFF4A148C);
      case 'tank':
        return const Color(0xFF455A64);
      case 'boss':
        return const Color(0xFFB71C1C);
      case 'summoner':
        return const Color(0xFF311B92);
      case 'healer':
        return const Color(0xFF1B5E20);
      case 'kamikaze':
        return const Color(0xFFFF6F00);
      case 'stealth':
        return const Color(0xFF263238);
      case 'poisoner':
        return const Color(0xFF33691E);
      case 'freezer':
        return const Color(0xFF0277BD);
      case 'burner':
        return const Color(0xFFBF360C);
      default:
        return const Color(0xFF616161);
    }
  }

  /// Genera sprite per il gate (portale)
  static Future<Sprite> generaGate({
    required Color colore,
    int dimensione = 64,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    // Aura esterna
    final auraPaint =
        Paint()
          ..color = colore.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.45, auraPaint);

    // Cerchio portale
    final portalePaint =
        Paint()
          ..color = colore.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.35, portalePaint);

    // Centro del portale (effetto vortice)
    final centroPaint =
        Paint()
          ..color = colore.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.25, centroPaint);

    // Cerchio interno
    final internoPaint =
        Paint()
          ..color = colore
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.2, internoPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  /// Genera sprite per l'icona di un'abilità
  static Future<Sprite> generaIconaAbilita({
    required Color colore,
    required String simbolo,
    int dimensione = 48,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final d = dimensione.toDouble();

    // Sfondo scuro
    final sfondoPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), sfondoPaint);

    // Glow del colore
    final glowPaint =
        Paint()
          ..color = colore.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(Rect.fromLTWH(d * 0.1, d * 0.1, d * 0.8, d * 0.8), glowPaint);

    // Icona centrale
    final iconaPaint = Paint()..color = colore;
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.25, iconaPaint);

    // Bordo
    final bordoPaint =
        Paint()
          ..color = colore
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(2, 2, d - 4, d - 4), bordoPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }
}
