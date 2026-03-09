/// Effetti visivi aggiuntivi per Dark Leveling Infinity
/// Loot drops, flash danno, slow-motion, vignette, torce, trappole
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/game_constants.dart';

// ============================================================
// LOOT DROP VISIVO - Oggetto che cade e può essere raccolto
// ============================================================

/// Loot drop che appare quando un nemico muore
class LootDropComponent extends SpriteComponent {
  final String itemId;
  final ItemRarity rarita;
  double _timerBob = 0;
  double _timerVita = 30.0; // sparisce dopo 30 secondi
  bool raccolto = false;
  final double _yBase;

  LootDropComponent({
    required this.itemId,
    required this.rarita,
    required Sprite sprite,
    required Vector2 position,
  }) : _yBase = position.y,
       super(
         sprite: sprite,
         position: position,
         size: Vector2(16, 16),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    // Glow della rarità
    final glowColor = Color(rarita.coloreHex);
    paint.colorFilter = ColorFilter.mode(
      glowColor.withValues(alpha: 0.3),
      BlendMode.srcATop,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (raccolto) return;

    _timerVita -= dt;
    if (_timerVita <= 0) {
      removeFromParent();
      return;
    }

    // Effetto bob (su e giù)
    _timerBob += dt * 3;
    position.y = _yBase + sin(_timerBob) * 2;

    // Lampeggio quando sta per sparire
    if (_timerVita < 5) {
      final alpha = (sin(_timerBob * 5) + 1) / 2;
      paint.color = paint.color.withValues(alpha: alpha);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Glow sotto il loot
    final glowPaint = Paint()
      ..color = Color(rarita.coloreHex).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.6,
      glowPaint,
    );
  }
}

// ============================================================
// FLASH DANNO SCHERMO - Overlay rosso quando il player è colpito
// ============================================================

/// Componente che disegna un flash colorato su tutto lo schermo
class ScreenFlash extends Component {
  final Color _colore;
  final double _durata;
  double _tempo = 0;

  ScreenFlash({
    Color colore = const Color(0x44FF0000),
    double durata = 0.2,
  }) : _colore = colore,
       _durata = durata;

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;
    if (_tempo >= _durata) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1.0 - _tempo / _durata).clamp(0.0, 1.0);
    final paint = Paint()..color = _colore.withValues(alpha: alpha * 0.4);
    // Disegna su un'area molto grande per coprire tutto lo schermo
    canvas.drawRect(
      const Rect.fromLTWH(-1000, -1000, 3000, 3000),
      paint,
    );
  }
}

// ============================================================
// INDICATORE DIREZIONE BOSS
// ============================================================

/// Freccia che indica la direzione del boss quando è fuori schermo
class BossDirectionIndicator extends PositionComponent {
  Vector2 bossPosition;
  Vector2 playerPosition;

  BossDirectionIndicator({
    required this.bossPosition,
    required this.playerPosition,
  }) : super(size: Vector2(12, 12));

  @override
  void render(Canvas canvas) {
    final dir = (bossPosition - playerPosition);
    if (dir.length < 150) return; // Non mostrare se il boss è vicino

    final angle = atan2(dir.y, dir.x);
    final dist = 60.0; // distanza dal centro dello schermo

    // Posiziona la freccia sul bordo
    final x = cos(angle) * dist;
    final y = sin(angle) * dist;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    // Disegna freccia rossa
    final paint = Paint()..color = GameColors.healthRed;
    final path = Path()
      ..moveTo(6, 0)
      ..lineTo(-4, -4)
      ..lineTo(-2, 0)
      ..lineTo(-4, 4)
      ..close();
    canvas.drawPath(path, paint);

    // Glow
    final glowPaint = Paint()
      ..color = GameColors.healthRed.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset.zero, 8, glowPaint);

    canvas.restore();
  }
}

// ============================================================
// TORCIA ANIMATA - Decorazione dungeon con luce dinamica
// ============================================================

/// Torcia che emette luce e particelle
class TorchComponent extends PositionComponent {
  double _timer = 0;

  TorchComponent({required Vector2 position})
      : super(position: position, size: Vector2(8, 16), anchor: Anchor.bottomCenter);

