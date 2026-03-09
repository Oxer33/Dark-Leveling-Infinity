/// Sistema di effetti particellari avanzato per Dark Leveling Infinity
/// Gestisce esplosioni, scie, impatti, aure, glow e tutti gli effetti visivi
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

// ============================================================
// SINGOLA PARTICELLA
// ============================================================

/// Una singola particella animata nel mondo di gioco
class Particella extends CircleComponent {
  final Vector2 velocita;
  final double vitaMax;
  double vita;
  final Color coloreInizio;
  final Color coloreFine;
  final double dimensioneInizio;
  final double dimensioneFine;
  final double gravita;
  final double attrito;
  final bool glow;

  Particella({
    required Vector2 posizione,
    required this.velocita,
    required this.coloreInizio,
    this.coloreFine = Colors.transparent,
    this.dimensioneInizio = 4.0,
    this.dimensioneFine = 0.5,
    this.vitaMax = 1.0,
    this.gravita = 0,
    this.attrito = 0.98,
    this.glow = false,
  }) : vita = vitaMax,
       super(
         radius: dimensioneInizio,
         position: posizione,
         anchor: Anchor.center,
         paint: Paint()..color = coloreInizio,
       );

  @override
  void update(double dt) {
    super.update(dt);
    vita -= dt;
    if (vita <= 0) {
      removeFromParent();
      return;
    }

    // Aggiorna posizione
    position += velocita * dt;

    // Applica gravità
    velocita.y += gravita * dt;

    // Applica attrito
    velocita.x *= attrito;
    velocita.y *= attrito;

    // Interpolazione colore e dimensione
    final t = 1.0 - (vita / vitaMax);
    final colore = Color.lerp(coloreInizio, coloreFine, t) ?? coloreInizio;

    paint.color = colore;
    radius = ui.lerpDouble(dimensioneInizio, dimensioneFine, t) ?? dimensioneInizio;

    // Effetto glow
    if (glow && vita > vitaMax * 0.3) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);
    }
  }
}

// ============================================================
// SISTEMA PARTICELLE PRINCIPALE
// ============================================================

/// Sistema centrale per creare e gestire tutti gli effetti particellari
class ParticleSystem {
  static final Random _rng = Random();

  // ─── EFFETTI DI IMPATTO ───

  /// Effetto impatto quando il player colpisce un nemico
  static List<Component> creaEffettoImpatto(
    Vector2 posizione, {
    Color colore = GameColors.damageRed,
    int numParticelle = 12,
    bool critico = false,
  }) {
    final componenti = <Component>[];
    final intensita = critico ? 2.0 : 1.0;

    for (int i = 0; i < numParticelle; i++) {
      final angolo = (_rng.nextDouble() * 2 * pi);
      final velocitaMod = 50 + _rng.nextDouble() * 100 * intensita;
      final vel = Vector2(cos(angolo) * velocitaMod, sin(angolo) * velocitaMod);

      componenti.add(Particella(
        posizione: posizione.clone(),
        velocita: vel,
        coloreInizio: critico ? GameColors.criticalYellow : colore,
        coloreFine: colore.withValues(alpha: 0),
        dimensioneInizio: critico ? 5.0 : 3.0,
        dimensioneFine: 0.5,
        vitaMax: 0.3 + _rng.nextDouble() * 0.3,
        attrito: 0.92,
        glow: critico,
      ));
    }

    // Flash luminoso centrale per critici
    if (critico) {
      componenti.add(Particella(
        posizione: posizione.clone(),
        velocita: Vector2.zero(),
        coloreInizio: Colors.white,
        coloreFine: GameColors.criticalYellow.withValues(alpha: 0),
        dimensioneInizio: 12.0,
        dimensioneFine: 0,
        vitaMax: 0.15,
        glow: true,
      ));
    }

    return componenti;
  }

  // ─── EFFETTI DI MORTE NEMICO ───

