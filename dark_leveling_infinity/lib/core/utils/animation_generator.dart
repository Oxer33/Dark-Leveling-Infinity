/// Generatore di animazioni sprite per Dark Leveling Infinity
/// Crea sprite sheet animate proceduralmente per player, nemici e ombre
library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

/// Generatore di sprite sheet animate procedurali
/// Ogni animazione ha frame multipli per idle, walk, attack, die
class AnimationGenerator {
  static final Random _rng = Random();

  // ─── PLAYER ANIMATIONS ───

  /// Genera tutte le animazioni del player
  /// Ritorna una mappa di SpriteAnimation per ogni stato
  static Future<Map<String, SpriteAnimation>> generaAnimazioniPlayer({
    int dimensione = 32,
    int framePerAnimazione = 4,
    double stepTime = 0.15,
  }) async {
    final animazioni = <String, SpriteAnimation>{};

    // Idle (4 frame - leggero breathing)
    animazioni['idle'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 4,
      stepTime: 0.3,
      disegnaFrame: (canvas, d, frame) {
        _disegnaPlayerBase(canvas, d);
        // Breathing effect: leggero spostamento verticale
        final offsetY = sin(frame * pi / 2) * d * 0.02;
        _disegnaPlayerDettagli(canvas, d, offsetY: offsetY);
      },
    );

    // Camminata (6 frame - gambe alternate)
    animazioni['cammina'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 6,
      stepTime: 0.12,
      disegnaFrame: (canvas, d, frame) {
        _disegnaPlayerBase(canvas, d);
        // Gambe alternate durante la camminata
        final legOffset = sin(frame * pi / 3) * d * 0.04;
        _disegnaPlayerGambe(canvas, d, offsetGamba: legOffset);
        _disegnaPlayerDettagli(canvas, d, offsetY: sin(frame * pi / 3) * d * 0.01);
      },
    );

    // Attacco (4 frame - swing della spada)
    animazioni['attacca'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 4,
      stepTime: 0.08,
      disegnaFrame: (canvas, d, frame) {
        _disegnaPlayerBase(canvas, d);
        _disegnaPlayerDettagli(canvas, d);
        // Spada swing: rotazione progressiva
        _disegnaPlayerSpadaSwing(canvas, d, frame: frame, maxFrame: 4);
      },
    );

    // Schivata (3 frame - blur effect)
    animazioni['schiva'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 3,
      stepTime: 0.07,
      disegnaFrame: (canvas, d, frame) {
        // Afterimage sbiadita
        final alpha = 0.3 + frame * 0.2;
        _disegnaPlayerBase(canvas, d, alpha: alpha);
        // Scia di schivata
        final trailPaint = Paint()
          ..color = const Color(0x4400BCD4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRect(
          Rect.fromLTWH(d * 0.2, d * 0.15, d * 0.6, d * 0.7),
          trailPaint,
        );
      },
    );

    // Ferito (2 frame - flash rosso)
    animazioni['ferito'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 2,
      stepTime: 0.1,
      disegnaFrame: (canvas, d, frame) {
        _disegnaPlayerBase(canvas, d);
        _disegnaPlayerDettagli(canvas, d);
        // Flash rosso alternato
        if (frame % 2 == 0) {
          final flashPaint = Paint()
            ..color = const Color(0x44FF0000)
            ..blendMode = BlendMode.screen;
          canvas.drawRect(Rect.fromLTWH(0, 0, d, d), flashPaint);
        }
      },
    );

    // Morte (4 frame - caduta e dissoluzione)
    animazioni['morto'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 4,
      stepTime: 0.25,
      disegnaFrame: (canvas, d, frame) {
        final alpha = 1.0 - (frame / 4);
        _disegnaPlayerBase(canvas, d, alpha: alpha);
        // Inclinazione progressiva
        final rotazione = frame * 0.2;
        canvas.save();
        canvas.translate(d / 2, d / 2);
        canvas.rotate(rotazione);
        canvas.translate(-d / 2, -d / 2);
        _disegnaPlayerDettagli(canvas, d, offsetY: frame * d * 0.05);
        canvas.restore();
      },
    );

    // Cast abilità (4 frame - aura che cresce)
    animazioni['cast'] = await _generaAnimazione(
      dimensione: dimensione,
      numFrame: 4,
      stepTime: 0.15,
      disegnaFrame: (canvas, d, frame) {
        _disegnaPlayerBase(canvas, d);
        _disegnaPlayerDettagli(canvas, d);
        // Aura crescente
        final raggioAura = d * 0.2 + frame * d * 0.1;
        final auraPaint = Paint()
          ..color = Color.fromARGB((100 - frame * 15).clamp(20, 100), 123, 47, 247)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, raggioAura * 0.3);
        canvas.drawCircle(Offset(d / 2, d / 2), raggioAura, auraPaint);
      },
    );

    return animazioni;
  }

