/// Generatore procedurale di dungeon per Dark Leveling Infinity
/// Crea labirinti infiniti con stanze, corridoi, nemici e boss
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/sprite_generator_v2.dart';
import '../../../data/enemies/enemy_definitions.dart';
import '../../../data/enemies/boss_definitions.dart';
import '../enemies/enemy_component.dart';
import '../effects/visual_effects.dart';

/// Tipo di tile nel dungeon
enum TileType {
  vuoto,
  pavimento,
  muro,
  porta,
  scale,
  trappola,
  tesoro,
  gatePortale,
}

/// Dati di una singola tile
class TileData {
  final int x;
  final int y;
  final TileType tipo;
  bool esplorata;

  TileData({
    required this.x,
    required this.y,
    required this.tipo,
    this.esplorata = false,
  });
}

/// Dati di una stanza del dungeon
class RoomData {
  final int x;
  final int y;
  final int larghezza;
  final int altezza;
  final bool isBossRoom;
  final bool isStartRoom;
  final bool isTreasureRoom;
  List<Vector2> posizioniNemici;
  List<Vector2> posizioniLoot;

  RoomData({
    required this.x,
    required this.y,
    required this.larghezza,
    required this.altezza,
    this.isBossRoom = false,
    this.isStartRoom = false,
    this.isTreasureRoom = false,
    List<Vector2>? posizioniNemici,
    List<Vector2>? posizioniLoot,
  }) : posizioniNemici = posizioniNemici ?? [],
       posizioniLoot = posizioniLoot ?? [];

  /// Centro della stanza in coordinate tile
  Vector2 get centro => Vector2(
    (x + larghezza / 2).toDouble(),
    (y + altezza / 2).toDouble(),
  );

  /// Centro della stanza in coordinate mondo
  Vector2 get centroMondo => Vector2(
    (x + larghezza / 2) * WorldConstants.tileSize,
    (y + altezza / 2) * WorldConstants.tileSize,
  );
}

/// Risultato della generazione del dungeon
class DungeonResult {
  final List<SpriteComponent> tiles;
  final List<EnemyComponent> nemici;
  final List<Component> decorazioni; // torce, trappole, decorazioni
  final Vector2 posizionePartenza;
  final Vector2 posizioneBoss;
  final List<RoomData> stanze;
  final GateRank rango;
  final int piano;
  final List<List<int>> grigliaCollisioni; // 0=passabile, 1=muro

  DungeonResult({
    required this.tiles,
    required this.nemici,
    this.decorazioni = const [],
    required this.posizionePartenza,
    required this.posizioneBoss,
    required this.stanze,
    required this.rango,
    this.piano = 1,
    this.grigliaCollisioni = const [],
  });
}

/// Generatore procedurale di dungeon
class DungeonGenerator {
  final Random _rng = Random();

  // Griglia del dungeon
  late List<List<TileType>> _griglia;
  late int _larghezza;
  late int _altezza;

  // Cache degli sprite generati
  final Map<TileType, Sprite> _spriteCache = {};

  /// Genera un dungeon completo per il rango specificato
  Future<DungeonResult> generaDungeon(GateRank rango, {int piano = 1}) async {
    dev.log('[DUNGEON] Generazione dungeon ${rango.nome} piano $piano...');

    // Dimensioni del dungeon basate sul rango
    final numStanze = rango.numStanze + _rng.nextInt(5);
    _larghezza = 80 + numStanze * 3;
    _altezza = 80 + numStanze * 3;

    // Inizializza la griglia con muri
    _griglia = List.generate(
      _altezza,
      (_) => List.generate(_larghezza, (_) => TileType.muro),
    );

    // Genera le stanze
    final stanze = _generaStanze(numStanze);

    // Collega le stanze con corridoi
    _collegaStanze(stanze);

    // Genera gli sprite delle tile
    await _preparaSpriteCache();
    final tileComponents = _creaTileComponents();

    // Genera i nemici
    final nemici = await _generaNemici(stanze, rango);

    // Genera decorazioni (torce e trappole)
    final decorazioni = _generaDecorazioni(stanze);

    // Genera griglia collisioni (0=passabile, 1=muro)
    final grigliaCollisioni = _generaGrigliaCollisioni();

    // Posizione di partenza (centro della prima stanza)
    final posizionePartenza = stanze.first.centroMondo;

    // Posizione del boss (centro dell'ultima stanza)
    final posizioneBoss = stanze.last.centroMondo;

    dev.log('[DUNGEON] Dungeon generato! ${stanze.length} stanze, ${nemici.length} nemici, ${decorazioni.length} decorazioni');

    return DungeonResult(
      tiles: tileComponents,
      nemici: nemici,
      decorazioni: decorazioni,
      posizionePartenza: posizionePartenza,
      posizioneBoss: posizioneBoss,
      stanze: stanze,
      rango: rango,
      piano: piano,
      grigliaCollisioni: grigliaCollisioni,
    );
  }