  /// Effetto quando un nemico muore (esplosione + dissoluzione)
  static List<Component> creaEffettoMorte(
    Vector2 posizione, {
    Color colore = GameColors.primaryPurple,
    double dimensione = 1.0,
    bool isBoss = false,
  }) {
    final componenti = <Component>[];
    final numParticelle = isBoss ? 40 : 20;

    // Esplosione principale
    for (int i = 0; i < numParticelle; i++) {
      final angolo = (_rng.nextDouble() * 2 * pi);
      final velocitaMod = 30 + _rng.nextDouble() * 80 * dimensione;
      final vel = Vector2(cos(angolo) * velocitaMod, sin(angolo) * velocitaMod);

      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 10 * dimensione,
          (_rng.nextDouble() - 0.5) * 10 * dimensione,
        ),
        velocita: vel,
        coloreInizio: colore,
        coloreFine: Colors.transparent,
        dimensioneInizio: 2.0 + _rng.nextDouble() * 3.0 * dimensione,
        dimensioneFine: 0,
        vitaMax: 0.5 + _rng.nextDouble() * 0.8,
        gravita: 20,
        attrito: 0.95,
        glow: true,
      ));
    }

    // Frammenti di ombra (pezzi scuri che cadono)
    for (int i = 0; i < numParticelle ~/ 2; i++) {
      final angolo = (_rng.nextDouble() * 2 * pi);
      final vel = Vector2(cos(angolo) * 40, sin(angolo) * 40 - 30);

      componenti.add(Particella(
        posizione: posizione.clone(),
        velocita: vel,
        coloreInizio: const Color(0xFF1A1A2E),
        coloreFine: Colors.transparent,
        dimensioneInizio: 3.0 * dimensione,
        dimensioneFine: 1.0,
        vitaMax: 0.6 + _rng.nextDouble() * 0.6,
        gravita: 80,
        attrito: 0.96,
      ));
    }

    // Boss: anello d'onda d'urto
    if (isBoss) {
      componenti.add(_AnelloOndaDurto(
        posizione: posizione.clone(),
        colore: colore,
        raggioMax: 80 * dimensione,
        durata: 0.6,
      ));
    }

    return componenti;
  }

  // ─── EFFETTI ELEMENTALI ───

  /// Effetto fuoco (fiamme che salgono)
  static List<Component> creaEffettoFuoco(
    Vector2 posizione, {
    int numParticelle = 8,
    double intensita = 1.0,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 16 * intensita,
          _rng.nextDouble() * 4,
        ),
        velocita: Vector2(
          (_rng.nextDouble() - 0.5) * 20,
          -30 - _rng.nextDouble() * 40,
        ),
        coloreInizio: GameColors.elementFire,
        coloreFine: const Color(0x00FF5722),
        dimensioneInizio: 3.0 * intensita,
        dimensioneFine: 0.5,
        vitaMax: 0.3 + _rng.nextDouble() * 0.4,
        glow: true,
      ));
    }

    return componenti;
  }

  /// Effetto ghiaccio (cristalli che si espandono)
  static List<Component> creaEffettoGhiaccio(
    Vector2 posizione, {
    int numParticelle = 10,
    double intensita = 1.0,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      final angolo = (i / numParticelle) * 2 * pi;
      final vel = Vector2(cos(angolo) * 40, sin(angolo) * 40);

      componenti.add(Particella(
        posizione: posizione.clone(),
        velocita: vel,
        coloreInizio: GameColors.elementIce,
        coloreFine: const Color(0x0000BCD4),
        dimensioneInizio: 2.5 * intensita,
        dimensioneFine: 4.0 * intensita,
        vitaMax: 0.5 + _rng.nextDouble() * 0.3,
        attrito: 0.90,
        glow: true,
      ));
    }

    return componenti;
  }

  /// Effetto fulmine (linee elettriche)
  static List<Component> creaEffettoFulmine(
    Vector2 posizione, {
    int numParticelle = 15,
    double intensita = 1.0,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      final angolo = _rng.nextDouble() * 2 * pi;
      final vel = Vector2(
        cos(angolo) * (60 + _rng.nextDouble() * 60),
        sin(angolo) * (60 + _rng.nextDouble() * 60),
      );

      componenti.add(Particella(
        posizione: posizione.clone(),
        velocita: vel,
        coloreInizio: GameColors.elementLightning,
        coloreFine: Colors.white.withValues(alpha: 0),
        dimensioneInizio: 1.5 * intensita,
        dimensioneFine: 0.3,
        vitaMax: 0.1 + _rng.nextDouble() * 0.15,
        attrito: 0.85,
        glow: true,
      ));
    }

    // Flash centrale
    componenti.add(Particella(
      posizione: posizione.clone(),
      velocita: Vector2.zero(),
      coloreInizio: Colors.white,
      coloreFine: GameColors.elementLightning.withValues(alpha: 0),
      dimensioneInizio: 8.0 * intensita,
      dimensioneFine: 0,
      vitaMax: 0.08,
      glow: true,
    ));

    return componenti;
  }

  /// Effetto veleno (bolle tossiche)
  static List<Component> creaEffettoVeleno(
    Vector2 posizione, {
    int numParticelle = 6,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 20,
          _rng.nextDouble() * 5,
        ),
        velocita: Vector2(
          (_rng.nextDouble() - 0.5) * 15,
          -15 - _rng.nextDouble() * 20,
        ),
        coloreInizio: GameColors.elementPoison,
        coloreFine: const Color(0x004CAF50),
        dimensioneInizio: 2.0 + _rng.nextDouble() * 2.0,
        dimensioneFine: 3.0,
        vitaMax: 0.5 + _rng.nextDouble() * 0.5,
        attrito: 0.97,
        glow: true,
      ));
    }

    return componenti;
  }

  /// Effetto ombra/shadow (per estrazione e evocazione)
  static List<Component> creaEffettoOmbra(
    Vector2 posizione, {
    int numParticelle = 20,
    double raggio = 30,
    bool estrazione = false,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      final angolo = (i / numParticelle) * 2 * pi;
      final dist = raggio * (0.5 + _rng.nextDouble() * 0.5);

      Vector2 vel;
      if (estrazione) {
        // Particelle convergono verso il centro
        vel = Vector2(-cos(angolo) * 30, -sin(angolo) * 30);
      } else {
        // Particelle divergono dal centro (evocazione)
        vel = Vector2(cos(angolo) * 50, sin(angolo) * 50);
      }

      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(cos(angolo) * dist, sin(angolo) * dist),
        velocita: vel,
        coloreInizio: GameColors.elementShadow,
        coloreFine: const Color(0x00311B92),
        dimensioneInizio: 3.0,
        dimensioneFine: estrazione ? 5.0 : 0.5,
        vitaMax: 0.6 + _rng.nextDouble() * 0.5,
        attrito: 0.95,
        glow: true,
      ));
    }

    return componenti;
  }

  // ─── EFFETTI DI CURA ───

  /// Effetto cura (particelle verdi che salgono)
  static List<Component> creaEffettoCura(
    Vector2 posizione, {
    int numParticelle = 10,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 20,
          _rng.nextDouble() * 10,
        ),
        velocita: Vector2(
          (_rng.nextDouble() - 0.5) * 10,
          -20 - _rng.nextDouble() * 30,
        ),
        coloreInizio: GameColors.healGreen,
        coloreFine: const Color(0x0000FF00),
        dimensioneInizio: 2.5,
        dimensioneFine: 0.5,
        vitaMax: 0.6 + _rng.nextDouble() * 0.4,
        attrito: 0.98,
        glow: true,
      ));
    }

    return componenti;
  }

  // ─── EFFETTI DI LEVEL UP ───

  /// Effetto level up (colonna di luce e particelle dorate)
  static List<Component> creaEffettoLevelUp(
    Vector2 posizione, {
    int numParticelle = 30,
  }) {
    final componenti = <Component>[];

    // Colonna di particelle che salgono
    for (int i = 0; i < numParticelle; i++) {
      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 24,
          _rng.nextDouble() * 20,
        ),
        velocita: Vector2(
          (_rng.nextDouble() - 0.5) * 15,
          -40 - _rng.nextDouble() * 60,
        ),
        coloreInizio: GameColors.accentGold,
        coloreFine: const Color(0x00FFD700),
        dimensioneInizio: 3.0,
        dimensioneFine: 0.5,
        vitaMax: 0.8 + _rng.nextDouble() * 0.6,
        attrito: 0.99,
        glow: true,
      ));
    }

    // Anello espansivo
    componenti.add(_AnelloOndaDurto(
      posizione: posizione.clone(),
      colore: GameColors.accentGold,
      raggioMax: 60,
      durata: 0.5,
    ));

    return componenti;
  }

  // ─── EFFETTI SCHIVATA ───

  /// Effetto scia schivata (afterimage)
  static List<Component> creaEffettoSchivata(
    Vector2 posizione,
    Vector2 direzione, {
    int numParticelle = 6,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      final offset = direzione * (-i * 5.0);
      componenti.add(Particella(
        posizione: posizione.clone() + offset,
        velocita: Vector2.zero(),
        coloreInizio: GameColors.accentCyan.withValues(alpha: 0.5),
        coloreFine: Colors.transparent,
        dimensioneInizio: 8.0,
        dimensioneFine: 2.0,
        vitaMax: 0.15 + i * 0.05,
      ));
    }

    return componenti;
  }

  // ─── EFFETTI AMBIENTALI ───

  /// Particelle ambientali del dungeon (polvere, scintille)
  static List<Component> creaEffettoAmbiente(
    Vector2 posizione, {
    String tipo = 'polvere',
    int numParticelle = 3,
  }) {
    final componenti = <Component>[];

    for (int i = 0; i < numParticelle; i++) {
      Color colore;
      double dim;
      double durata;
      Vector2 vel;

      switch (tipo) {
        case 'polvere':
          colore = const Color(0x33FFFFFF);
          dim = 1.0 + _rng.nextDouble();
          durata = 2.0 + _rng.nextDouble() * 3.0;
          vel = Vector2((_rng.nextDouble() - 0.5) * 5, -2 - _rng.nextDouble() * 3);
          break;
        case 'scintille':
          colore = GameColors.accentGold.withValues(alpha: 0.6);
          dim = 1.5;
          durata = 0.5 + _rng.nextDouble() * 0.5;
          vel = Vector2((_rng.nextDouble() - 0.5) * 20, -10 - _rng.nextDouble() * 20);
          break;
        case 'nebbia_oscura':
          colore = GameColors.elementShadow.withValues(alpha: 0.2);
          dim = 4.0 + _rng.nextDouble() * 4.0;
          durata = 3.0 + _rng.nextDouble() * 4.0;
          vel = Vector2((_rng.nextDouble() - 0.5) * 3, (_rng.nextDouble() - 0.5) * 3);
          break;
        default:
          colore = const Color(0x22FFFFFF);
          dim = 1.0;
          durata = 2.0;
          vel = Vector2.zero();
      }

      componenti.add(Particella(
        posizione: posizione.clone() + Vector2(
          (_rng.nextDouble() - 0.5) * 60,
          (_rng.nextDouble() - 0.5) * 60,
        ),
        velocita: vel,
        coloreInizio: colore,
        coloreFine: Colors.transparent,
        dimensioneInizio: dim,
        dimensioneFine: dim * 0.5,
        vitaMax: durata,
        attrito: 0.999,
      ));
    }

    return componenti;
  }

  // ─── SCIA DEL PLAYER ───

  /// Crea una scia di particelle dietro al player durante il movimento
  static Particella? creaParticellaScia(
    Vector2 posizione,
    Vector2 direzione, {
    Color colore = GameColors.neonPurple,
    bool attivo = true,
  }) {
    if (!attivo || _rng.nextDouble() > 0.3) return null;

    return Particella(
      posizione: posizione.clone() + Vector2(
        (_rng.nextDouble() - 0.5) * 6,
        (_rng.nextDouble() - 0.5) * 6,
      ),
      velocita: -direzione * 10 + Vector2(
        (_rng.nextDouble() - 0.5) * 5,
        (_rng.nextDouble() - 0.5) * 5,
      ),
      coloreInizio: colore.withValues(alpha: 0.4),
      coloreFine: Colors.transparent,
      dimensioneInizio: 1.5,
      dimensioneFine: 0.3,
      vitaMax: 0.3 + _rng.nextDouble() * 0.2,
    );
  }

  // ─── EFFETTO AURA ───

  /// Particelle di aura intorno a un componente
  static Particella? creaParticellaAura(
    Vector2 posizione, {
    Color colore = GameColors.primaryPurple,
    double raggio = 16,
  }) {
    if (_rng.nextDouble() > 0.15) return null;

    final angolo = _rng.nextDouble() * 2 * pi;
    final dist = raggio * (0.8 + _rng.nextDouble() * 0.4);

    return Particella(
      posizione: posizione.clone() + Vector2(cos(angolo) * dist, sin(angolo) * dist),
      velocita: Vector2(
        (_rng.nextDouble() - 0.5) * 5,
        -5 - _rng.nextDouble() * 10,
      ),
      coloreInizio: colore.withValues(alpha: 0.5),
      coloreFine: Colors.transparent,
      dimensioneInizio: 1.5 + _rng.nextDouble(),
      dimensioneFine: 0.3,
      vitaMax: 0.4 + _rng.nextDouble() * 0.3,
      glow: true,
    );
  }
}