  // ─── NEMICO ANIMATIONS ───

  /// Genera animazioni per un nemico specifico
  static Future<Map<String, SpriteAnimation>> generaAnimazioniNemico({
    required String tipoAI,
    int dimensione = 32,
    Color? coloreBase,
    double scala = 1.0,
  }) async {
    final dim = (dimensione * scala).toInt();
    final colore = coloreBase ?? _getColoreNemico(tipoAI);
    final animazioni = <String, SpriteAnimation>{};

    // Idle (2 frame)
    animazioni['idle'] = await _generaAnimazione(
      dimensione: dim,
      numFrame: 2,
      stepTime: 0.5,
      disegnaFrame: (canvas, d, frame) {
        _disegnaNemicoPerTipo(canvas, d, tipoAI, colore);
        // Leggero bob
        if (frame == 1) {
          final bobPaint = Paint()..color = colore.withValues(alpha: 0.1);
          canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.8, d * 0.6, d * 0.05), bobPaint);
        }
      },
    );

    // Walk (4 frame)
    animazioni['cammina'] = await _generaAnimazione(
      dimensione: dim,
      numFrame: 4,
      stepTime: 0.15,
      disegnaFrame: (canvas, d, frame) {
        _disegnaNemicoPerTipo(canvas, d, tipoAI, colore);
        // Movimento gambe simulato
        final legOff = sin(frame * pi / 2) * d * 0.03;
        final legPaint = Paint()..color = colore.withValues(alpha: 0.5);
        canvas.drawRect(
          Rect.fromLTWH(d * 0.3, d * 0.7 + legOff, d * 0.15, d * 0.15),
          legPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(d * 0.55, d * 0.7 - legOff, d * 0.15, d * 0.15),
          legPaint,
        );
      },
    );

    // Attack (3 frame)
    animazioni['attacca'] = await _generaAnimazione(
      dimensione: dim,
      numFrame: 3,
      stepTime: 0.1,
      disegnaFrame: (canvas, d, frame) {
        _disegnaNemicoPerTipo(canvas, d, tipoAI, colore);
        // Flash attacco
        if (frame == 1) {
          final attackPaint = Paint()
            ..color = const Color(0x44FF0000)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          canvas.drawRect(Rect.fromLTWH(d * 0.1, d * 0.1, d * 0.8, d * 0.8), attackPaint);
        }
        // Proiettile/slash
        if (frame == 2) {
          final slashPaint = Paint()..color = const Color(0x88FFFFFF);
          canvas.drawRect(Rect.fromLTWH(d * 0.7, d * 0.3, d * 0.25, d * 0.04), slashPaint);
        }
      },
    );

    // Morte (3 frame)
    animazioni['morto'] = await _generaAnimazione(
      dimensione: dim,
      numFrame: 3,
      stepTime: 0.2,
      disegnaFrame: (canvas, d, frame) {
        final alpha = 1.0 - (frame / 3);
        final fadeColore = colore.withValues(alpha: alpha);
        _disegnaNemicoPerTipo(canvas, d, tipoAI, fadeColore);
        // Particelle di dissoluzione
        for (int p = 0; p < frame * 3; p++) {
          final px = _rng.nextDouble() * d;
          final py = _rng.nextDouble() * d;
          final pPaint = Paint()..color = colore.withValues(alpha: alpha * 0.5);
          canvas.drawCircle(Offset(px, py), 1.5, pPaint);
        }
      },
    );

    return animazioni;
  }

  // ─── HELPER METHODS ───

  /// Genera una singola SpriteAnimation
  static Future<SpriteAnimation> _generaAnimazione({
    required int dimensione,
    required int numFrame,
    required double stepTime,
    required void Function(Canvas canvas, double d, int frame) disegnaFrame,
  }) async {
    final sprites = <Sprite>[];

    for (int f = 0; f < numFrame; f++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final d = dimensione.toDouble();

      disegnaFrame(canvas, d, f);

      final picture = recorder.endRecording();
      final image = await picture.toImage(dimensione, dimensione);
      sprites.add(Sprite(image));
    }

    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }

  // ─── DISEGNO PLAYER ───

  static void _disegnaPlayerBase(Canvas canvas, double d, {double alpha = 1.0}) {
    // Corpo armatura scura
    final corpoPaint = Paint()..color = const Color(0xFF2C2C44).withValues(alpha: alpha);
    canvas.drawRect(Rect.fromLTWH(d * 0.3, d * 0.28, d * 0.4, d * 0.45), corpoPaint);

    // Spallacci
    final spallaPaint = Paint()..color = const Color(0xFF3D3D5C).withValues(alpha: alpha);
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.28, d * 0.12, d * 0.08), spallaPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.63, d * 0.28, d * 0.12, d * 0.08), spallaPaint);

    // Testa
    final testaPaint = Paint()..color = const Color(0xFFE8C4A0).withValues(alpha: alpha);
    canvas.drawRect(Rect.fromLTWH(d * 0.37, d * 0.12, d * 0.26, d * 0.18), testaPaint);

    // Capelli
    final capelliPaint = Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: alpha);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.08, d * 0.30, d * 0.08), capelliPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.10, d * 0.06, d * 0.12), capelliPaint); // ciuffo sx
  }

  static void _disegnaPlayerDettagli(Canvas canvas, double d, {double offsetY = 0}) {
    // Occhi luminosi blu
    final occhiPaint = Paint()..color = const Color(0xFF448AFF);
    canvas.drawRect(Rect.fromLTWH(d * 0.40, d * 0.19 + offsetY, d * 0.05, d * 0.03), occhiPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.55, d * 0.19 + offsetY, d * 0.05, d * 0.03), occhiPaint);

    // Glow occhi
    final glowPaint = Paint()
      ..color = const Color(0x33448AFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.17 + offsetY, d * 0.24, d * 0.07), glowPaint);

    // Aura viola sottile
    final auraPaint = Paint()
      ..color = const Color(0x227B2FF7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(Rect.fromLTWH(d * 0.18, d * 0.15, d * 0.64, d * 0.65), auraPaint);

    // Spada (posizione default)
    final spadaPaint = Paint()..color = const Color(0xFFBBDEFB);
    canvas.drawRect(Rect.fromLTWH(d * 0.72, d * 0.15, d * 0.05, d * 0.50), spadaPaint);

    // Elsa
    final elsaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(d * 0.68, d * 0.38, d * 0.13, d * 0.03), elsaPaint);

    // Cintura
    final cinturaPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(Rect.fromLTWH(d * 0.30, d * 0.55, d * 0.40, d * 0.03), cinturaPaint);

    // Fibbia cintura
    final fibbiaPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(d * 0.47, d * 0.54, d * 0.06, d * 0.05), fibbiaPaint);
  }

  static void _disegnaPlayerGambe(Canvas canvas, double d, {double offsetGamba = 0}) {
    final gambePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(d * 0.33, d * 0.73 + offsetGamba, d * 0.13, d * 0.20), gambePaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.54, d * 0.73 - offsetGamba, d * 0.13, d * 0.20), gambePaint);

    // Stivali
    final stivaliPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(d * 0.31, d * 0.88 + offsetGamba, d * 0.16, d * 0.07), stivaliPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.53, d * 0.88 - offsetGamba, d * 0.16, d * 0.07), stivaliPaint);
  }

  static void _disegnaPlayerSpadaSwing(Canvas canvas, double d, {required int frame, required int maxFrame}) {
    final angolo = -pi / 4 + (frame / maxFrame) * pi;
    final spadaPaint = Paint()..color = const Color(0xFFBBDEFB);
    final slashPaint = Paint()
      ..color = const Color(0x66BBDEFB)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.save();
    canvas.translate(d * 0.5, d * 0.4);
    canvas.rotate(angolo);

    // Lama
    canvas.drawRect(Rect.fromLTWH(-d * 0.025, -d * 0.35, d * 0.05, d * 0.35), spadaPaint);

    // Scia della lama
    canvas.drawRect(Rect.fromLTWH(-d * 0.04, -d * 0.30, d * 0.08, d * 0.25), slashPaint);

    canvas.restore();
  }

  // ─── DISEGNO NEMICI PER TIPO ───

  static void _disegnaNemicoPerTipo(Canvas canvas, double d, String tipoAI, Color colore) {
    switch (tipoAI) {
      case 'melee':
      case 'berserker':
        _disegnaNemicoMelee(canvas, d, colore);
        break;
      case 'ranged':
      case 'areaMage':
        _disegnaNemicoRanged(canvas, d, colore);
        break;
      case 'flyer':
        _disegnaNemicoVolante(canvas, d, colore);
        break;
      case 'tank':
      case 'reflector':
      case 'shielder':
        _disegnaNemicoTank(canvas, d, colore);
        break;
      case 'stealth':
      case 'hitAndRun':
        _disegnaNemicoStealth(canvas, d, colore);
        break;
      case 'summoner':
      case 'healer':
        _disegnaNemicoMago(canvas, d, colore);
        break;
      case 'kamikaze':
        _disegnaNemicoKamikaze(canvas, d, colore);
        break;
      default:
        _disegnaNemicoGenerico(canvas, d, colore);
    }
  }

  static void _disegnaNemicoMelee(Canvas canvas, double d, Color colore) {
    // Corpo muscoloso
    final corpoPaint = Paint()..color = colore;
    canvas.drawRect(Rect.fromLTWH(d * 0.22, d * 0.25, d * 0.52, d * 0.48), corpoPaint);

    // Testa
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.10, d * 0.32, d * 0.18), Paint()..color = colore.withValues(alpha: 0.85));

    // Braccia
    canvas.drawRect(Rect.fromLTWH(d * 0.12, d * 0.28, d * 0.12, d * 0.30), Paint()..color = colore.withValues(alpha: 0.7));
    canvas.drawRect(Rect.fromLTWH(d * 0.72, d * 0.28, d * 0.12, d * 0.30), Paint()..color = colore.withValues(alpha: 0.7));

    // Arma
    canvas.drawRect(Rect.fromLTWH(d * 0.78, d * 0.12, d * 0.06, d * 0.48), Paint()..color = const Color(0xFFBDBDBD));

    // Occhi rossi
    canvas.drawRect(Rect.fromLTWH(d * 0.36, d * 0.16, d * 0.06, d * 0.04), Paint()..color = const Color(0xFFFF0000));
    canvas.drawRect(Rect.fromLTWH(d * 0.54, d * 0.16, d * 0.06, d * 0.04), Paint()..color = const Color(0xFFFF0000));
  }

  static void _disegnaNemicoRanged(Canvas canvas, double d, Color colore) {
    // Corpo snello con cappuccio
    canvas.drawRect(Rect.fromLTWH(d * 0.30, d * 0.22, d * 0.38, d * 0.48), Paint()..color = colore);
    canvas.drawRect(Rect.fromLTWH(d * 0.28, d * 0.08, d * 0.42, d * 0.20), Paint()..color = colore.withValues(alpha: 0.7));

    // Mantello
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.25, d * 0.48, d * 0.52), Paint()..color = colore.withValues(alpha: 0.4));

    // Arco/bastone
    canvas.drawRect(Rect.fromLTWH(d * 0.72, d * 0.15, d * 0.04, d * 0.52), Paint()..color = const Color(0xFF795548));

    // Occhi luminosi
    canvas.drawRect(Rect.fromLTWH(d * 0.36, d * 0.15, d * 0.05, d * 0.04), Paint()..color = const Color(0xFF76FF03));
    canvas.drawRect(Rect.fromLTWH(d * 0.57, d * 0.15, d * 0.05, d * 0.04), Paint()..color = const Color(0xFF76FF03));
  }

  static void _disegnaNemicoVolante(Canvas canvas, double d, Color colore) {
    // Ali
    final aliPaint = Paint()..color = colore.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(d * 0.02, d * 0.15, d * 0.28, d * 0.32), aliPaint);
    canvas.drawRect(Rect.fromLTWH(d * 0.70, d * 0.15, d * 0.28, d * 0.32), aliPaint);

    // Corpo
    canvas.drawRect(Rect.fromLTWH(d * 0.30, d * 0.22, d * 0.40, d * 0.38), Paint()..color = colore);

    // Occhi gialli
    canvas.drawRect(Rect.fromLTWH(d * 0.36, d * 0.28, d * 0.07, d * 0.05), Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawRect(Rect.fromLTWH(d * 0.57, d * 0.28, d * 0.07, d * 0.05), Paint()..color = const Color(0xFFFFEB3B));

    // Coda
    canvas.drawRect(Rect.fromLTWH(d * 0.42, d * 0.60, d * 0.16, d * 0.25), Paint()..color = colore.withValues(alpha: 0.6));
  }

  static void _disegnaNemicoTank(Canvas canvas, double d, Color colore) {
    // Corpo massiccio
    canvas.drawRect(Rect.fromLTWH(d * 0.12, d * 0.20, d * 0.76, d * 0.60), Paint()..color = colore);

    // Armatura
    canvas.drawRect(Rect.fromLTWH(d * 0.18, d * 0.25, d * 0.64, d * 0.50), Paint()..color = const Color(0xFF616161));

    // Rivetti armatura
    final rivetPaint = Paint()..color = const Color(0xFFBDBDBD);
    canvas.drawCircle(Offset(d * 0.25, d * 0.32), d * 0.02, rivetPaint);
    canvas.drawCircle(Offset(d * 0.75, d * 0.32), d * 0.02, rivetPaint);
    canvas.drawCircle(Offset(d * 0.25, d * 0.60), d * 0.02, rivetPaint);
    canvas.drawCircle(Offset(d * 0.75, d * 0.60), d * 0.02, rivetPaint);

    // Testa piccola
    canvas.drawRect(Rect.fromLTWH(d * 0.35, d * 0.08, d * 0.30, d * 0.16), Paint()..color = colore.withValues(alpha: 0.8));

    // Occhi arancioni
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.12, d * 0.06, d * 0.05), Paint()..color = const Color(0xFFFF9800));
    canvas.drawRect(Rect.fromLTWH(d * 0.56, d * 0.12, d * 0.06, d * 0.05), Paint()..color = const Color(0xFFFF9800));
  }

  static void _disegnaNemicoStealth(Canvas canvas, double d, Color colore) {
    // Corpo semi-trasparente
    final corpoPaint = Paint()..color = colore.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(d * 0.30, d * 0.20, d * 0.38, d * 0.50), corpoPaint);

    // Cappuccio
    canvas.drawRect(Rect.fromLTWH(d * 0.28, d * 0.08, d * 0.42, d * 0.18), Paint()..color = colore.withValues(alpha: 0.8));

    // Pugnali
    canvas.drawRect(Rect.fromLTWH(d * 0.15, d * 0.35, d * 0.04, d * 0.20), Paint()..color = const Color(0xFFBDBDBD));
    canvas.drawRect(Rect.fromLTWH(d * 0.80, d * 0.35, d * 0.04, d * 0.20), Paint()..color = const Color(0xFFBDBDBD));

    // Occhi luminosi nel buio del cappuccio
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.14, d * 0.04, d * 0.03), Paint()..color = const Color(0xFFE040FB));
    canvas.drawRect(Rect.fromLTWH(d * 0.56, d * 0.14, d * 0.04, d * 0.03), Paint()..color = const Color(0xFFE040FB));
  }

  static void _disegnaNemicoMago(Canvas canvas, double d, Color colore) {
    // Tunica
    canvas.drawRect(Rect.fromLTWH(d * 0.28, d * 0.22, d * 0.44, d * 0.55), Paint()..color = colore);

    // Cappello/corona
    canvas.drawRect(Rect.fromLTWH(d * 0.30, d * 0.02, d * 0.40, d * 0.22), Paint()..color = colore.withValues(alpha: 0.8));

    // Bastone magico
    canvas.drawRect(Rect.fromLTWH(d * 0.76, d * 0.10, d * 0.04, d * 0.65), Paint()..color = const Color(0xFF795548));
    // Gemma in cima al bastone
    canvas.drawCircle(Offset(d * 0.78, d * 0.10), d * 0.04, Paint()..color = const Color(0xFF7B2FF7));
    // Glow gemma
    canvas.drawCircle(
      Offset(d * 0.78, d * 0.10),
      d * 0.06,
      Paint()
        ..color = const Color(0x447B2FF7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Occhi
    canvas.drawRect(Rect.fromLTWH(d * 0.36, d * 0.16, d * 0.05, d * 0.04), Paint()..color = const Color(0xFF82B1FF));
    canvas.drawRect(Rect.fromLTWH(d * 0.57, d * 0.16, d * 0.05, d * 0.04), Paint()..color = const Color(0xFF82B1FF));
  }

  static void _disegnaNemicoKamikaze(Canvas canvas, double d, Color colore) {
    // Corpo rotondo instabile
    canvas.drawCircle(Offset(d / 2, d / 2), d * 0.30, Paint()..color = colore);

    // "Miccia" che brucia
    canvas.drawRect(Rect.fromLTWH(d * 0.47, d * 0.08, d * 0.06, d * 0.15), Paint()..color = const Color(0xFF795548));
    // Fiamma
    canvas.drawCircle(Offset(d * 0.50, d * 0.08), d * 0.04, Paint()..color = const Color(0xFFFF9800));
    canvas.drawCircle(
      Offset(d * 0.50, d * 0.08),
      d * 0.06,
      Paint()
        ..color = const Color(0x66FF9800)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Crepe sul corpo
    final crepePaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(d * 0.35, d * 0.40), Offset(d * 0.50, d * 0.55), crepePaint);
    canvas.drawLine(Offset(d * 0.55, d * 0.38), Offset(d * 0.65, d * 0.52), crepePaint);

    // Occhi piccoli e folli
    canvas.drawRect(Rect.fromLTWH(d * 0.38, d * 0.42, d * 0.05, d * 0.05), Paint()..color = const Color(0xFFFFFF00));
    canvas.drawRect(Rect.fromLTWH(d * 0.57, d * 0.42, d * 0.05, d * 0.05), Paint()..color = const Color(0xFFFFFF00));
  }

  static void _disegnaNemicoGenerico(Canvas canvas, double d, Color colore) {
    canvas.drawRect(Rect.fromLTWH(d * 0.25, d * 0.20, d * 0.50, d * 0.60), Paint()..color = colore);
    canvas.drawRect(Rect.fromLTWH(d * 0.32, d * 0.28, d * 0.08, d * 0.06), Paint()..color = const Color(0xFFFF0000));
    canvas.drawRect(Rect.fromLTWH(d * 0.60, d * 0.28, d * 0.08, d * 0.06), Paint()..color = const Color(0xFFFF0000));
  }

  /// Colore base per tipo di nemico
  static Color _getColoreNemico(String tipo) {
    switch (tipo) {
      case 'melee': return const Color(0xFF8B0000);
      case 'ranged': return const Color(0xFF1B5E20);
      case 'flyer': return const Color(0xFF4A148C);
      case 'tank': return const Color(0xFF455A64);
      case 'stealth': return const Color(0xFF263238);
      case 'summoner': return const Color(0xFF311B92);
      case 'healer': return const Color(0xFF1B5E20);
      case 'kamikaze': return const Color(0xFFFF6F00);
      case 'berserker': return const Color(0xFFB71C1C);
      default: return const Color(0xFF616161);
    }
  }
}
