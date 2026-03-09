/// Sistema di combattimento di Dark Leveling Infinity
/// Gestisce attacchi, abilità, danni, combo e interazioni di combattimento
/// V2: Integrato con ParticleSystem, DamageNumbers, ScreenShake, ElementalSystem
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/constants/colors.dart';
import '../effects/particle_system.dart';
import '../player/player_component.dart';
import '../enemies/enemy_component.dart';
import '../world/dungeon_generator.dart';
import '../../systems/elemental_system.dart';

/// Tipo di abilità del player
enum SkillType {
  // Abilità fisiche
  fendente('Fendente', 10, 0.8, 48, 'Taglio potente in avanti'),
  colpoRotante('Colpo Rotante', 15, 1.2, 64, 'Attacco circolare che colpisce tutti i nemici vicini'),
  caricaOscura('Carica Oscura', 20, 1.5, 96, 'Carica in avanti attraversando i nemici'),
  pioggiaDiLame('Pioggia di Lame', 30, 2.0, 80, 'Lame oscure cadono dal cielo'),

  // Abilità Shadow
  estrazioneOmbra('Estrazione Ombra', 25, 3.0, 48, 'Tenta di estrarre l\'ombra di un nemico sconfitto'),
  scambioOmbre('Scambio Ombre', 15, 5.0, 200, 'Teletrasportati alla posizione di un\'ombra'),
  autoritaDelSovrano('Autorità del Sovrano', 40, 4.0, 120, 'Telecinesi: solleva e lancia i nemici'),
  dominioDellOmbra('Dominio dell\'Ombra', 50, 8.0, 150, 'Potenzia tutte le ombre nel raggio'),

  // Abilità elementali
  lamaOscura('Lama Oscura', 20, 1.0, 80, 'Proiettile di energia oscura'),
  novaDiOmbra('Nova di Ombra', 35, 3.0, 100, 'Esplosione di energia oscura ad area'),
  pugnoFantasma('Pugno Fantasma', 25, 1.5, 60, 'Colpo potenziato dall\'energia oscura'),
  urloDiGuerra('Urlo di Guerra', 15, 5.0, 120, 'Stordisce i nemici vicini');

  final String nome;
  final double costoMana;
  final double cooldown;
  final double range;
  final String descrizione;

  const SkillType(this.nome, this.costoMana, this.cooldown, this.range, this.descrizione);
}

/// Sistema di combattimento principale
class CombatSystem {
  final dynamic game; // Riferimento al gioco (DarkLevelingGame)

  // Lista dei nemici attivi
  List<EnemyComponent> _nemiciAttivi = [];

  // Cooldown abilità
  final Map<SkillType, double> _cooldownAbilita = {};

  // Statistiche combattimento
  int _nemiciSconfittiRun = 0;
  int dannoTotaleInflitto = 0;
  int dannoTotaleRicevuto = 0;

  // Sistema elementale per le reazioni
  final ElementalSystem _elementalSystem = ElementalSystem();

  // Riferimento al mondo per spawnare effetti
  World? _gameWorld;
  CameraComponent? _camera;

  // Auto-targeting: nemico più vicino
  EnemyComponent? _autoTarget;
  double _timerAutoTarget = 0;

  // Parry system
  bool _parryAttivo = false;
  double _parryTimer = 0;
  static const double _parryWindow = 0.3; // finestra di parry in secondi
  static const double _parryCooldown = 1.0;
  double _parryCooldownTimer = 0;

  // Dash chain
  int _dashChainCount = 0;
  double _dashChainTimer = 0;
  static const double _dashChainWindow = 0.8;
  static const int _maxDashChain = 3;

  CombatSystem({required this.game});

