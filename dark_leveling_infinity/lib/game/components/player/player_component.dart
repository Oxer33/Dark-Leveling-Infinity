/// Componente Player per il gioco
/// Gestisce movimento, animazioni, stats e interazioni del giocatore
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../data/models/player_data.dart';

/// Direzione in cui guarda il player
enum PlayerDirection { su, giu, sinistra, destra }

/// Stato di animazione del player
enum PlayerAnimState { idle, cammina, attacca, schiva, ferito, morto, castsAbilita }

/// Componente principale del player nel mondo di gioco
class PlayerComponent extends SpriteComponent with CollisionCallbacks {
  // --- Dati del player ---
  final PlayerData playerData;

  // --- Stato corrente ---
  PlayerDirection _direzione = PlayerDirection.giu;
  PlayerAnimState _animState = PlayerAnimState.idle;
  Vector2 _velocitaCorrente = Vector2.zero();

  // --- Salute e mana in tempo reale ---
  double saluteAttuale;
  double manaAttuale;

  // --- Combat ---
  double _cooldownAttacco = 0;
  double _cooldownSchivata = 0;
  bool _staSchivando = false;
  bool _invulnerabile = false;
  double _timerInvulnerabilita = 0;
  int _comboCorrente = 0;
  double _timerCombo = 0;

  // --- Effetti di stato ---
  bool avvelenato = false;
  bool congelato = false;
  bool bruciato = false;
  bool stordito = false;
  double _timerVeleno = 0;
  double _timerGelo = 0;
  double _timerBruciatura = 0;
  double _timerStordimento = 0;

  // --- Rigenerazione ---
  double _timerRigenerazione = 0;
  static const double _intervalloRigenerazione = 5.0; // secondi

  PlayerComponent({
    required this.playerData,
    required Sprite sprite,
    required Vector2 position,
  }) : saluteAttuale = playerData.saluteAttuale,
       manaAttuale = playerData.manaAttuale,
       super(
         sprite: sprite,
         position: position,
         size: Vector2(32, 32),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    dev.log('[PLAYER] Caricamento componente player...');

    // Aggiungi hitbox per le collisioni
    add(
      RectangleHitbox(
        size: Vector2(20, 24),
        position: Vector2(6, 4),
      ),
    );

    dev.log('[PLAYER] Player caricato! HP: $saluteAttuale/${playerData.stats.saluteMax}');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Non aggiornare se morto
    if (_animState == PlayerAnimState.morto) return;

    // Aggiorna cooldown
    _aggiornaCooldown(dt);

    // Aggiorna effetti di stato
    _aggiornaEffettiStato(dt);

    // Aggiorna movimento
    _aggiornaMovimento(dt);

    // Sprite flip orizzontale in base alla direzione
    if (_direzione == PlayerDirection.sinistra) {
      if (!isFlippedHorizontally) flipHorizontally();
    } else if (_direzione == PlayerDirection.destra) {
      if (isFlippedHorizontally) flipHorizontally();
    }

    // Flash invulnerabilità (lampeggio quando colpito)
    if (_invulnerabile) {
      paint.color = paint.color.withValues(
        alpha: ((_timerInvulnerabilita * 20).toInt() % 2 == 0) ? 0.4 : 1.0,
      );
    } else {
      paint.color = paint.color.withValues(alpha: 1.0);
    }

    // Aggiorna combo timer
    _aggiornaCombo(dt);

    // Aggiorna rigenerazione
    _aggiornaRigenerazione(dt);

    // Aggiorna invulnerabilità
    _aggiornaInvulnerabilita(dt);

    // Sincronizza con PlayerData
    playerData.saluteAttuale = saluteAttuale;
    playerData.manaAttuale = manaAttuale;
  }

  /// Muovi il player in una direzione (dal joystick)
  void muovi(Vector2 direzione) {
    if (_animState == PlayerAnimState.morto || stordito) return;

    if (direzione.length > 0) {
      _velocitaCorrente = direzione.normalized();
      _animState = PlayerAnimState.cammina;

      // Aggiorna la direzione in base al vettore
      if (direzione.x.abs() > direzione.y.abs()) {
        _direzione = direzione.x > 0
            ? PlayerDirection.destra
            : PlayerDirection.sinistra;
      } else {
        _direzione = direzione.y > 0
            ? PlayerDirection.giu
            : PlayerDirection.su;
      }
    } else {
      _velocitaCorrente = Vector2.zero();
      _animState = PlayerAnimState.idle;
    }
  }