  /// Genera le stanze del dungeon usando BSP (Binary Space Partitioning)
  List<RoomData> _generaStanze(int numStanze) {
    dev.log('[DUNGEON] Generazione $numStanze stanze...');
    final stanze = <RoomData>[];

    // Prima stanza (start room) - sempre al centro-sinistra
    final startRoom = RoomData(
      x: 5,
      y: _altezza ~/ 2 - 4,
      larghezza: 8,
      altezza: 8,
      isStartRoom: true,
    );
    _scavaStanza(startRoom);
    stanze.add(startRoom);

    // Genera stanze con tentativi casuali
    int tentativi = 0;
    while (stanze.length < numStanze && tentativi < numStanze * 10) {
      tentativi++;

      final larghezza = 5 + _rng.nextInt(6); // 5-10
      final altezza = 5 + _rng.nextInt(6);
      final x = 2 + _rng.nextInt(_larghezza - larghezza - 4);
      final y = 2 + _rng.nextInt(_altezza - altezza - 4);

      final nuovaStanza = RoomData(x: x, y: y, larghezza: larghezza, altezza: altezza);

      // Controlla sovrapposizioni
      bool sovrapposizione = false;
      for (final stanza in stanze) {
        if (_stanzeOverlap(nuovaStanza, stanza, margine: 2)) {
          sovrapposizione = true;
          break;
        }
      }

      if (!sovrapposizione) {
        _scavaStanza(nuovaStanza);
        stanze.add(nuovaStanza);
      }
    }

    // Marca l'ultima stanza come boss room
    if (stanze.length > 1) {
      // Trova la stanza più lontana dalla start
      RoomData stanzaPiuLontana = stanze[1];
      double maxDistanza = 0;
      for (int i = 1; i < stanze.length; i++) {
        final dist = stanze[i].centro.distanceTo(stanze[0].centro);
        if (dist > maxDistanza) {
          maxDistanza = dist;
          stanzaPiuLontana = stanze[i];
        }
      }

      // Rimuovi e ricrea come boss room
      final idx = stanze.indexOf(stanzaPiuLontana);
      stanze[idx] = RoomData(
        x: stanzaPiuLontana.x,
        y: stanzaPiuLontana.y,
        larghezza: stanzaPiuLontana.larghezza,
        altezza: stanzaPiuLontana.altezza,
        isBossRoom: true,
      );
    }

    // Aggiungi alcune stanze del tesoro
    for (int i = 1; i < stanze.length - 1; i++) {
      if (_rng.nextDouble() < 0.15) {
        stanze[i] = RoomData(
          x: stanze[i].x,
          y: stanze[i].y,
          larghezza: stanze[i].larghezza,
          altezza: stanze[i].altezza,
          isTreasureRoom: true,
        );
      }
    }

    dev.log('[DUNGEON] ${stanze.length} stanze generate');
    return stanze;
  }

  /// Scava una stanza nella griglia
  void _scavaStanza(RoomData stanza) {
    for (int y = stanza.y; y < stanza.y + stanza.altezza; y++) {
      for (int x = stanza.x; x < stanza.x + stanza.larghezza; x++) {
        if (y >= 0 && y < _altezza && x >= 0 && x < _larghezza) {
          _griglia[y][x] = TileType.pavimento;
        }
      }
    }
  }

  /// Collega le stanze con corridoi
  void _collegaStanze(List<RoomData> stanze) {
    dev.log('[DUNGEON] Collegamento stanze con corridoi...');
    for (int i = 0; i < stanze.length - 1; i++) {
      final a = stanze[i].centro;
      final b = stanze[i + 1].centro;

      // Corridoio a L
      if (_rng.nextBool()) {
        _scavaCorrioioOrizzontale(a.x.toInt(), b.x.toInt(), a.y.toInt());
        _scavaCorrioioVerticale(a.y.toInt(), b.y.toInt(), b.x.toInt());
      } else {
        _scavaCorrioioVerticale(a.y.toInt(), b.y.toInt(), a.x.toInt());
        _scavaCorrioioOrizzontale(a.x.toInt(), b.x.toInt(), b.y.toInt());
      }
    }

    // Aggiungi porte tra stanze e corridoi
    _aggiungiPorte(stanze);
  }

