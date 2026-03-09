/// Chunk Manager per il mondo infinito di Dark Leveling Infinity
/// Gestisce la generazione e il caricamento/scaricamento dei chunk del mondo
/// Implementa un sistema di chunk-based rendering per performance ottimali
library;

import 'dart:developer' as dev;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/sprite_generator.dart';

/// Coordinate di un chunk nel mondo
class ChunkCoord {
  final int x;
  final int y;

  const ChunkCoord(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is ChunkCoord && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ (y.hashCode << 16);

  @override
  String toString() => 'Chunk($x, $y)';
}

/// Tipo di bioma del chunk (varia l'aspetto visivo)
enum ChunkBiome {
  dungeon,       // Standard dark dungeon
  caverna,       // Caverne di pietra
  cripte,        // Cripte con bare e candelabri
  foresta,       // Foresta oscura
  vulcano,       // Lava e roccia rossa
  ghiaccio,      // Cristalli di ghiaccio
  abisso,        // Vuoto e piattaforme
  tempio,        // Tempio antico
  laboratorio,   // Laboratorio alchemico
  trono,         // Sala del trono (boss)
}

/// Dati di un singolo chunk generato
class ChunkData {
  final ChunkCoord coord;
  final ChunkBiome biome;
  final List<List<int>> tiles; // 0=vuoto, 1=pavimento, 2=muro, 3=porta, 4=decorazione
  final List<Vector2> spawnNemici;
  final List<Vector2> spawnLoot;
  final bool hasBoss;
  final int seed;

  ChunkData({
    required this.coord,
    required this.biome,
    required this.tiles,
    this.spawnNemici = const [],
    this.spawnLoot = const [],
    this.hasBoss = false,
    required this.seed,
  });
}

/// Manager dei chunk per il mondo infinito
/// Carica e scarica chunk basandosi sulla posizione del player
class ChunkManager extends Component {
  // --- Configurazione ---
  final int chunkSize = WorldConstants.chunkSize; // 16x16 tiles
  final int renderDistance = WorldConstants.renderDistance; // 3 chunks

  // --- Cache dei chunk ---
  final Map<ChunkCoord, ChunkData> _chunkCache = {};
  final Map<ChunkCoord, List<Component>> _chunkComponents = {};

  // --- Stato ---
  ChunkCoord _lastPlayerChunk = const ChunkCoord(0, 0);
  int _worldSeed = 0;

  // --- Cache sprite ---
  final Map<int, Sprite> _tileSprites = {};
  bool _spritesReady = false;

  // --- Colori per bioma (usati per la generazione tile varianti) ---
  static const Map<ChunkBiome, List<Color>> biomeColors = {
    ChunkBiome.dungeon: [Color(0xFF2C2C44), Color(0xFF12121A), Color(0xFF363652)],
    ChunkBiome.caverna: [Color(0xFF3E2723), Color(0xFF1B0F0A), Color(0xFF4E342E)],
    ChunkBiome.cripte: [Color(0xFF263238), Color(0xFF0D1B1E), Color(0xFF37474F)],
    ChunkBiome.foresta: [Color(0xFF1B3A1B), Color(0xFF0A1F0A), Color(0xFF2E5A2E)],
    ChunkBiome.vulcano: [Color(0xFF4A1A0A), Color(0xFF1A0A00), Color(0xFF6A2A0A)],
    ChunkBiome.ghiaccio: [Color(0xFF1A3A5A), Color(0xFF0A1A3A), Color(0xFF2A5A7A)],
    ChunkBiome.abisso: [Color(0xFF0A0A1A), Color(0xFF000005), Color(0xFF1A1A3A)],
    ChunkBiome.tempio: [Color(0xFF3A2A1A), Color(0xFF1A1A0A), Color(0xFF5A4A2A)],
    ChunkBiome.laboratorio: [Color(0xFF1A2A2A), Color(0xFF0A1A1A), Color(0xFF2A3A3A)],
    ChunkBiome.trono: [Color(0xFF2A1A3A), Color(0xFF0A0A1A), Color(0xFF4A2A5A)],
  };