  @override
  void render(Canvas canvas) {
    // Base torcia (legno)
    final woodPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(const Rect.fromLTWH(2, 6, 4, 10), woodPaint);

    // Fiamma (cambia con il timer)
    final flickerOffset = sin(_timer * 8) * 1.5;
    final flamePaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawRect(
      Rect.fromLTWH(1 + flickerOffset * 0.3, 0, 6, 7),
      flamePaint,
    );

    // Centro fiamma più chiaro
    final innerFlame = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawRect(
      Rect.fromLTWH(2.5 + flickerOffset * 0.2, 1, 3, 4),
      innerFlame,
    );

    // Glow luce (illuminazione area circostante)
    final lightPaint = Paint()
      ..color = const Color(0x15FFCC00)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        20 + sin(_timer * 3) * 3,
      );
    canvas.drawCircle(const Offset(4, 3), 30, lightPaint);

    // Glow più stretto
    final innerLight = Paint()
      ..color = const Color(0x22FF9800)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        8 + sin(_timer * 5) * 2,
      );
    canvas.drawCircle(const Offset(4, 3), 12, innerLight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
  }
}

// ============================================================
// TRAPPOLA VISIVA - Tile pericolosa nel dungeon
// ============================================================

/// Trappola a terra che causa danno al player
class TrapComponent extends PositionComponent {
  double _timer = 0;
  bool _attivata = false;
  double _cooldownAttivazione = 0;
  final double danno;

  TrapComponent({
    required Vector2 position,
    this.danno = 15,
  }) : super(
         position: position,
         size: Vector2(WorldConstants.tileSize, WorldConstants.tileSize),
         anchor: Anchor.center,
       );

  @override
  void render(Canvas canvas) {
    final d = size.x;

    // Base trappola
    final basePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, d, d), basePaint);

    if (_attivata) {
      // Punte che escono
      final spikePaint = Paint()..color = const Color(0xFFBDBDBD);
      for (int i = 0; i < 4; i++) {
        final x = d * 0.15 + i * d * 0.22;
        canvas.drawRect(Rect.fromLTWH(x, d * 0.2, d * 0.08, d * 0.6), spikePaint);
      }
      // Sangue
      final bloodPaint = Paint()..color = const Color(0x44FF0000);
      canvas.drawRect(Rect.fromLTWH(d * 0.1, d * 0.3, d * 0.8, d * 0.1), bloodPaint);
    } else {
      // Segni sottili a terra (indizio visivo)
      final hintPaint = Paint()
        ..color = const Color(0xFF2A2A44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRect(Rect.fromLTWH(d * 0.2, d * 0.2, d * 0.6, d * 0.6), hintPaint);

      // Piccoli fori
      final holePaint = Paint()..color = const Color(0xFF0A0A14);
      for (int i = 0; i < 4; i++) {
        final x = d * 0.25 + i * d * 0.18;
        canvas.drawCircle(Offset(x, d * 0.5), 1.5, holePaint);
      }
    }

    // Pulsazione di avvertimento quando il player è vicino
    if (_cooldownAttivazione <= 0 && !_attivata) {
      final warnAlpha = (sin(_timer * 4) + 1) / 2 * 0.15;
      final warnPaint = Paint()..color = Color.fromARGB(
        (warnAlpha * 255).toInt(), 255, 0, 0,
      );
      canvas.drawRect(Rect.fromLTWH(0, 0, d, d), warnPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (_attivata) {
      _cooldownAttivazione -= dt;
      if (_cooldownAttivazione <= 0) {
        _attivata = false;
      }
    }
  }

  /// Attiva la trappola
  void attiva() {
    if (_cooldownAttivazione > 0) return;
    _attivata = true;
    _cooldownAttivazione = 3.0; // 3 secondi di cooldown
    dev.log('[TRAP] Trappola attivata!');
  }

  bool get attivata => _attivata;
}

// ============================================================
// VIGNETTE POST-PROCESSING OVERLAY
// ============================================================

/// Overlay scuro ai bordi dello schermo per atmosfera
class VignetteOverlay extends PositionComponent {
  @override
  void render(Canvas canvas) {
    // Gradiente radiale scuro ai bordi
    final rect = Rect.fromLTWH(-500, -500, 2000, 2000);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(500, 400),
        600,
        [
          Colors.transparent,
          Colors.transparent,
          const Color(0x33000000),
          const Color(0x88000000),
        ],
        [0.0, 0.5, 0.8, 1.0],
      );
    canvas.drawRect(rect, paint);
  }
}

// ============================================================
// WAVE INDICATOR - Mostra l'ondata corrente
// ============================================================