  /// Scava un corridoio orizzontale
  void _scavaCorrioioOrizzontale(int x1, int x2, int y) {
    final start = min(x1, x2);
    final end = max(x1, x2);
    for (int x = start; x <= end; x++) {
      if (y >= 0 && y < _altezza && x >= 0 && x < _larghezza) {
        _griglia[y][x] = TileType.pavimento;
        // Corridoio largo 2
        if (y + 1 < _altezza) _griglia[y + 1][x] = TileType.pavimento;
      }
    }
  }

  /// Scava un corridoio verticale
  void _scavaCorrioioVerticale(int y1, int y2, int x) {
    final start = min(y1, y2);
    final end = max(y1, y2);
    for (int y = start; y <= end; y++) {
      if (y >= 0 && y < _altezza && x >= 0 && x < _larghezza) {
        _griglia[y][x] = TileType.pavimento;
        if (x + 1 < _larghezza) _griglia[y][x + 1] = TileType.pavimento;
      }
    }
  }

  /// Aggiungi porte nelle transizioni stanza-corridoio
  void _aggiungiPorte(List<RoomData> stanze) {
    for (final stanza in stanze) {
      // Controlla i bordi della stanza per trovare transizioni
      for (int x = stanza.x; x < stanza.x + stanza.larghezza; x++) {
        _controllaPorta(x, stanza.y - 1, stanza);
        _controllaPorta(x, stanza.y + stanza.altezza, stanza);
      }
      for (int y = stanza.y; y < stanza.y + stanza.altezza; y++) {
        _controllaPorta(stanza.x - 1, y, stanza);
        _controllaPorta(stanza.x + stanza.larghezza, y, stanza);
      }
    }
  }

  void _controllaPorta(int x, int y, RoomData stanza) {
    if (y >= 0 && y < _altezza && x >= 0 && x < _larghezza) {
      if (_griglia[y][x] == TileType.pavimento) {
        // C'è un corridoio adiacente - potrebbe essere una porta
        if (_rng.nextDouble() < 0.3) {
          _griglia[y][x] = TileType.porta;
        }
      }
    }
  }

  /// Controlla se due stanze si sovrappongono
  bool _stanzeOverlap(RoomData a, RoomData b, {int margine = 1}) {
    return a.x - margine < b.x + b.larghezza &&
        a.x + a.larghezza + margine > b.x &&
        a.y - margine < b.y + b.altezza &&
        a.y + a.altezza + margine > b.y;
  }

  /// Prepara la cache degli sprite per le tile (V2 con pixel art avanzata)
  Future<void> _preparaSpriteCache() async {
    if (_spriteCache.isNotEmpty) return;

    // Usa SpriteGeneratorV2 per tile con dettagli, crepe, variazioni
    _spriteCache[TileType.pavimento] = await SpriteGeneratorV2.generaTilePavimento();
    _spriteCache[TileType.muro] = await SpriteGeneratorV2.generaTileMuro();
    _spriteCache[TileType.porta] = await SpriteGeneratorV2.generaTilePorta();
    _spriteCache[TileType.scale] = await SpriteGeneratorV2.generaTilePavimento(seed: 42);
    _spriteCache[TileType.vuoto] = await SpriteGeneratorV2.generaTileVuoto();
  }

  /// Crea i componenti sprite per tutte le tile
  List<SpriteComponent> _creaTileComponents() {
    final componenti = <SpriteComponent>[];

    for (int y = 0; y < _altezza; y++) {
      for (int x = 0; x < _larghezza; x++) {
        final tipo = _griglia[y][x];

        // Salta le tile vuote per performance
        if (tipo == TileType.vuoto) continue;

        final sprite = _spriteCache[tipo] ?? _spriteCache[TileType.pavimento]!;
        componenti.add(
          SpriteComponent(
            sprite: sprite,
            position: Vector2(
              x * WorldConstants.tileSize,
              y * WorldConstants.tileSize,
            ),
            size: Vector2(WorldConstants.tileSize, WorldConstants.tileSize),
          ),
        );
      }
    }

    return componenti;
  }