  /// Schivata nella direzione specificata
  void schiva(Vector2 direzione) {
    if (_cooldownSchivata > 0 || _staSchivando || stordito) return;
    if (_animState == PlayerAnimState.morto) return;

    dev.log('[PLAYER] Schivata!');
    _staSchivando = true;
    _invulnerabile = true;
    _timerInvulnerabilita = PlayerConstants.dodgeInvincibilityDuration;
    _cooldownSchivata = PlayerConstants.dodgeCooldown;
    _animState = PlayerAnimState.schiva;

    // Applica il movimento della schivata
    final dir = direzione.length > 0 ? direzione.normalized() : _getDirezioneVettore();
    final schivataVelocita = dir * PlayerConstants.dodgeDistance;

    // Effetto di schivata con animazione
    add(
      MoveByEffect(
        schivataVelocita,
        EffectController(duration: 0.2, curve: Curves.easeOut),
        onComplete: () {
          _staSchivando = false;
          _animState = PlayerAnimState.idle;
        },
      ),
    );
  }

  /// Ricevi danno
  void riceviDanno(double danno, {String? fonte}) {
    if (_invulnerabile || _animState == PlayerAnimState.morto) return;

    // Calcola evasione
    final rng = Random();
    if (rng.nextDouble() < playerData.stats.evasione) {
      dev.log('[PLAYER] Attacco evaso!');
      return;
    }

    // Applica difesa
    final dannoRidotto = max(1.0, danno - playerData.stats.difesaFisica);
    saluteAttuale -= dannoRidotto;

    dev.log('[PLAYER] Danno ricevuto: $dannoRidotto da $fonte (HP: $saluteAttuale/${playerData.stats.saluteMax})');

    // Flash rosso per feedback visivo
    _animState = PlayerAnimState.ferito;

    // Flash rosso sullo schermo (spawna nel mondo)
    parent?.add(_ScreenDamageFlash());

    // Breve invulnerabilità dopo il danno
    _invulnerabile = true;
    _timerInvulnerabilita = 0.3;

    // Controlla morte
    if (saluteAttuale <= 0) {
      saluteAttuale = 0;
      _muori();
    }
  }

  /// Cura il player
  void cura(double quantita) {
    saluteAttuale = min(saluteAttuale + quantita, playerData.stats.saluteMax);
    dev.log('[PLAYER] Curato di $quantita HP (HP: $saluteAttuale/${playerData.stats.saluteMax})');
  }

  /// Ripristina mana
  void ripristinaMana(double quantita) {
    manaAttuale = min(manaAttuale + quantita, playerData.stats.manaMax);
  }

  /// Consuma mana per un'abilità
  bool consumaMana(double costo) {
    if (manaAttuale >= costo) {
      manaAttuale -= costo;
      return true;
    }
    return false;
  }

  /// Aggiungi esperienza e controlla level up
  bool aggiungiEsperienza(double quantita) {
    return playerData.aggiungiEsperienza(quantita);
  }

  /// Aggiungi oro
  void aggiungiOro(int quantita) {
    playerData.oro += quantita;
  }

  /// Incrementa la combo
  void incrementaCombo() {
    _comboCorrente++;
    _timerCombo = CombatConstants.comboWindowSeconds;

    if (_comboCorrente > playerData.comboMassima) {
      playerData.comboMassima = _comboCorrente;
    }
  }

  /// Resetta la combo
  void resetCombo() {
    _comboCorrente = 0;
    _timerCombo = 0;
  }

  /// Ottieni il moltiplicatore combo corrente
  double get moltiplicatoreCombo =>
      1.0 + (_comboCorrente * CombatConstants.comboMultiplierStep);

  /// Ottieni la combo corrente
  int get comboCorrente => _comboCorrente;

  /// Applica effetto veleno
  void applicaVeleno(double durata) {
    avvelenato = true;
    _timerVeleno = durata;
    dev.log('[PLAYER] Avvelenato per $durata secondi!');
  }

  /// Applica effetto gelo
  void applicaGelo(double durata) {
    congelato = true;
    _timerGelo = durata;
    dev.log('[PLAYER] Congelato per $durata secondi!');
  }

  /// Applica effetto bruciatura
  void applicaBruciatura(double durata) {
    bruciato = true;
    _timerBruciatura = durata;
    dev.log('[PLAYER] In fiamme per $durata secondi!');
  }

  /// Applica effetto stordimento
  void applicaStordimento(double durata) {
    stordito = true;
    _timerStordimento = durata;
    dev.log('[PLAYER] Stordito per $durata secondi!');
  }

  /// Percentuale salute
  double get percentualeSalute => saluteAttuale / playerData.stats.saluteMax;

  /// Percentuale mana
  double get percentualeMana => manaAttuale / playerData.stats.manaMax;

  /// Il player può attaccare?
  bool get puoAttaccare => _cooldownAttacco <= 0 && !stordito && _animState != PlayerAnimState.morto;

