/// Componente nemico per il gioco
/// Gestisce AI, movimento, attacchi e stato dei nemici
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../../../data/models/enemy_data.dart';
import '../player/player_component.dart';

/// Stato del nemico
enum EnemyState { idle, inseguimento, attacco, ferito, morto, evocazione, fuga, stordito }

/// Componente base per tutti i nemici
class EnemyComponent extends SpriteComponent with CollisionCallbacks {
  // --- Dati del nemico ---
  final EnemyData enemyData;
  final bool isBoss;

  // --- Stato ---
  EnemyState _stato = EnemyState.idle;
  double saluteAttuale;
  double _cooldownAttacco = 0;
  bool _morto = false;

  // --- AI ---
  double _timerAI = 0;
  static const double _intervalloDecisioneAI = 0.3; // secondi
  PlayerComponent? _target;

  // --- Boss specifico ---
  int _faseCorrenteBoss = 0;
  bool _inTransizioneFase = false;

  // --- Effetti ---
  bool _flashDanno = false;
  double _timerFlash = 0;

  // --- Loot drop ---
  bool lootDropped = false;

  EnemyComponent({
    required this.enemyData,
    required Sprite sprite,
    required Vector2 position,
    this.isBoss = false,
  }) : saluteAttuale = enemyData.saluteBase,
       super(
         sprite: sprite,
         position: position,
         size: Vector2(
           32 * enemyData.dimensione,
           32 * enemyData.dimensione,
         ),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    // Aggiungi hitbox
    add(
      RectangleHitbox(
        size: size * 0.8,
        position: size * 0.1,
      ),
    );

    if (isBoss) {
      dev.log('[NEMICO] Boss caricato: ${enemyData.nome} (HP: $saluteAttuale)');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_morto) return;

    // Aggiorna cooldown
    if (_cooldownAttacco > 0) _cooldownAttacco -= dt;

    // Aggiorna flash danno
    if (_flashDanno) {
      _timerFlash -= dt;
      if (_timerFlash <= 0) {
        _flashDanno = false;
        // Ripristina opacità
        paint.colorFilter = null;
      }
    }

    // Aggiorna AI
    _timerAI += dt;
    if (_timerAI >= _intervalloDecisioneAI) {
      _timerAI = 0;
      _aggiornaAI();
    }

    // Esegui azione basata sullo stato
    switch (_stato) {
      case EnemyState.inseguimento:
        _insegui(dt);
        break;
      case EnemyState.attacco:
        _attacca(dt);
        break;
      case EnemyState.fuga:
        _fuggi(dt);
        break;
      case EnemyState.evocazione:
        _evoca(dt);
        break;
      default:
        break;
    }

    // Controlla fasi boss
    if (isBoss && !_inTransizioneFase) {
      _controllaFasiBoss();
    }
  }

  /// Ricevi danno
  void riceviDanno(double danno, {bool critico = false}) {
    if (_morto || _inTransizioneFase) return;

    // Applica difesa
    final dannoRidotto = max(1.0, danno - enemyData.difesaBase * 0.5);
    saluteAttuale -= dannoRidotto;

    dev.log('[NEMICO] ${enemyData.nome} riceve ${dannoRidotto.toStringAsFixed(1)} danni${critico ? " (CRITICO!)" : ""} (HP: ${saluteAttuale.toStringAsFixed(0)}/${enemyData.saluteBase})');

    // Flash rosso
    _flashDanno = true;
    _timerFlash = 0.15;
    paint.colorFilter = const ColorFilter.mode(Colors.red, BlendMode.modulate);

    // Se stava in idle, ora insegue
    if (_stato == EnemyState.idle) {
      _stato = EnemyState.inseguimento;
    }

    // Controlla morte
    if (saluteAttuale <= 0) {
      saluteAttuale = 0;
      _muori();
    }
  }

  /// Percentuale salute
  double get percentualeSalute => saluteAttuale / enemyData.saluteBase;