  /// Inizializza il chunk manager con un seed per la generazione
  Future<void> inizializza({int? seed}) async {
    _worldSeed = seed ?? Random().nextInt(999999999);
    dev.log('[CHUNK] Inizializzazione ChunkManager con seed: $_worldSeed');

    // Pre-genera gli sprite delle tile
    await _preparaSprites();

    dev.log('[CHUNK] ChunkManager pronto!');
  }

  /// Prepara gli sprite delle tile nella cache
  Future<void> _preparaSprites() async {
    if (_spritesReady) return;

    _tileSprites[0] = await SpriteGenerator.generaTile(tipo: 'vuoto');
    _tileSprites[1] = await SpriteGenerator.generaTile(tipo: 'pavimento');
    _tileSprites[2] = await SpriteGenerator.generaTile(tipo: 'muro');
    _tileSprites[3] = await SpriteGenerator.generaTile(tipo: 'porta');
    _tileSprites[4] = await SpriteGenerator.generaTile(tipo: 'scale');

    _spritesReady = true;
    dev.log('[CHUNK] Sprites delle tile pronti');
  }

  /// Aggiorna i chunk basandosi sulla posizione del player
  void aggiornaChunks(Vector2 posizionePlayer) {
    if (!_spritesReady) return;

    // Calcola il chunk corrente del player
    final playerChunk = _posizioneAChunk(posizionePlayer);

    // Se il player non ha cambiato chunk, non fare nulla
    if (playerChunk == _lastPlayerChunk) return;

    _lastPlayerChunk = playerChunk;
    dev.log('[CHUNK] Player nel chunk $playerChunk');

    // Determina quali chunk devono essere caricati
    final chunksNecessari = <ChunkCoord>{};
    for (int dx = -renderDistance; dx <= renderDistance; dx++) {
      for (int dy = -renderDistance; dy <= renderDistance; dy++) {
        chunksNecessari.add(ChunkCoord(
          playerChunk.x + dx,
          playerChunk.y + dy,
        ));
      }
    }

    // Scarica i chunk fuori dal range
    final chunksDaRimuovere = _chunkComponents.keys
        .where((coord) => !chunksNecessari.contains(coord))
        .toList();

    for (final coord in chunksDaRimuovere) {
      _scaricaChunk(coord);
    }

    // Carica i nuovi chunk necessari
    for (final coord in chunksNecessari) {
      if (!_chunkComponents.containsKey(coord)) {
        _caricaChunk(coord);
      }
    }
  }

  /// Genera e carica un chunk
  void _caricaChunk(ChunkCoord coord) {
    // Genera i dati del chunk se non in cache
    if (!_chunkCache.containsKey(coord)) {
      _chunkCache[coord] = _generaChunk(coord);
    }

    final chunkData = _chunkCache[coord]!;
    final componenti = <Component>[];

    // Crea i componenti sprite per ogni tile del chunk
    final offsetMondo = Vector2(
      coord.x * chunkSize * WorldConstants.tileSize,
      coord.y * chunkSize * WorldConstants.tileSize,
    );

    for (int y = 0; y < chunkSize; y++) {
      for (int x = 0; x < chunkSize; x++) {
        final tileType = chunkData.tiles[y][x];
        if (tileType == 0) continue; // Salta tile vuote

        final sprite = _tileSprites[tileType] ?? _tileSprites[1]!;
        final comp = SpriteComponent(
          sprite: sprite,
          position: offsetMondo + Vector2(
            x * WorldConstants.tileSize,
            y * WorldConstants.tileSize,
          ),
          size: Vector2(WorldConstants.tileSize, WorldConstants.tileSize),
        );

        componenti.add(comp);
        parent?.add(comp);
      }
    }

    _chunkComponents[coord] = componenti;
  }

  /// Scarica un chunk dal mondo
  void _scaricaChunk(ChunkCoord coord) {
    final componenti = _chunkComponents[coord];
    if (componenti != null) {
      for (final comp in componenti) {
        comp.removeFromParent();
      }
      _chunkComponents.remove(coord);
    }
  }

