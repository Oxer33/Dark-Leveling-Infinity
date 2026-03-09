/// Componente visivo per le ombre evocate nel mondo di gioco
/// Le ombre seguono il player, combattono autonomamente e hanno effetti visivi
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/sprite_generator.dart';
import '../effects/particle_system.dart';
import '../enemies/enemy_component.dart';
import '../player/player_component.dart';
import 'shadow_army.dart';

/// Componente visivo di un'ombra evocata nel mondo di gioco
/// Le ombre combattono autonomamente seguendo il player
class ShadowComponent extends SpriteComponent with CollisionCallbacks {
  // --- Dati dell'ombra ---
  final ShadowData shadowData;

  // --- Riferimenti ---
  PlayerComponent? _owner;
  EnemyComponent? _targetNemico;

  // --- Stato ---
  bool _attivo = true;
  double _cooldownAttacco = 0;
  double _timerCercaTarget = 0;
  static const double _intervalloRicercaTarget = 0.5;

  // --- Movimento ---
  static const double _distanzaSeguimento = 40.0; // distanza dal player
  static const double _distanzaAttacco = 100.0; // raggio di aggressione
  final double _angoloFormazione; // angolo nella formazione intorno al player

  // --- Effetti visivi ---
  double _timerAura = 0;
  double _pulseTimer = 0;
  bool _pulsing = false;

  ShadowComponent({
    required this.shadowData,
    required Sprite sprite,
    required Vector2 position,
    double angoloFormazione = 0,
  }) : _angoloFormazione = angoloFormazione,
       super(
         sprite: sprite,
         position: position,
         size: Vector2(28, 28),
         anchor: Anchor.center,
       ) {
    // Opacità ridotta per effetto ombra
    paint.color = paint.color.withValues(alpha: 0.75);
  }

  @override
  Future<void> onLoad() async {
    // Hitbox per le collisioni
    add(RectangleHitbox(
      size: Vector2(18, 20),
      position: Vector2(5, 4),
    ));

    dev.log('[SHADOW_COMP] Ombra ${shadowData.nome} caricata nel mondo');
  }

  /// Imposta il proprietario (player)
  void setOwner(PlayerComponent owner) {
    _owner = owner;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_attivo || _owner == null) return;

    // Aggiorna cooldown
    if (_cooldownAttacco > 0) _cooldownAttacco -= dt;

    // Cerca target nemico periodicamente
    _timerCercaTarget += dt;
    if (_timerCercaTarget >= _intervalloRicercaTarget) {
      _timerCercaTarget = 0;
      _cercaTarget();
    }

    // Logica comportamentale
    if (_targetNemico != null && !_targetNemico!.morto) {
      _combattiNemico(dt);
    } else {
      _seguiPlayer(dt);
    }

    // Effetti visivi aura
    _aggiornaEffettiVisivi(dt);
  }

  /// Cerca il nemico più vicino nel raggio di attacco
  void _cercaTarget() {
    if (_owner == null) return;

    _targetNemico = null;
    double distanzaMinima = _distanzaAttacco;

    // Cerca tra i componenti del mondo
    final mondo = parent;
    if (mondo == null) return;

    for (final child in mondo.children) {
      if (child is EnemyComponent && !child.morto) {
        final dist = position.distanceTo(child.position);
        if (dist < distanzaMinima) {
          distanzaMinima = dist;
          _targetNemico = child;
        }
      }
    }
  }

  /// Segui il player in formazione
  void _seguiPlayer(double dt) {
    if (_owner == null) return;

    // Posizione target nella formazione
    final targetPos = _owner!.position + Vector2(
      cos(_angoloFormazione) * _distanzaSeguimento,
      sin(_angoloFormazione) * _distanzaSeguimento,
    );

    final distanza = position.distanceTo(targetPos);

    if (distanza > 3.0) {
      final direzione = (targetPos - position).normalized();
      final velocita = shadowData.velocitaEffettiva * 0.8;

      // Movimento smooth verso la posizione target
      position += direzione * min(velocita * dt, distanza);
    }
  }

  /// Combatti un nemico nel raggio
  void _combattiNemico(double dt) {
    if (_targetNemico == null || _targetNemico!.morto) {
      _targetNemico = null;
      return;
    }

    final distanza = position.distanceTo(_targetNemico!.position);

    if (distanza <= 32) {
      // Nel range di attacco - attacca
      if (_cooldownAttacco <= 0) {
        _attaccaNemico();
      }
    } else {
      // Insegui il nemico
      final direzione = (_targetNemico!.position - position).normalized();
      position += direzione * shadowData.velocitaEffettiva * dt;
    }
  }

  /// Esegui un attacco sul nemico target
  void _attaccaNemico() {
    if (_targetNemico == null || _targetNemico!.morto) return;

    final danno = shadowData.dannoEffettivo;
    _targetNemico!.riceviDanno(danno);
    _cooldownAttacco = 0.8; // cooldown fisso per le ombre

    // Conteggio uccisioni
    if (_targetNemico!.morto) {
      shadowData.uccisioni++;
      _targetNemico = null;
    }

    // Pulse visivo durante l'attacco
    _pulsing = true;
    _pulseTimer = 0.15;
  }

  /// Aggiorna gli effetti visivi dell'ombra
  void _aggiornaEffettiVisivi(double dt) {
    // Pulse attack
    if (_pulsing) {
      _pulseTimer -= dt;
      if (_pulseTimer <= 0) {
        _pulsing = false;
        scale = Vector2.all(1.0);
      } else {
        scale = Vector2.all(1.1);
      }
    }

    // Effetto aura ombra
    _timerAura += dt;
    if (_timerAura >= 0.3) {
      _timerAura = 0;
      final particella = ParticleSystem.creaParticellaAura(
        position,
        colore: GameColors.elementShadow,
        raggio: 12,
      );
      if (particella != null) {
        parent?.add(particella);
      }
    }

    // Oscillazione leggera (fluttuazione ombra)
    final oscY = sin(_timerAura * 3) * 0.5;
    position.y += oscY * dt * 10;
  }

  /// Disattiva l'ombra
  void disattiva() {
    _attivo = false;
    dev.log('[SHADOW_COMP] Ombra ${shadowData.nome} disattivata');
    removeFromParent();
  }

  /// L'ombra è attiva?
  bool get attivo => _attivo;

  /// Crea un ShadowComponent con sprite generato
  static Future<ShadowComponent> crea({
    required ShadowData shadowData,
    required Vector2 posizione,
    double angoloFormazione = 0,
  }) async {
    // Genera lo sprite dell'ombra basato sul tipo
    Color coloreOmbra;
    switch (shadowData.grado) {
      case ShadowGrade.normal:
        coloreOmbra = const Color(0xFF311B92);
        break;
      case ShadowGrade.elite:
        coloreOmbra = const Color(0xFF4A148C);
        break;
      case ShadowGrade.knight:
        coloreOmbra = const Color(0xFF6A1B9A);
        break;
      case ShadowGrade.eliteKnight:
        coloreOmbra = const Color(0xFF7B1FA2);
        break;
      case ShadowGrade.marshal:
        coloreOmbra = const Color(0xFF8E24AA);
        break;
      case ShadowGrade.grandMarshal:
        coloreOmbra = const Color(0xFFAB47BC);
        break;
    }

    final sprite = await SpriteGenerator.generaOmbra(
      colore: coloreOmbra,
      dimensione: 32,
    );

    return ShadowComponent(
      shadowData: shadowData,
      sprite: sprite,
      position: posizione,
      angoloFormazione: angoloFormazione,
    );
  }
}