  /// Il nemico è morto?
  bool get morto => _morto;

  /// Il nemico è un boss?
  bool get boss => isBoss;

  /// Stato corrente
  EnemyState get stato => _stato;

  /// Fase corrente del boss
  int get faseBoss => _faseCorrenteBoss;

  /// Imposta il target (player)
  void setTarget(PlayerComponent player) {
    _target = player;
  }

  // --- AI Logic ---

  /// Aggiorna la decisione AI del nemico
  void _aggiornaAI() {
    if (_target == null || _morto) return;

    final distanza = position.distanceTo(_target!.position);
    final rangeRilevamento = 200.0; // pixel

    switch (enemyData.aiType) {
      case EnemyAIType.melee:
        _aiMelee(distanza, rangeRilevamento);
        break;
      case EnemyAIType.ranged:
        _aiRanged(distanza, rangeRilevamento);
        break;
      case EnemyAIType.hitAndRun:
        _aiHitAndRun(distanza, rangeRilevamento);
        break;
      case EnemyAIType.teleporter:
        _aiTeleporter(distanza, rangeRilevamento);
        break;
      case EnemyAIType.summoner:
        _aiSummoner(distanza, rangeRilevamento);
        break;
      case EnemyAIType.tank:
        _aiTank(distanza, rangeRilevamento);
        break;
      case EnemyAIType.healer:
        _aiHealer(distanza, rangeRilevamento);
        break;
      case EnemyAIType.kamikaze:
        _aiKamikaze(distanza, rangeRilevamento);
        break;
      case EnemyAIType.stealth:
        _aiStealth(distanza, rangeRilevamento);
        break;
      case EnemyAIType.flyer:
        _aiFlyer(distanza, rangeRilevamento);
        break;
      case EnemyAIType.areaMage:
        _aiAreaMage(distanza, rangeRilevamento);
        break;
      case EnemyAIType.splitter:
        _aiSplitter(distanza, rangeRilevamento);
        break;
      case EnemyAIType.trapper:
        _aiTrapper(distanza, rangeRilevamento);
        break;
      case EnemyAIType.poisoner:
        _aiPoisoner(distanza, rangeRilevamento);
        break;
      case EnemyAIType.freezer:
        _aiFreezer(distanza, rangeRilevamento);
        break;
      case EnemyAIType.burner:
        _aiBurner(distanza, rangeRilevamento);
        break;
      case EnemyAIType.vampiric:
        _aiVampiric(distanza, rangeRilevamento);
        break;
      case EnemyAIType.reflector:
        _aiReflector(distanza, rangeRilevamento);
        break;
      case EnemyAIType.shielder:
        _aiShielder(distanza, rangeRilevamento);
        break;
      case EnemyAIType.berserker:
        _aiBerserker(distanza, rangeRilevamento);
        break;
    }
  }

  // --- Implementazione AI per ogni tipo ---