  /// Genera proceduralmente un chunk
  ChunkData _generaChunk(ChunkCoord coord) {
    // Seed unico per questo chunk basato sulla posizione e il world seed
    final chunkSeed = _worldSeed ^ (coord.x * 73856093) ^ (coord.y * 19349669);
    final rng = Random(chunkSeed);

    // Determina il bioma basato sulla posizione
    final biome = _determinaBioma(coord, rng);

    // Genera la griglia delle tile
    final tiles = List.generate(
      chunkSize,
      (_) => List.generate(chunkSize, (_) => 0),
    );

    // Genera il layout del dungeon per questo chunk
    _generaLayoutChunk(tiles, coord, rng, biome);

    // Determina posizioni spawn nemici
    final spawnNemici = <Vector2>[];
    final spawnLoot = <Vector2>[];

    for (int y = 1; y < chunkSize - 1; y++) {
      for (int x = 1; x < chunkSize - 1; x++) {
        if (tiles[y][x] == 1) { // Solo su pavimento
          if (rng.nextDouble() < 0.03) { // 3% chance spawn nemico
            spawnNemici.add(Vector2(
              (coord.x * chunkSize + x) * WorldConstants.tileSize,
              (coord.y * chunkSize + y) * WorldConstants.tileSize,
            ));
          }
          if (rng.nextDouble() < 0.005) { // 0.5% chance loot
            spawnLoot.add(Vector2(
              (coord.x * chunkSize + x) * WorldConstants.tileSize,
              (coord.y * chunkSize + y) * WorldConstants.tileSize,
            ));
          }
        }
      }
    }

    // Boss check: ogni 10 chunk c'è una boss room
    final hasBoss = (coord.x.abs() + coord.y.abs()) % 10 == 0 &&
        coord.x != 0 && coord.y != 0;

    return ChunkData(
      coord: coord,
      biome: biome,
      tiles: tiles,
      spawnNemici: spawnNemici,
      spawnLoot: spawnLoot,
      hasBoss: hasBoss,
      seed: chunkSeed,
    );
  }

  /// Genera il layout delle tile per un chunk usando automata cellulare
  void _generaLayoutChunk(
    List<List<int>> tiles,
    ChunkCoord coord,
    Random rng,
    ChunkBiome biome,
  ) {
    // Fase 1: Riempimento casuale (40% pavimento, 60% muro)
    for (int y = 0; y < chunkSize; y++) {
      for (int x = 0; x < chunkSize; x++) {
        // I bordi del chunk sono sempre muro per continuità
        if (x == 0 || x == chunkSize - 1 || y == 0 || y == chunkSize - 1) {
          tiles[y][x] = 2; // muro
        } else {
          tiles[y][x] = rng.nextDouble() < 0.45 ? 1 : 2;
        }
      }
    }

    // Fase 2: Smooth con cellular automata (3 iterazioni)
    for (int iter = 0; iter < 3; iter++) {
      final nuovaTile = List.generate(
        chunkSize,
        (y) => List.generate(chunkSize, (x) => tiles[y][x]),
      );

      for (int y = 1; y < chunkSize - 1; y++) {
        for (int x = 1; x < chunkSize - 1; x++) {
          int muri = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (tiles[y + dy][x + dx] == 2) muri++;
            }
          }
          // Regola 4-5: se >= 5 vicini sono muri, diventa muro
          nuovaTile[y][x] = muri >= 5 ? 2 : 1;
        }
      }

      for (int y = 0; y < chunkSize; y++) {
        for (int x = 0; x < chunkSize; x++) {
          tiles[y][x] = nuovaTile[y][x];
        }
      }
    }