  /// Inizializza il combat system per un nuovo dungeon
  void inizializza(DungeonResult dungeonData) {
    dev.log('[COMBAT] Inizializzazione combat system...');
    _nemiciAttivi = List.from(dungeonData.nemici);
    _nemiciSconfittiRun = 0;
    dannoTotaleInflitto = 0;
    dannoTotaleRicevuto = 0;
    _elementalSystem.pulisci();

    // Prendi riferimento al mondo e camera per spawnare effetti
    _gameWorld = game.gameWorld as World;
    _camera = game.cameraComponent as CameraComponent;

    // Resetta cooldown
    _cooldownAbilita.clear();
    for (final skill in SkillType.values) {
      _cooldownAbilita[skill] = 0;
    }

    // Imposta il target di tutti i nemici
    for (final nemico in _nemiciAttivi) {
      nemico.setTarget(game.playerComponent as PlayerComponent);
    }

    dev.log('[COMBAT] ${_nemiciAttivi.length} nemici pronti al combattimento');
  }

  /// Aggiorna il combat system ogni frame
  void update(double dt) {
    // Aggiorna cooldown abilità
    for (final skill in SkillType.values) {
      if ((_cooldownAbilita[skill] ?? 0) > 0) {
        _cooldownAbilita[skill] = _cooldownAbilita[skill]! - dt;
      }
    }

    // Aggiorna parry
    if (_parryAttivo) {
      _parryTimer -= dt;
      if (_parryTimer <= 0) _parryAttivo = false;
    }
    if (_parryCooldownTimer > 0) _parryCooldownTimer -= dt;

    // Aggiorna dash chain timer
    if (_dashChainTimer > 0) {
      _dashChainTimer -= dt;
      if (_dashChainTimer <= 0) _dashChainCount = 0;
    }

    // Auto-targeting: aggiorna il nemico più vicino
    _timerAutoTarget += dt;
    if (_timerAutoTarget >= 0.2) {
      _timerAutoTarget = 0;
      _aggiornaAutoTarget();
    }

    // Spawna particelle scia del player durante il movimento
    _spawnaScia(dt);

    // Spawna particelle aura del player
    _spawnaAuraPlayer(dt);

    // Rimuovi nemici morti dalla lista
    _nemiciAttivi.removeWhere((nemico) {
      if (nemico.morto && !nemico.lootDropped) {
        _onNemicoSconfitto(nemico);
        return true;
      }
      return nemico.morto;
    });
  }

  /// Gestisci tap sullo schermo (attacco nella direzione del tap)
  void onTap(Vector2 posizione) {
    // L'attacco viene gestito dai pulsanti dell'HUD
  }

  /// Attacco base del player
  void attaccaBase(PlayerComponent player) {
    if (!player.puoAttaccare) return;

    dev.log('[COMBAT] Attacco base!');

    // Trova nemici nel range dell'attacco
    final nemiciColpiti = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      PlayerConstants.baseAttackRange,
      angoloCono: 60.0, // gradi
    );

    // Calcola danno
    final dannoBase = player.playerData.stats.dannoFisico;
    final rng = Random();

    for (final nemico in nemiciColpiti) {
      double danno = dannoBase;

      // Controlla critico
      bool critico = false;
      if (rng.nextDouble() < player.playerData.stats.critChance) {
        critico = true;
        danno *= CombatConstants.criticalHitMultiplier;
      }

      // Applica moltiplicatore combo
      danno *= player.moltiplicatoreCombo;

      // Infliggi danno
      nemico.riceviDanno(danno, critico: critico);
      dannoTotaleInflitto += danno.toInt();

      // === EFFETTI VISIVI V2 ===
      // Spawna particelle impatto nella posizione del nemico
      _spawnaEffettoImpatto(nemico.position, critico: critico);

      // Spawna damage number fluttuante
      _spawnaDamageNumber(nemico.position, danno, critico: critico);

      // Screen shake su critico
      if (critico && _camera != null) {
        ScreenShake.applica(_camera!, intensita: 4.0, durata: 0.15);
      }

      // Incrementa combo
      player.incrementaCombo();
    }

    // Screen shake leggero su ogni attacco
    if (nemiciColpiti.isNotEmpty && _camera != null) {
      ScreenShake.applica(_camera!, intensita: 1.5, durata: 0.08);
    }