  void _aiMelee(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
    } else if (distanza > enemyData.rangeAttacco) {
      _stato = EnemyState.inseguimento;
    } else {
      _stato = EnemyState.attacco;
    }
  }

  void _aiRanged(double distanza, double range) {
    if (distanza > range * 1.5) {
      _stato = EnemyState.idle;
    } else if (distanza < enemyData.rangeAttacco * 0.3) {
      _stato = EnemyState.fuga; // Troppo vicino, fuggi
    } else if (distanza <= enemyData.rangeAttacco) {
      _stato = EnemyState.attacco;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiHitAndRun(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
    } else if (_cooldownAttacco <= 0 && distanza <= enemyData.rangeAttacco) {
      _stato = EnemyState.attacco;
    } else if (_cooldownAttacco > 0) {
      _stato = EnemyState.fuga;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiTeleporter(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
    } else if (_cooldownAttacco <= 0) {
      // Teletrasportati vicino al player
      if (distanza > enemyData.rangeAttacco) {
        _teletrasportaVicino();
      }
      _stato = EnemyState.attacco;
    } else {
      _stato = EnemyState.fuga;
    }
  }

  void _aiSummoner(double distanza, double range) {
    if (distanza > range * 1.5) {
      _stato = EnemyState.idle;
    } else if (distanza < enemyData.rangeAttacco * 0.5) {
      _stato = EnemyState.fuga;
    } else if (_cooldownAttacco <= 0) {
      _stato = EnemyState.evocazione;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiTank(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
    } else if (distanza <= enemyData.rangeAttacco) {
      _stato = EnemyState.attacco;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiHealer(double distanza, double range) {
    if (distanza > range * 1.5) {
      _stato = EnemyState.idle;
    } else if (distanza < enemyData.rangeAttacco * 0.3) {
      _stato = EnemyState.fuga;
    } else {
      // Cerca alleati feriti da curare (semplificato)
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiKamikaze(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
    } else if (distanza <= enemyData.rangeAttacco * 0.5) {
      // BOOM!
      _stato = EnemyState.attacco;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiStealth(double distanza, double range) {
    if (distanza > range) {
      _stato = EnemyState.idle;
      // Diventa invisibile
      paint.color = paint.color.withValues(alpha: 0.2);
    } else if (distanza <= enemyData.rangeAttacco && _cooldownAttacco <= 0) {
      paint.color = paint.color.withValues(alpha: 1.0);
      _stato = EnemyState.attacco;
    } else {
      paint.color = paint.color.withValues(alpha: 0.3);
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiFlyer(double distanza, double range) {
    if (distanza > range * 1.2) {
      _stato = EnemyState.idle;
    } else if (distanza <= enemyData.rangeAttacco && _cooldownAttacco <= 0) {
      _stato = EnemyState.attacco;
    } else {
      // Vola in cerchio intorno al player
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiAreaMage(double distanza, double range) {
    if (distanza > range * 1.5) {
      _stato = EnemyState.idle;
    } else if (distanza < enemyData.rangeAttacco * 0.4) {
      _stato = EnemyState.fuga;
    } else if (_cooldownAttacco <= 0) {
      _stato = EnemyState.attacco;
    } else {
      _stato = EnemyState.inseguimento;
    }
  }

  void _aiSplitter(double distanza, double range) {
    _aiMelee(distanza, range);
  }

  void _aiTrapper(double distanza, double range) {
    if (distanza > range * 1.5) {
      _stato = EnemyState.idle;
    } else if (_cooldownAttacco <= 0) {
      _stato = EnemyState.attacco; // Piazza trappola
    } else {
      _stato = EnemyState.idle; // Resta fermo
    }
  }

  void _aiPoisoner(double distanza, double range) {
    _aiMelee(distanza, range);
  }

  void _aiFreezer(double distanza, double range) {
    _aiRanged(distanza, range);
  }

  void _aiBurner(double distanza, double range) {
    _aiMelee(distanza, range);
  }

  void _aiVampiric(double distanza, double range) {
    _aiMelee(distanza, range);
  }

  void _aiReflector(double distanza, double range) {
    _aiTank(distanza, range);
  }

  void _aiShielder(double distanza, double range) {
    _aiHealer(distanza, range);
  }

  void _aiBerserker(double distanza, double range) {
    // Più aggressivo quando ferito
    final soglia = percentualeSalute < 0.5 ? range * 1.5 : range;
    _aiMelee(distanza, soglia);
  }

  // --- Azioni ---

  void _insegui(double dt) {
    if (_target == null) return;

    final direzione = (_target!.position - position).normalized();
    final velocita = enemyData.velocitaBase;

    position += direzione * velocita * dt;
  }

  void _attacca(double dt) {
    if (_target == null || _cooldownAttacco > 0) return;

    // Esegui attacco
    final distanza = position.distanceTo(_target!.position);
    if (distanza <= enemyData.rangeAttacco) {
      // Calcola danno
      double danno = enemyData.dannoBase;

      // Bonus berserker quando ferito
      if (enemyData.aiType == EnemyAIType.berserker && percentualeSalute < 0.5) {
        danno *= 1.5;
      }

      // Boss fasi - moltiplicatore danno
      if (isBoss && enemyData is BossData) {
        final bossData = enemyData as BossData;
        if (_faseCorrenteBoss < bossData.fasi.length) {
          danno *= bossData.fasi[_faseCorrenteBoss].moltiplicatoreDanno;
        }
      }

      _target!.riceviDanno(danno, fonte: enemyData.nome);

      // Applica effetti speciali
      _applicaEffettiSpeciali();

      _cooldownAttacco = enemyData.cooldownAttacco;
    }
  }

  void _fuggi(double dt) {
    if (_target == null) return;

    final direzione = (position - _target!.position).normalized();
    final velocita = enemyData.velocitaBase * 1.2;

    position += direzione * velocita * dt;
  }

  void _evoca(double dt) {
    if (_cooldownAttacco > 0) return;
    // L'evocazione è gestita dal CombatSystem
    _cooldownAttacco = enemyData.cooldownAttacco * 2;
    dev.log('[NEMICO] ${enemyData.nome} sta evocando!');
  }

  void _teletrasportaVicino() {
    if (_target == null) return;

    final rng = Random();
    final offset = Vector2(
      (rng.nextDouble() - 0.5) * enemyData.rangeAttacco,
      (rng.nextDouble() - 0.5) * enemyData.rangeAttacco,
    );

    position = _target!.position + offset;
    dev.log('[NEMICO] ${enemyData.nome} si è teletrasportato!');
  }

  /// Applica effetti speciali basati sul tipo di nemico
  void _applicaEffettiSpeciali() {
    if (_target == null) return;

    switch (enemyData.elemento) {
      case ElementType.poison:
        _target!.applicaVeleno(3.0);
        break;
      case ElementType.ice:
        _target!.applicaGelo(2.0);
        break;
      case ElementType.fire:
        _target!.applicaBruciatura(2.0);
        break;
      case ElementType.lightning:
        if (Random().nextDouble() < 0.2) {
          _target!.applicaStordimento(0.5);
        }
        break;
      default:
        break;
    }

    // Effetti specifici AI
    if (enemyData.aiType == EnemyAIType.vampiric) {
      // Cura sé stesso per il 20% del danno inflitto
      final cura = enemyData.dannoBase * 0.2;
      saluteAttuale = min(saluteAttuale + cura, enemyData.saluteBase);
    }
  }

  /// Controlla le transizioni di fase del boss
  void _controllaFasiBoss() {
    if (!isBoss || enemyData is! BossData) return;

    final bossData = enemyData as BossData;
    if (_faseCorrenteBoss >= bossData.fasi.length - 1) return;

    final prossimaFase = bossData.fasi[_faseCorrenteBoss + 1];
    if (percentualeSalute <= prossimaFase.sogliaSalute) {
      _faseCorrenteBoss++;
      _inTransizioneFase = true;

      dev.log('[BOSS] ${bossData.nome} entra nella fase ${_faseCorrenteBoss + 1}!');
      if (prossimaFase.dialogoFase != null) {
        dev.log('[BOSS] "${prossimaFase.dialogoFase}"');
      }

      // Breve invulnerabilità durante la transizione
      Future.delayed(const Duration(seconds: 2), () {
        _inTransizioneFase = false;
      });
    }
  }

  /// Il nemico muore
  void _muori() {
    if (_morto) return;
    _morto = true;
    _stato = EnemyState.morto;

    dev.log('[NEMICO] ${enemyData.nome} sconfitto!');

    // Effetto di morte (fade out) - rimozione dopo breve delay
    Future.delayed(const Duration(milliseconds: 500), () {
      removeFromParent();
    });
  }
}