    // Fase 3: Garantisci connessione ai bordi del chunk per continuità
    // Crea corridoi in punti specifici dei bordi
    final corridoioBordi = [chunkSize ~/ 4, chunkSize ~/ 2, 3 * chunkSize ~/ 4];
    for (final pos in corridoioBordi) {
      if (pos >= 1 && pos < chunkSize - 1) {
        // Corridoio orizzontale ai bordi superiore e inferiore
        tiles[0][pos] = 1;
        tiles[1][pos] = 1;
        tiles[chunkSize - 1][pos] = 1;
        tiles[chunkSize - 2][pos] = 1;

        // Corridoio verticale ai bordi sinistro e destro
        tiles[pos][0] = 1;
        tiles[pos][1] = 1;
        tiles[pos][chunkSize - 1] = 1;
        tiles[pos][chunkSize - 2] = 1;
      }
    }

    // Fase 4: Aggiungi decorazioni
    for (int y = 2; y < chunkSize - 2; y++) {
      for (int x = 2; x < chunkSize - 2; x++) {
        if (tiles[y][x] == 1 && rng.nextDouble() < 0.02) {
          tiles[y][x] = 4; // decorazione
        }
      }
    }

    // Fase 5: Aggiungi porte in punti specifici
    for (int y = 2; y < chunkSize - 2; y++) {
      for (int x = 2; x < chunkSize - 2; x++) {
        if (tiles[y][x] == 1) {
          // Controlla se è un collo di bottiglia (muri su 2 lati opposti)
          final muriOrizzontali = (tiles[y][x - 1] == 2 ? 1 : 0) + (tiles[y][x + 1] == 2 ? 1 : 0);
          final muriVerticali = (tiles[y - 1][x] == 2 ? 1 : 0) + (tiles[y + 1][x] == 2 ? 1 : 0);

          if ((muriOrizzontali == 2 || muriVerticali == 2) && rng.nextDouble() < 0.3) {
            tiles[y][x] = 3; // porta
          }
        }
      }
    }
  }

  /// Determina il bioma del chunk basandosi sulla distanza dal centro
  ChunkBiome _determinaBioma(ChunkCoord coord, Random rng) {
    final distanza = sqrt((coord.x * coord.x + coord.y * coord.y).toDouble());

    if (distanza < 3) return ChunkBiome.dungeon;
    if (distanza < 6) {
      return [ChunkBiome.caverna, ChunkBiome.cripte][rng.nextInt(2)];
    }
    if (distanza < 10) {
      return [ChunkBiome.foresta, ChunkBiome.tempio, ChunkBiome.laboratorio][rng.nextInt(3)];
    }
    if (distanza < 15) {
      return [ChunkBiome.vulcano, ChunkBiome.ghiaccio][rng.nextInt(2)];
    }
    return [ChunkBiome.abisso, ChunkBiome.trono][rng.nextInt(2)];
  }

  /// Converti posizione mondo in coordinate chunk
  ChunkCoord _posizioneAChunk(Vector2 posizione) {
    return ChunkCoord(
      (posizione.x / (chunkSize * WorldConstants.tileSize)).floor(),
      (posizione.y / (chunkSize * WorldConstants.tileSize)).floor(),
    );
  }

  /// Ottieni i chunk attualmente caricati
  int get chunksCaricati => _chunkComponents.length;

  /// Ottieni il seed del mondo
  int get worldSeed => _worldSeed;

  /// Ottieni il bioma del chunk corrente
  ChunkBiome? getBiomaCorrente() {
    return _chunkCache[_lastPlayerChunk]?.biome;
  }

  /// Ottieni le posizioni spawn nemici nei chunk attivi
  List<Vector2> getSpawnNemiciAttivi() {
    final spawns = <Vector2>[];
    for (final coord in _chunkComponents.keys) {
      final data = _chunkCache[coord];
      if (data != null) {
        spawns.addAll(data.spawnNemici);
      }
    }
    return spawns;
  }

  /// Pulisci tutti i chunk
  void pulisci() {
    for (final coord in _chunkComponents.keys.toList()) {
      _scaricaChunk(coord);
    }
    _chunkCache.clear();
    dev.log('[CHUNK] Tutti i chunk puliti');
  }
}
