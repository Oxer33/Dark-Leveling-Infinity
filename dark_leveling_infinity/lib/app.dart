/// App principale di Dark Leveling Infinity
/// Gestisce la navigazione tra le schermate e gli overlay del gioco
library;

import 'dart:developer' as dev;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/colors.dart';
import 'core/services/save_service.dart';
import 'game/dark_leveling_game.dart';
import 'ui/screens/main_menu_screen.dart';
import 'ui/widgets/hud_overlay.dart';
import 'ui/overlays/pause_overlay.dart';
import 'ui/overlays/game_over_overlay.dart';
import 'ui/overlays/level_up_overlay.dart';

/// Widget principale dell'applicazione
class DarkLevelingApp extends StatelessWidget {
  const DarkLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Leveling Infinity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.backgroundDark,
        fontFamily: 'GameFont',
        colorScheme: const ColorScheme.dark(
          primary: GameColors.primaryPurple,
          secondary: GameColors.shadowBlue,
          surface: GameColors.backgroundMedium,
        ),
      ),
      home: const GameContainer(),
    );
  }
}

/// Container principale che gestisce gioco e UI
class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late DarkLevelingGame _game;
  GameState _statoCorrente = GameState.menu;

  @override
  void initState() {
    super.initState();
    dev.log('[APP] Inizializzazione GameContainer...');

    // Forza orientamento landscape per una migliore esperienza di gioco
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Nascondi la barra di stato per fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Inizializza il gioco
    _game = DarkLevelingGame();

    // Ascolta i cambiamenti di stato
    _game.onStatoChanged = (nuovoStato) {
      dev.log('[APP] Stato gioco cambiato: $nuovoStato');
      if (mounted) {
        setState(() {
          _statoCorrente = nuovoStato;
        });
      }
    };

    // Inizializza il servizio di salvataggio
    _inizializzaServizi();
  }

  Future<void> _inizializzaServizi() async {
    await SaveService.instance.inizializza();
    dev.log('[APP] Servizi inizializzati!');
  }

  @override
  void dispose() {
    // Ripristina orientamento
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDark,
      body: Stack(
        children: [
          // Layer 1: Il gioco Flame (sempre attivo in background)
          GameWidget(game: _game),

          // Layer 2: Overlay UI basati sullo stato
          _buildOverlay(),
        ],
      ),
    );
  }

  /// Costruisci l'overlay appropriato basato sullo stato del gioco
  Widget _buildOverlay() {
    switch (_statoCorrente) {
      case GameState.menu:
        return MainMenuScreen(
          onNuovaPartita: _nuovaPartita,
          onContinua: _continuaPartita,
          onImpostazioni: _apriImpostazioni,
          onMarket: _apriMarket,
        );

      case GameState.giocando:
        return HudOverlay(game: _game);

      case GameState.pausa:
        return PauseOverlay(
          onRiprendi: () => _game.riprendi(),
          onImpostazioni: _apriImpostazioni,
          onMenu: _tornaAlMenu,
          onSalva: _salvaPartita,
        );

      case GameState.gameOver:
        return GameOverOverlay(
          playerData: _game.playerData,
          onRiprova: _riprova,
          onMenu: _tornaAlMenu,
          nemiciSconfitti: _game.combatSystem.nemiciSconfittiRun,
        );

      case GameState.levelUp:
        return LevelUpOverlay(
          playerData: _game.playerData,
          onAssegnaPunto: (stat) {
            _game.levelingSystem.assegnaPuntoStat(stat, _game.playerData);
            setState(() {});
          },
          onChiudi: () => _game.cambiaStato(GameState.giocando),
        );

      case GameState.caricamento:
        return _buildSchermataCaricamento();

      default:
        return const SizedBox.shrink();
    }
  }

  /// Schermata di caricamento
  Widget _buildSchermataCaricamento() {
    return Container(
      color: GameColors.backgroundDark,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: GameColors.primaryPurple,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Caricamento...',
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 16,
                color: GameColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Azioni del menu ---

  void _nuovaPartita() {
    dev.log('[APP] Nuova partita!');
    _game.nuovaPartita();
  }

  void _continuaPartita() {
    dev.log('[APP] Continua partita...');
    final datiSalvati = SaveService.instance.caricaPlayerData();
    if (datiSalvati != null) {
      _game.continuaPartita(datiSalvati);
    } else {
      dev.log('[APP] Nessun salvataggio trovato, nuova partita');
      _game.nuovaPartita();
    }
  }

  void _apriImpostazioni() {
    dev.log('[APP] Apertura impostazioni...');
    // TODO: Implementare schermata impostazioni
  }

  void _apriMarket() {
    dev.log('[APP] Apertura market...');
    // TODO: Implementare schermata market
  }

  void _tornaAlMenu() {
    dev.log('[APP] Ritorno al menu...');
    _salvaPartita();
    _game.cambiaStato(GameState.menu);
  }

  void _riprova() {
    dev.log('[APP] Riprova...');
    _game.nuovaPartita();
  }

  Future<void> _salvaPartita() async {
    dev.log('[APP] Salvataggio partita...');
    final successo = await SaveService.instance.salvaPlayerData(_game.playerData);
    if (successo) {
      dev.log('[APP] Partita salvata con successo!');
    }
  }
}