  /// Il player può schivare?
  bool get puoSchivare => _cooldownSchivata <= 0 && !_staSchivando && !stordito;

  // --- Metodi privati ---

  /// Aggiorna i cooldown
  void _aggiornaCooldown(double dt) {
    if (_cooldownAttacco > 0) _cooldownAttacco -= dt;
    if (_cooldownSchivata > 0) _cooldownSchivata -= dt;
  }

  /// Aggiorna gli effetti di stato
  void _aggiornaEffettiStato(double dt) {
    // Veleno
    if (avvelenato) {
      _timerVeleno -= dt;
      // Danno da veleno ogni secondo
      if ((_timerVeleno * 10).toInt() % 10 == 0) {
        final dannoVeleno = playerData.stats.saluteMax * 0.02; // 2% HP/sec
        saluteAttuale -= dannoVeleno;
      }
      if (_timerVeleno <= 0) avvelenato = false;
    }

    // Gelo (rallentamento)
    if (congelato) {
      _timerGelo -= dt;
      if (_timerGelo <= 0) congelato = false;
    }

    // Bruciatura
    if (bruciato) {
      _timerBruciatura -= dt;
      if ((_timerBruciatura * 10).toInt() % 5 == 0) {
        final dannoBruciatura = playerData.stats.saluteMax * 0.03;
        saluteAttuale -= dannoBruciatura;
      }
      if (_timerBruciatura <= 0) bruciato = false;
    }

    // Stordimento
    if (stordito) {
      _timerStordimento -= dt;
      if (_timerStordimento <= 0) stordito = false;
    }
  }

  /// Aggiorna il movimento
  void _aggiornaMovimento(double dt) {
    if (_velocitaCorrente.length == 0 || _staSchivando) return;

    double velocita = playerData.stats.velocita;

    // Rallentamento se congelato
    if (congelato) velocita *= CombatConstants.freezeSlowFactor;

    position += _velocitaCorrente * velocita * dt;
  }

  /// Aggiorna il timer della combo
  void _aggiornaCombo(double dt) {
    if (_comboCorrente > 0) {
      _timerCombo -= dt;
      if (_timerCombo <= 0) {
        resetCombo();
      }
    }
  }

  /// Aggiorna la rigenerazione passiva
  void _aggiornaRigenerazione(double dt) {
    _timerRigenerazione += dt;
    if (_timerRigenerazione >= _intervalloRigenerazione) {
      _timerRigenerazione = 0;

      // Rigenera 1% HP e 2% MP ogni 5 secondi
      if (saluteAttuale < playerData.stats.saluteMax) {
        cura(playerData.stats.saluteMax * 0.01);
      }
      if (manaAttuale < playerData.stats.manaMax) {
        ripristinaMana(playerData.stats.manaMax * 0.02);
      }
    }
  }

  /// Aggiorna l'invulnerabilità
  void _aggiornaInvulnerabilita(double dt) {
    if (_invulnerabile) {
      _timerInvulnerabilita -= dt;
      if (_timerInvulnerabilita <= 0) {
        _invulnerabile = false;
        _animState = PlayerAnimState.idle;
      }
    }
  }

  /// Il player muore
  void _muori() {
    dev.log('[PLAYER] Il player è morto!');
    _animState = PlayerAnimState.morto;
    _velocitaCorrente = Vector2.zero();
  }

  /// Ottieni il vettore direzione corrente
  Vector2 _getDirezioneVettore() {
    switch (_direzione) {
      case PlayerDirection.su:
        return Vector2(0, -1);
      case PlayerDirection.giu:
        return Vector2(0, 1);
      case PlayerDirection.sinistra:
        return Vector2(-1, 0);
      case PlayerDirection.destra:
        return Vector2(1, 0);
    }
  }

  /// Imposta il cooldown dell'attacco
  void impostaCooldownAttacco() {
    _cooldownAttacco = PlayerConstants.baseAttackCooldown;
  }

  /// Ottieni la direzione corrente come vettore
  Vector2 get direzioneVettore => _getDirezioneVettore();

  /// Ottieni lo stato di animazione corrente
  PlayerAnimState get animState => _animState;

  /// Ottieni la direzione corrente
  PlayerDirection get direzione => _direzione;
}

/// Flash rosso sullo schermo quando il player riceve danno
class _ScreenDamageFlash extends Component {
  double _vita = 0.2;

  @override
  void update(double dt) {
    super.update(dt);
    _vita -= dt;
    if (_vita <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_vita / 0.2).clamp(0.0, 1.0) * 0.35;
    canvas.drawRect(
      const Rect.fromLTWH(-2000, -2000, 5000, 5000),
      Paint()..color = Color.fromARGB((alpha * 255).toInt(), 255, 0, 0),
    );
  }
}