/// Componente che mostra il numero dell'ondata corrente
class WaveIndicator extends TextComponent {
  int _ondataCorrente = 0;
  double _timerVisibile = 0;

  WaveIndicator({required Vector2 position})
      : super(
          text: '',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GameColors.accentGold,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
          ),
        );

  /// Mostra una nuova ondata
  void mostraOndata(int numero) {
    _ondataCorrente = numero;
    text = 'ONDATA $_ondataCorrente';
    _timerVisibile = 3.0;
    scale = Vector2.all(1.5);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_timerVisibile > 0) {
      _timerVisibile -= dt;

      // Scale down animation
      if (scale.x > 1.0) {
        scale -= Vector2.all(dt * 2);
        if (scale.x < 1.0) scale = Vector2.all(1.0);
      }

      // Fade out negli ultimi secondi
      if (_timerVisibile < 1.0) {
        final alpha = _timerVisibile;
        textRenderer = TextPaint(
          style: TextStyle(
            fontFamily: 'GameFont',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: GameColors.accentGold.withValues(alpha: alpha),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: alpha),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      }
    } else {
      text = '';
    }
  }
}

// ============================================================
// STANZA CLEARED EFFECT
// ============================================================

/// Effetto che appare quando tutti i nemici di una stanza sono sconfitti
class RoomClearedEffect extends TextComponent {
  double _vita = 2.5;

  RoomClearedEffect({required Vector2 position})
      : super(
          text: 'STANZA CONQUISTATA!',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GameColors.accentGold,
              letterSpacing: 2,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 3, offset: Offset(1, 1)),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _vita -= dt;

    if (_vita <= 0) {
      removeFromParent();
      return;
    }

    // Sale verso l'alto
    position.y -= 15 * dt;

    // Fade out
    if (_vita < 1.0) {
      textRenderer = TextPaint(
        style: TextStyle(
          fontFamily: 'GameFont',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: GameColors.accentGold.withValues(alpha: _vita),
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: _vita),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
    }
  }
}

// ============================================================
// SISTEMA MESSAGGIO BOSS (stile Solo Leveling)
// ============================================================

/// Messaggio che appare quando il boss parla durante le fasi
class BossDialogComponent extends TextComponent {
  double _vita;
  BossDialogComponent({
    required String messaggio,
    required Vector2 position,
    double durata = 3.0,
  }) : _vita = durata,
       super(
         text: '"$messaggio"',
         position: position,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: const TextStyle(
             fontFamily: 'GameFont',
             fontSize: 11,
             fontWeight: FontWeight.w700,
             color: GameColors.healthRed,
             fontStyle: FontStyle.italic,
             shadows: [
               Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
             ],
           ),
         ),
       );

  @override
  void update(double dt) {
    super.update(dt);
    _vita -= dt;

    if (_vita <= 0) {
      removeFromParent();
      return;
    }

    // Leggero bob
    position.y -= 5 * dt;

    // Fade
    if (_vita < 0.5) {
      final alpha = _vita * 2;
      textRenderer = TextPaint(
        style: TextStyle(
          fontFamily: 'GameFont',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: GameColors.healthRed.withValues(alpha: alpha),
          fontStyle: FontStyle.italic,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
    }
  }
}

// ============================================================
// EXP ORB - Sfere di esperienza che volano verso il player
// ============================================================

/// Sfera di esperienza che vola verso il player quando raccolta
class ExpOrb extends CircleComponent {
  final Vector2 targetPosition;
  final double espValore;
  double _velocita = 50;
  bool _raccolto = false;

  ExpOrb({
    required Vector2 posizione,
    required this.targetPosition,
    required this.espValore,
  }) : super(
         radius: 2.5,
         position: posizione,
         anchor: Anchor.center,
         paint: Paint()..color = GameColors.expGreen,
       );

  @override
  void update(double dt) {
    super.update(dt);

    // Accelera verso il player
    _velocita += dt * 200;
    final dir = (targetPosition - position);
    final dist = dir.length;

    if (dist < 5) {
      // Raccolto!
      if (!_raccolto) {
        _raccolto = true;
        removeFromParent();
      }
      return;
    }

    position += dir.normalized() * _velocita * dt;

    // Glow
    paint.color = GameColors.expGreen.withValues(
      alpha: 0.6 + sin(position.x * 0.1) * 0.3,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Scia luminosa
    final trailPaint = Paint()
      ..color = GameColors.expGreen.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset.zero, 5, trailPaint);
  }
}
