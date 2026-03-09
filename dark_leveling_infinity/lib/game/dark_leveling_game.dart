/// Game Engine principale di Dark Leveling Infinity
/// Gestisce il game loop, la camera, e tutti i sistemi di gioco
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../core/constants/game_constants.dart';
import '../core/constants/colors.dart';
import '../core/utils/sprite_generator_v2.dart';
import '../data/models/player_data.dart';
import 'components/player/player_component.dart';
import 'components/world/dungeon_generator.dart';
import 'components/combat/combat_system.dart';
import 'components/shadows/shadow_army.dart';
import 'components/shadows/shadow_component.dart';
import 'components/effects/particle_system.dart';
import 'systems/quest_system.dart';
import 'systems/leveling_system.dart';
import 'systems/tutorial_system.dart';
import 'systems/achievement_system.dart';
import 'systems/balance_system.dart';

/// Stato del gioco
enum GameState {
  menu,
  giocando,
  pausa,
  inventario,
  shadowArmy,
  market,
  gameOver,
  levelUp,
  bossIntro,
  gateSelect,
  caricamento,
}

/// Game Engine principale
class DarkLevelingGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  // --- Stato del gioco ---
  GameState _statoCorrente = GameState.caricamento;
  GameState get statoCorrente => _statoCorrente;

  // --- Dati del player ---
  late PlayerData playerData;
  late PlayerComponent playerComponent;

  // --- Sistemi ---
  late DungeonGenerator dungeonGenerator;
  late CombatSystem combatSystem;
  late QuestSystem questSystem;
  late LevelingSystem levelingSystem;
  late TutorialSystem tutorialSystem;
  late AchievementSystem achievementSystem;
  late BalanceSystem balanceSystem;
  late ShadowArmySystem shadowArmySystem;

  // --- Ombre evocate nel mondo ---
  final List<ShadowComponent> _ombreEvocate = [];

  // --- Wall collision data ---
  List<List<int>> _grigliaCollisioni = [];
  int _dungeonLarghezza = 0;

  // --- Camera e viewport ---
  late CameraComponent cameraComponent;

  // --- Mondo di gioco ---
  late World gameWorld;

  // --- Callback per la UI Flutter ---
  Function(GameState)? onStatoChanged;
  Function(String)? onSystemMessage;
  Function(PlayerData)? onPlayerDataChanged;

  // --- Variabili di debug ---
  int _fps = 0;
  double _fpsTimer = 0;
  int _frameCount = 0;

  /// Inizializzazione del gioco
  @override
  Future<void> onLoad() async {
    dev.log('[GAME] Inizializzazione Dark Leveling Infinity...');

    // Inizializza il mondo di gioco
    gameWorld = World();
    cameraComponent = CameraComponent(world: gameWorld);
    cameraComponent.viewfinder.zoom = 2.5;

    addAll([gameWorld, cameraComponent]);

    // Inizializza i dati del player (nuova partita o caricamento)
    playerData = PlayerData();

    // Inizializza i sistemi
    dungeonGenerator = DungeonGenerator();
    combatSystem = CombatSystem(game: this);
    questSystem = QuestSystem();
    levelingSystem = LevelingSystem();
    tutorialSystem = TutorialSystem();
    achievementSystem = AchievementSystem();
    balanceSystem = BalanceSystem();
    shadowArmySystem = ShadowArmySystem();

    // Genera gli sprite del player
    await _inizializzaPlayer();

    // Cambia stato a menu
    cambiaStato(GameState.menu);

    dev.log('[GAME] Inizializzazione completata!');
  }

  /// Inizializza il componente del player
  Future<void> _inizializzaPlayer() async {
    dev.log('[GAME] Generazione sprite player...');

    // Usa SpriteGeneratorV2 per sprite dettagliati
    final playerSprite = await SpriteGeneratorV2.generaPlayer(dimensione: 32);
    playerComponent = PlayerComponent(
      playerData: playerData,
      sprite: playerSprite,
      position: Vector2.zero(),
    );

    dev.log('[GAME] Player inizializzato!');
  }

  /// Inizia una nuova partita
  Future<void> nuovaPartita() async {
    dev.log('[GAME] Inizio nuova partita...');

    playerData = PlayerData();
    await _inizializzaPlayer();

    // Genera il primo dungeon (Gate E)
    await entraNelGate(GateRank.e);

    cambiaStato(GameState.giocando);
    inviaMessaggioSistema('Benvenuto, Cacciatore. Il tuo viaggio inizia ora.');

    // Tutorial primo avvio
    tutorialSystem.triggerEvento(TutorialTrigger.primoAvvio);

    // Daily login
    achievementSystem.controllaLogin();
  }

  /// Continua una partita salvata
  Future<void> continuaPartita(PlayerData datiSalvati) async {
    dev.log('[GAME] Caricamento partita salvata...');

    playerData = datiSalvati;
    await _inizializzaPlayer();

    cambiaStato(GameState.gateSelect);
    inviaMessaggioSistema('Bentornato, Cacciatore ${playerData.nome}.');
  }

  /// Entra in un Gate/Dungeon
  Future<void> entraNelGate(GateRank rango) async {
    dev.log('[GAME] Ingresso nel ${rango.nome}...');
    cambiaStato(GameState.caricamento);

    // Pulisci il mondo corrente
    gameWorld.removeAll(gameWorld.children);

    // Genera il nuovo dungeon
    final dungeonData = await dungeonGenerator.generaDungeon(rango);

    // Aggiungi le tile del dungeon al mondo
    for (final tile in dungeonData.tiles) {
      gameWorld.add(tile);
    }

    // Aggiungi il player
    playerComponent.position = dungeonData.posizionePartenza;
    gameWorld.add(playerComponent);

    // Centra la camera sul player
    cameraComponent.follow(playerComponent);

    // Aggiungi i nemici
    for (final nemico in dungeonData.nemici) {
      gameWorld.add(nemico);
    }

    // Aggiungi decorazioni (torce animate, trappole)
    for (final deco in dungeonData.decorazioni) {
      gameWorld.add(deco);
    }

    // Salva griglia collisioni per wall collision del player
    _grigliaCollisioni = dungeonData.grigliaCollisioni;
    _dungeonLarghezza = dungeonData.grigliaCollisioni.isNotEmpty
        ? dungeonData.grigliaCollisioni[0].length : 0;

    // Aggiungi il combat system al mondo
    combatSystem.inizializza(dungeonData);

    cambiaStato(GameState.giocando);
    inviaMessaggioSistema('Sei entrato nel ${rango.nome}. Preparati a combattere!');
  }

  /// Game loop principale - aggiornamento frame
  @override
  void update(double dt) {
    super.update(dt);

    if (_statoCorrente != GameState.giocando) return;

    // Aggiorna il contatore FPS
    _aggiornaFPS(dt);

    // Aggiorna il tempo di gioco
    playerData.tempoGiocatoSecondi += dt;

    // Wall collision: impedisci al player di attraversare i muri
    _controllaWallCollision();

    // Aggiorna il combat system
    combatSystem.update(dt);

    // Aggiorna il sistema quest
    questSystem.update(dt, playerData);

    // Aggiorna il bilanciamento
    balanceSystem.aggiornaMetriche(dt);

    // Aggiorna le ombre evocate
    for (final ombra in _ombreEvocate) {
      if (!ombra.attivo) continue;
    }
    _ombreEvocate.removeWhere((o) => !o.attivo);

    // Controlla condizioni di game over
    if (playerComponent.saluteAttuale <= 0) {
      _gameOver();
    }
  }

  /// Gestione tap sullo schermo
  @override
  void onTapDown(TapDownEvent event) {
    if (_statoCorrente != GameState.giocando) return;

    // Il tap viene gestito dal combat system per gli attacchi
    combatSystem.onTap(event.localPosition);
  }

  /// Gestione drag per il movimento
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_statoCorrente != GameState.giocando) return;
    // Il joystick virtuale è gestito dall'overlay Flutter
  }

  /// Cambia lo stato del gioco
  void cambiaStato(GameState nuovoStato) {
    dev.log('[GAME] Cambio stato: $_statoCorrente -> $nuovoStato');
    _statoCorrente = nuovoStato;
    onStatoChanged?.call(nuovoStato);
  }

  /// Invia un messaggio di sistema (stile Solo Leveling)
  void inviaMessaggioSistema(String messaggio) {
    dev.log('[SISTEMA] $messaggio');
    onSystemMessage?.call(messaggio);
  }

  /// Gestisci il level up del player
  void onLevelUp() {
    dev.log('[GAME] LEVEL UP! Livello ${playerData.livello}');
    cambiaStato(GameState.levelUp);
    inviaMessaggioSistema('Livello ${playerData.livello} raggiunto!');

    // Controlla se il rango è cambiato
    final vecchioRango = playerData.rango;
    if (playerData.rango != vecchioRango) {
      inviaMessaggioSistema('PROMOZIONE! Sei ora ${playerData.rango.nome}!');
    }

    // Aggiorna limiti Shadow Army basati sul livello
    shadowArmySystem.aggiornaLimiti(playerData.livello);

    // Achievement progressione
    achievementSystem.aggiornaProgresso('level_10', playerData.livello);
    achievementSystem.aggiornaProgresso('level_25', playerData.livello);
    achievementSystem.aggiornaProgresso('level_50', playerData.livello);
    achievementSystem.aggiornaProgresso('level_100', playerData.livello);

    // Tutorial
    tutorialSystem.triggerEvento(TutorialTrigger.primoLevelUp);

    onPlayerDataChanged?.call(playerData);
  }

  /// Gestisci la morte del player
  void _gameOver() {
    dev.log('[GAME] Game Over!');
    playerData.mortiTotali++;

    // Registra morte nel balance system
    balanceSystem.registraMorte();

    // Richiama tutte le ombre
    shadowArmySystem.richiamaTutte();
    for (final ombra in _ombreEvocate) {
      ombra.disattiva();
    }
    _ombreEvocate.clear();

    cambiaStato(GameState.gameOver);
    inviaMessaggioSistema('Sei stato sconfitto... Ma un Cacciatore non si arrende mai.');
  }

  /// Metti in pausa il gioco
  void pausa() {
    if (_statoCorrente == GameState.giocando) {
      cambiaStato(GameState.pausa);
    }
  }

  /// Riprendi il gioco dalla pausa
  void riprendi() {
    if (_statoCorrente == GameState.pausa) {
      cambiaStato(GameState.giocando);
    }
  }

  /// Muovi il player tramite joystick
  void muoviPlayer(Vector2 direzione) {
    if (_statoCorrente != GameState.giocando) return;
    playerComponent.muovi(direzione);
  }

  /// Attacco base del player
  void attaccaBase() {
    if (_statoCorrente != GameState.giocando) return;
    combatSystem.attaccaBase(playerComponent);
  }

  /// Usa un'abilità
  void usaAbilita(int indice) {
    if (_statoCorrente != GameState.giocando) return;
    combatSystem.usaAbilita(playerComponent, indice);
  }

  /// Schiva
  void schiva(Vector2 direzione) {
    if (_statoCorrente != GameState.giocando) return;
    playerComponent.schiva(direzione);
  }

  /// Evoca le ombre nel mondo di gioco
  Future<void> evocaOmbre() async {
    if (_statoCorrente != GameState.giocando) return;

    dev.log('[GAME] Evocazione ombre...');

    // Evoca tutte le ombre disponibili
    final numEvocate = shadowArmySystem.evocaTutte();

    if (numEvocate == 0) {
      inviaMessaggioSistema('Nessuna ombra disponibile per l\'evocazione.');
      return;
    }

    // Spawna i ShadowComponent visivi nel mondo
    int indice = 0;
    for (final ombraData in shadowArmySystem.ombreEvocate) {
      if (ombraData.evocata) {
        // Calcola posizione in formazione intorno al player
        final angolo = (indice / numEvocate) * 3.14159 * 2;
        final posizione = playerComponent.position + Vector2(
          cos(angolo) * 40, sin(angolo) * 40,
        );

        final shadowComp = await ShadowComponent.crea(
          shadowData: ombraData,
          posizione: posizione,
          angoloFormazione: angolo,
        );
        shadowComp.setOwner(playerComponent);

        gameWorld.add(shadowComp);
        _ombreEvocate.add(shadowComp);
        indice++;
      }
    }

    // Effetto visivo evocazione
    final effetti = ParticleSystem.creaEffettoOmbra(
      playerComponent.position,
      numParticelle: 25,
      raggio: 40,
      estrazione: false,
    );
    for (final e in effetti) {
      gameWorld.add(e);
    }

    inviaMessaggioSistema('Alzatevi, mie ombre! ($numEvocate evocate)');
    achievementSystem.incrementaProgresso('shadow_1');

    // Trigger tutorial
    tutorialSystem.triggerEvento(TutorialTrigger.primaEvocazione);
  }

  /// Aggiorna il contatore FPS
  void _aggiornaFPS(double dt) {
    _frameCount++;
    _fpsTimer += dt;
    if (_fpsTimer >= 1.0) {
      _fps = _frameCount;
      _frameCount = 0;
      _fpsTimer -= 1.0;
    }
  }

  /// Ottieni gli FPS correnti
  int get fps => _fps;

  /// Controlla le collisioni del player con i muri
  void _controllaWallCollision() {
    if (_grigliaCollisioni.isEmpty) return;

    final pos = playerComponent.position;
    final tileX = (pos.x / WorldConstants.tileSize).floor();
    final tileY = (pos.y / WorldConstants.tileSize).floor();
    final gridH = _grigliaCollisioni.length;

    // Controlla le 8 tile circostanti + la tile corrente
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        final cx = tileX + dx;
        final cy = tileY + dy;

        if (cy < 0 || cy >= gridH || cx < 0 || cx >= _dungeonLarghezza) continue;
        if (_grigliaCollisioni[cy][cx] != 1) continue; // non è un muro

        // Calcola il rettangolo del muro
        final wallLeft = cx * WorldConstants.tileSize;
        final wallTop = cy * WorldConstants.tileSize;
        final wallRight = wallLeft + WorldConstants.tileSize;
        final wallBottom = wallTop + WorldConstants.tileSize;

        // Controlla overlap con il player (hitbox semplificata 12x12 al centro)
        final pHalf = 6.0;
        final pLeft = pos.x - pHalf;
        final pRight = pos.x + pHalf;
        final pTop = pos.y - pHalf;
        final pBottom = pos.y + pHalf;

        if (pRight > wallLeft && pLeft < wallRight &&
            pBottom > wallTop && pTop < wallBottom) {
          // Risolvi la collisione spingendo il player fuori
          final overlapLeft = pRight - wallLeft;
          final overlapRight = wallRight - pLeft;
          final overlapTop = pBottom - wallTop;
          final overlapBottom = wallBottom - pTop;

          final minOverlap = [overlapLeft, overlapRight, overlapTop, overlapBottom]
              .reduce((a, b) => a < b ? a : b);

          if (minOverlap == overlapLeft) {
            pos.x -= overlapLeft;
          } else if (minOverlap == overlapRight) {
            pos.x += overlapRight;
          } else if (minOverlap == overlapTop) {
            pos.y -= overlapTop;
          } else {
            pos.y += overlapBottom;
          }
        }
      }
    }
  }

  /// Rendering del background
  @override
  Color backgroundColor() => GameColors.backgroundDark;
}