// ============================================================
// ANELLO ONDA D'URTO (shockwave ring)
// ============================================================

/// Anello espansivo per onde d'urto, boss kill, level up
class _AnelloOndaDurto extends CircleComponent {
  final double raggioMax;
  final double durata;
  double _tempo = 0;
  final Color _colore;

  _AnelloOndaDurto({
    required Vector2 posizione,
    required Color colore,
    this.raggioMax = 60,
    this.durata = 0.5,
  }) : _colore = colore,
       super(
         radius: 1,
         position: posizione,
         anchor: Anchor.center,
         paint: Paint()
           ..color = colore
           ..style = PaintingStyle.stroke
           ..strokeWidth = 3,
       );

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;

    if (_tempo >= durata) {
      removeFromParent();
      return;
    }

    final t = _tempo / durata;
    radius = raggioMax * t;
    paint.color = _colore.withValues(alpha: 1.0 - t);
    paint.strokeWidth = 3.0 * (1.0 - t);
  }
}

// ============================================================
// COMPONENTE NUMERO DANNO FLUTTUANTE
// ============================================================

/// Numero di danno che appare e fluttua verso l'alto
class DamageNumber extends TextComponent {
  double _vita = 1.0;
  final bool critico;
  final bool cura;

  DamageNumber({
    required String testo,
    required Vector2 posizione,
    this.critico = false,
    this.cura = false,
  }) : super(
         text: testo,
         position: posizione,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             fontFamily: 'GameFont',
             fontSize: critico ? 16 : 12,
             fontWeight: critico ? FontWeight.w700 : FontWeight.w500,
             color: cura
                 ? GameColors.healGreen
                 : critico
                     ? GameColors.criticalYellow
                     : GameColors.damageRed,
             shadows: [
               Shadow(
                 color: Colors.black,
                 blurRadius: 2,
                 offset: const Offset(1, 1),
               ),
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

    // Muovi verso l'alto
    position.y -= 30 * dt;

    // Leggero spostamento orizzontale casuale
    position.x += (Random().nextDouble() - 0.5) * 10 * dt;

    // Fade out
    final alpha = (_vita).clamp(0.0, 1.0);
    textRenderer = TextPaint(
      style: TextStyle(
        fontFamily: 'GameFont',
        fontSize: critico ? 16 : 12,
        fontWeight: critico ? FontWeight.w700 : FontWeight.w500,
        color: (cura
            ? GameColors.healGreen
            : critico
                ? GameColors.criticalYellow
                : GameColors.damageRed)
            .withValues(alpha: alpha),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: alpha),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );

    // Scale up per critici
    if (critico && _vita > 0.8) {
      scale = Vector2.all(1.0 + (1.0 - _vita) * 2);
    }
  }
}

// ============================================================
// SCREEN SHAKE COMPONENT
// ============================================================

/// Componente per lo screen shake della camera
class ScreenShake {
  static final Random _rng = Random();