    // Imposta cooldown attacco
    player.impostaCooldownAttacco();
  }

  /// Usa un'abilità specifica
  void usaAbilita(PlayerComponent player, int indice) {
    if (indice >= SkillType.values.length) return;

    final skill = SkillType.values[indice];

    // Controlla cooldown
    if ((_cooldownAbilita[skill] ?? 0) > 0) {
      dev.log('[COMBAT] Abilità ${skill.nome} in cooldown!');
      return;
    }

    // Controlla mana
    if (!player.consumaMana(skill.costoMana)) {
      dev.log('[COMBAT] Mana insufficiente per ${skill.nome}!');
      return;
    }

    dev.log('[COMBAT] Uso abilità: ${skill.nome}!');

    // Imposta cooldown
    _cooldownAbilita[skill] = skill.cooldown;

    // Esegui l'abilità
    switch (skill) {
      case SkillType.fendente:
        _eseguiFendente(player);
        break;
      case SkillType.colpoRotante:
        _eseguiColpoRotante(player);
        break;
      case SkillType.caricaOscura:
        _eseguiCaricaOscura(player);
        break;
      case SkillType.pioggiaDiLame:
        _eseguiPioggiaDiLame(player);
        break;
      case SkillType.estrazioneOmbra:
        _eseguiEstrazioneOmbra(player);
        break;
      case SkillType.scambioOmbre:
        _eseguiScambioOmbre(player);
        break;
      case SkillType.autoritaDelSovrano:
        _eseguiAutoritaSovrano(player);
        break;
      case SkillType.dominioDellOmbra:
        _eseguiDominioOmbra(player);
        break;
      case SkillType.lamaOscura:
        _eseguiLamaOscura(player);
        break;
      case SkillType.novaDiOmbra:
        _eseguiNovaDiOmbra(player);
        break;
      case SkillType.pugnoFantasma:
        _eseguiPugnoFantasma(player);
        break;
      case SkillType.urloDiGuerra:
        _eseguiUrloDiGuerra(player);
        break;
    }
  }

  /// Evoca le ombre del player
  void evocaOmbre(PlayerComponent player) {
    dev.log('[COMBAT] Evocazione ombre!');
    // L'evocazione è gestita dal Shadow Army system
    game.inviaMessaggioSistema('Alzatevi, mie ombre!');
  }

  /// Ottieni il cooldown rimanente di un'abilità
  double getCooldownAbilita(SkillType skill) {
    return _cooldownAbilita[skill] ?? 0;
  }

  /// Ottieni il numero di nemici attivi
  int get nemiciAttivi => _nemiciAttivi.length;

  /// Ottieni statistiche combattimento
  int get nemiciSconfittiRun => _nemiciSconfittiRun;

  // --- Implementazione abilità ---

  void _eseguiFendente(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.fendente.range,
      angoloCono: 90,
    );

    final danno = player.playerData.stats.dannoFisico * 2.0;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
      player.incrementaCombo();
    }
  }

  void _eseguiColpoRotante(PlayerComponent player) {
    // Colpisce tutti i nemici intorno
    final nemici = _trovaNemiciInRange(
      player.position,
      Vector2(1, 0), // direzione non importa, è circolare
      SkillType.colpoRotante.range,
      angoloCono: 360,
    );

    final danno = player.playerData.stats.dannoFisico * 1.5;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
      player.incrementaCombo();
    }
  }

  void _eseguiCaricaOscura(PlayerComponent player) {
    // Dash in avanti colpendo tutti i nemici sul percorso
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.caricaOscura.range,
      angoloCono: 30,
    );

    final danno = player.playerData.stats.dannoFisico * 2.5;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
      player.incrementaCombo();
    }

    // Muovi il player in avanti
    player.position += player.direzioneVettore * SkillType.caricaOscura.range;
  }

  void _eseguiPioggiaDiLame(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.pioggiaDiLame.range,
      angoloCono: 360,
    );

    final danno = player.playerData.stats.dannoMagico * 3.0;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
    }
  }

  void _eseguiEstrazioneOmbra(PlayerComponent player) {
    // Cerca nemici morti vicini per l'estrazione
    dev.log('[COMBAT] Tentativo di estrazione ombra...');
    game.inviaMessaggioSistema('Estrazione dell\'ombra in corso...');
  }

  void _eseguiScambioOmbre(PlayerComponent player) {
    dev.log('[COMBAT] Scambio ombre!');
  }

  void _eseguiAutoritaSovrano(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.autoritaDelSovrano.range,
      angoloCono: 60,
    );

    final danno = player.playerData.stats.dannoMagico * 2.5;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
      // Knockback
      final dir = (nemico.position - player.position).normalized();
      nemico.position += dir * CombatConstants.knockbackForce;
    }
  }

  void _eseguiDominioOmbra(PlayerComponent player) {
    dev.log('[COMBAT] Dominio dell\'ombra attivato!');
    game.inviaMessaggioSistema('Dominio dell\'Ombra: Tutte le ombre potenziate!');
  }

  void _eseguiLamaOscura(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.lamaOscura.range,
      angoloCono: 15,
    );

    final danno = player.playerData.stats.dannoMagico * 2.0;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
    }
  }

  void _eseguiNovaDiOmbra(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      Vector2(1, 0),
      SkillType.novaDiOmbra.range,
      angoloCono: 360,
    );

    final danno = player.playerData.stats.dannoMagico * 3.5;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
    }
  }

  void _eseguiPugnoFantasma(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      player.direzioneVettore,
      SkillType.pugnoFantasma.range,
      angoloCono: 45,
    );

    final danno = (player.playerData.stats.dannoFisico + player.playerData.stats.dannoMagico) * 1.5;
    for (final nemico in nemici) {
      nemico.riceviDanno(danno);
      player.incrementaCombo();
    }
  }

  void _eseguiUrloDiGuerra(PlayerComponent player) {
    final nemici = _trovaNemiciInRange(
      player.position,
      Vector2(1, 0),
      SkillType.urloDiGuerra.range,
      angoloCono: 360,
    );

    for (final nemico in nemici) {
      nemico.riceviDanno(player.playerData.stats.dannoFisico * 0.5);
    }

    game.inviaMessaggioSistema('Urlo di Guerra! Nemici storditi!');
  }

  // --- Utility ---

  /// Trova nemici nel range di attacco con cono direzionale
  List<EnemyComponent> _trovaNemiciInRange(
    Vector2 posizione,
    Vector2 direzione,
    double range, {
    double angoloCono = 360,
  }) {
    final risultato = <EnemyComponent>[];

    for (final nemico in _nemiciAttivi) {
      if (nemico.morto) continue;

      final distanza = posizione.distanceTo(nemico.position);
      if (distanza > range) continue;

      // Se è un attacco a 360°, include tutti
      if (angoloCono >= 360) {
        risultato.add(nemico);
        continue;
      }

      // Controlla angolo
      final dirVersoNemico = (nemico.position - posizione).normalized();
      final angolo = _angoloTraVettori(direzione, dirVersoNemico);

      if (angolo <= angoloCono / 2) {
        risultato.add(nemico);
      }
    }

    return risultato;
  }

  /// Calcola l'angolo tra due vettori in gradi
  double _angoloTraVettori(Vector2 a, Vector2 b) {
    final dot = a.x * b.x + a.y * b.y;
    final det = a.x * b.y - a.y * b.x;
    return atan2(det, dot).abs() * 180 / pi;
  }

  /// Gestisci la sconfitta di un nemico
  void _onNemicoSconfitto(EnemyComponent nemico) {
    nemico.lootDropped = true;
    _nemiciSconfittiRun++;

    final player = game.playerComponent as PlayerComponent;

    // === EFFETTI VISIVI MORTE V2 ===
    _spawnaEffettoMorte(nemico);

    // Dai esperienza
    final levelUp = player.aggiungiEsperienza(nemico.enemyData.expRicompensa);
    if (levelUp) {
      // Effetto level up visivo
      _spawnaEffettoLevelUp(player.position);
      game.onLevelUp();
    }

    // Dai oro
    player.aggiungiOro(nemico.enemyData.oroRicompensa);

    // Spawna testo EXP e Oro
    _spawnaDamageNumber(
      nemico.position + Vector2(0, -10),
      nemico.enemyData.expRicompensa,
      cura: true, // verde per exp
    );

    // Aggiorna statistiche
    player.playerData.nemiciSconfitti++;
    if (nemico.isBoss) {
      player.playerData.bosssSconfitti++;
      // Boss kill: screen shake potente + onda d'urto
      if (_camera != null) {
        ScreenShake.applica(_camera!, intensita: 10.0, durata: 0.5);
      }
      game.inviaMessaggioSistema('Boss ${nemico.enemyData.nome} sconfitto!');
    }

    // Pulisci elementi dal nemico morto
    _elementalSystem.rimuoviElementi(nemico.enemyData.id);

    dev.log('[COMBAT] ${nemico.enemyData.nome} sconfitto! +${nemico.enemyData.expRicompensa} EXP, +${nemico.enemyData.oroRicompensa} oro');
  }

  // ═══════════════════════════════════════════════
  // EFFETTI VISIVI - Spawning nel mondo di gioco
  // ═══════════════════════════════════════════════

  /// Spawna particelle d'impatto alla posizione del nemico
  void _spawnaEffettoImpatto(Vector2 posizione, {bool critico = false}) {
    if (_gameWorld == null) return;
    final effetti = ParticleSystem.creaEffettoImpatto(
      posizione.clone(),
      critico: critico,
      numParticelle: critico ? 16 : 8,
    );
    for (final e in effetti) {
      _gameWorld!.add(e);
    }
  }

  /// Spawna un numero di danno fluttuante
  void _spawnaDamageNumber(Vector2 posizione, double danno, {bool critico = false, bool cura = false}) {
    if (_gameWorld == null) return;
    final offset = Vector2(
      (Random().nextDouble() - 0.5) * 10,
      -5 - Random().nextDouble() * 5,
    );
    _gameWorld!.add(DamageNumber(
      testo: cura ? '+${danno.toInt()}' : '${danno.toInt()}',
      posizione: posizione.clone() + offset,
      critico: critico,
      cura: cura,
    ));
  }

  /// Spawna effetto morte nemico (esplosione particelle)
  void _spawnaEffettoMorte(EnemyComponent nemico) {
    if (_gameWorld == null) return;
    final effetti = ParticleSystem.creaEffettoMorte(
      nemico.position.clone(),
      colore: GameColors.primaryPurple,
      dimensione: nemico.enemyData.dimensione,
      isBoss: nemico.isBoss,
    );
    for (final e in effetti) {
      _gameWorld!.add(e);
    }
  }

  /// Spawna effetto level up (colonna di luce dorata)
  void _spawnaEffettoLevelUp(Vector2 posizione) {
    if (_gameWorld == null) return;
    final effetti = ParticleSystem.creaEffettoLevelUp(posizione.clone());
    for (final e in effetti) {
      _gameWorld!.add(e);
    }
    // Screen shake celebrativo
    if (_camera != null) {
      ScreenShake.applica(_camera!, intensita: 3.0, durata: 0.3);
    }
  }

  /// Spawna particelle scia del player durante il movimento
  void _spawnaScia(double dt) {
    if (_gameWorld == null) return;
    final player = game.playerComponent as PlayerComponent;
    if (player.animState != PlayerAnimState.cammina) return;

    final particella = ParticleSystem.creaParticellaScia(
      player.position,
      player.direzioneVettore,
      colore: GameColors.neonPurple,
    );
    if (particella != null) {
      _gameWorld!.add(particella);
    }
  }

  /// Spawna particelle aura intorno al player
  void _spawnaAuraPlayer(double dt) {
    if (_gameWorld == null) return;
    final player = game.playerComponent as PlayerComponent;

    final particella = ParticleSystem.creaParticellaAura(
      player.position,
      colore: GameColors.primaryPurple,
      raggio: 14,
    );
    if (particella != null) {
      _gameWorld!.add(particella);
    }
  }

  // ═══════════════════════════════════════════════
  // MECCANICHE AVANZATE V2
  // ═══════════════════════════════════════════════

  /// Auto-targeting: trova il nemico più vicino al player
  void _aggiornaAutoTarget() {
    final player = game.playerComponent as PlayerComponent;
    double minDist = 150.0; // range di auto-target
    _autoTarget = null;

    for (final nemico in _nemiciAttivi) {
      if (nemico.morto) continue;
      final dist = player.position.distanceTo(nemico.position);
      if (dist < minDist) {
        minDist = dist;
        _autoTarget = nemico;
      }
    }
  }

  /// Attiva il parry (contrattacco)
  void attivaParry() {
    if (_parryCooldownTimer > 0 || _parryAttivo) return;
    _parryAttivo = true;
    _parryTimer = _parryWindow;
    _parryCooldownTimer = _parryCooldown;
    dev.log('[COMBAT] Parry attivato!');
  }

  /// Controlla se un attacco nemico viene parato
  bool controllaParry(double dannoNemico, Vector2 posizioneNemico) {
    if (!_parryAttivo) return false;

    _parryAttivo = false;
    dev.log('[COMBAT] PARRY RIUSCITO! Contrattacco!');

    // Contrattacco: infliggi danno doppio al nemico
    final player = game.playerComponent as PlayerComponent;
    final nemiciVicini = _trovaNemiciInRange(
      player.position, player.direzioneVettore, 60, angoloCono: 120,
    );

    for (final nemico in nemiciVicini) {
      final controDanno = player.playerData.stats.dannoFisico * 3.0;
      nemico.riceviDanno(controDanno, critico: true);
      _spawnaEffettoImpatto(nemico.position, critico: true);
      _spawnaDamageNumber(nemico.position, controDanno, critico: true);
    }

    // Effetto visivo parry
    if (_gameWorld != null) {
      final effetti = ParticleSystem.creaEffettoGhiaccio(
        player.position, numParticelle: 12,
      );
      for (final e in effetti) {
        _gameWorld!.add(e);
      }
    }

    if (_camera != null) {
      ScreenShake.applica(_camera!, intensita: 5.0, durata: 0.2);
    }

    game.inviaMessaggioSistema('Parry perfetto! Contrattacco!');
    return true;
  }

  /// Esegui dash chain (schivata concatenata)
  void eseguiDashChain(PlayerComponent player, Vector2 direzione) {
    if (_dashChainCount >= _maxDashChain) return;

    _dashChainCount++;
    _dashChainTimer = _dashChainWindow;

    // Ogni dash successivo è più veloce e fa più danno
    final moltiplicatore = 1.0 + _dashChainCount * 0.5;
    final danno = player.playerData.stats.dannoFisico * moltiplicatore;

    // Dash e colpisci nemici sul percorso
    final nemici = _trovaNemiciInRange(
      player.position, direzione, 80, angoloCono: 45,
    );

    for (final nemico in nemici) {
      nemico.riceviDanno(danno, critico: _dashChainCount >= 3);
      _spawnaEffettoImpatto(nemico.position, critico: _dashChainCount >= 3);
      _spawnaDamageNumber(nemico.position, danno, critico: _dashChainCount >= 3);
    }

    // Effetto scia schivata
    if (_gameWorld != null) {
      final effetti = ParticleSystem.creaEffettoSchivata(
        player.position, direzione,
      );
      for (final e in effetti) {
        _gameWorld!.add(e);
      }
    }

    if (_dashChainCount >= 3) {
      game.inviaMessaggioSistema('Dash Chain x$_dashChainCount!');
    }

    dev.log('[COMBAT] Dash chain x$_dashChainCount');
  }

  /// Ottieni il nemico auto-targetato
  EnemyComponent? get autoTarget => _autoTarget;

  /// Il parry è attivo?
  bool get parryAttivo => _parryAttivo;

  /// Dash chain count corrente
  int get dashChainCount => _dashChainCount;
}