  /// Genera i nemici per il dungeon
  Future<List<EnemyComponent>> _generaNemici(
    List<RoomData> stanze,
    GateRank rango,
  ) async {
    dev.log('[DUNGEON] Generazione nemici per ${rango.nome}...');
    final nemici = <EnemyComponent>[];

    // Ottieni la lista di nemici disponibili per questo rango
    final nemiciDisponibili = EnemyDatabase.getNemiciPerGate(rango);
    if (nemiciDisponibili.isEmpty) {
      dev.log('[DUNGEON] ATTENZIONE: Nessun nemico definito per ${rango.nome}');
      return nemici;
    }

    for (int i = 0; i < stanze.length; i++) {
      final stanza = stanze[i];

      // Salta la stanza iniziale
      if (stanza.isStartRoom) continue;

      if (stanza.isBossRoom) {
        // Genera il boss
        final bossData = BossDatabase.getBossCasualePerGate(rango);
        if (bossData != null) {
          // Usa SpriteGeneratorV2 per boss con pixel art dettagliata
          final bossSprite = await SpriteGeneratorV2.generaNemico(
            tipo: 'boss',
            dimensione: 32,
            scala: bossData.dimensione,
          );

          nemici.add(
            EnemyComponent(
              enemyData: bossData,
              sprite: bossSprite,
              position: stanza.centroMondo,
              isBoss: true,
            ),
          );
        }
      } else {
        // Genera nemici normali nella stanza
        final numNemici = 2 + _rng.nextInt(4); // 2-5 nemici per stanza

        for (int j = 0; j < numNemici; j++) {
          final nemicoData = nemiciDisponibili[_rng.nextInt(nemiciDisponibili.length)];

          // Posizione casuale nella stanza
          final posX = stanza.x + 1 + _rng.nextInt(stanza.larghezza - 2);
          final posY = stanza.y + 1 + _rng.nextInt(stanza.altezza - 2);

          // Usa SpriteGeneratorV2 per nemici con pixel art dettagliata
          final nemicoSprite = await SpriteGeneratorV2.generaNemico(
            tipo: nemicoData.aiType.name,
            dimensione: 32,
            scala: nemicoData.dimensione,
          );

          nemici.add(
            EnemyComponent(
              enemyData: nemicoData,
              sprite: nemicoSprite,
              position: Vector2(
                posX * WorldConstants.tileSize,
                posY * WorldConstants.tileSize,
              ),
            ),
          );
        }
      }
    }

    dev.log('[DUNGEON] ${nemici.length} nemici generati');
    return nemici;
  }

  /// Genera decorazioni: torce ai muri e trappole a terra
  List<Component> _generaDecorazioni(List<RoomData> stanze) {
    dev.log('[DUNGEON] Generazione decorazioni...');
    final decorazioni = <Component>[];

    for (final stanza in stanze) {
      if (stanza.isStartRoom) continue;

      // Torce agli angoli delle stanze (vicino ai muri)
      final torchPositions = [
        Vector2((stanza.x + 1) * WorldConstants.tileSize, (stanza.y + 1) * WorldConstants.tileSize),
        Vector2((stanza.x + stanza.larghezza - 2) * WorldConstants.tileSize, (stanza.y + 1) * WorldConstants.tileSize),
        Vector2((stanza.x + 1) * WorldConstants.tileSize, (stanza.y + stanza.altezza - 2) * WorldConstants.tileSize),
        Vector2((stanza.x + stanza.larghezza - 2) * WorldConstants.tileSize, (stanza.y + stanza.altezza - 2) * WorldConstants.tileSize),
      ];

      for (final pos in torchPositions) {
        if (_rng.nextDouble() < 0.6) { // 60% chance per torcia
          decorazioni.add(TorchComponent(position: pos));
        }
      }

      // Trappole casuali nelle stanze (non nella start e non nella boss room)
      if (!stanza.isBossRoom && _rng.nextDouble() < 0.3) {
        final trapX = stanza.x + 2 + _rng.nextInt(max(1, stanza.larghezza - 4));
        final trapY = stanza.y + 2 + _rng.nextInt(max(1, stanza.altezza - 4));
        decorazioni.add(TrapComponent(
          position: Vector2(
            trapX * WorldConstants.tileSize,
            trapY * WorldConstants.tileSize,
          ),
          danno: 10 + _rng.nextInt(15).toDouble(),
        ));
      }
    }

    dev.log('[DUNGEON] ${decorazioni.length} decorazioni generate');
    return decorazioni;
  }

  /// Genera la griglia collisioni (0=passabile, 1=muro) per wall collision
  List<List<int>> _generaGrigliaCollisioni() {
    return List.generate(
      _altezza,
      (y) => List.generate(
        _larghezza,
        (x) => _griglia[y][x] == TileType.muro ? 1 : 0,
      ),
    );
  }
}