  /// Applica screen shake alla camera
  static void applica(
    CameraComponent camera, {
    double intensita = 5.0,
    double durata = 0.3,
  }) {
    dev.log('[FX] Screen shake: intensità=$intensita durata=$durata');

    final viewfinder = camera.viewfinder;
    final posOriginale = viewfinder.position.clone();
    double tempo = 0;

    // Usiamo un timer interno per lo shake
    camera.add(
      TimerComponent(
        period: 0.016, // ~60fps
        repeat: true,
        onTick: () {
          tempo += 0.016;
          if (tempo >= durata) {
            viewfinder.position = posOriginale;
            return;
          }

          final decadimento = 1.0 - (tempo / durata);
          final offsetX = (_rng.nextDouble() - 0.5) * intensita * 2 * decadimento;
          final offsetY = (_rng.nextDouble() - 0.5) * intensita * 2 * decadimento;
          viewfinder.position = posOriginale + Vector2(offsetX, offsetY);
        },
      ),
    );
  }
}

// ============================================================
// EFFETTO BARRA HP NEMICO (sopra la testa)
// ============================================================

/// Barra HP che appare sopra i nemici quando colpiti
class EnemyHealthBar extends PositionComponent {
  double percentuale;
  final double larghezza;
  final double altezza;
  final bool isBoss;
  double _timerVisibile = 0;
  static const double _durataVisibilita = 3.0;

  EnemyHealthBar({
    required this.percentuale,
    this.larghezza = 24,
    this.altezza = 3,
    this.isBoss = false,
    required Vector2 posizione,
  }) : super(
         position: posizione,
         size: Vector2(larghezza, altezza),
         anchor: Anchor.center,
       );

  /// Aggiorna la percentuale e resetta il timer
  void aggiorna(double nuovaPercentuale) {
    percentuale = nuovaPercentuale.clamp(0.0, 1.0);
    _timerVisibile = _durataVisibilita;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timerVisibile > 0) {
      _timerVisibile -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_timerVisibile <= 0 && !isBoss) return;

    // Sfondo nero
    canvas.drawRect(
      Rect.fromLTWH(0, 0, larghezza, altezza),
      Paint()..color = const Color(0xCC000000),
    );

    // Barra HP
    final colore = percentuale > 0.5
        ? GameColors.healGreen
        : percentuale > 0.25
            ? GameColors.staminaYellow
            : GameColors.healthRed;

    canvas.drawRect(
      Rect.fromLTWH(0.5, 0.5, (larghezza - 1) * percentuale, altezza - 1),
      Paint()..color = colore,
    );

    // Bordo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, larghezza, altezza),
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }
}
