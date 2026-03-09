/// Sistema Shadow Army di Dark Leveling Infinity
/// Gestisce l'estrazione, l'evocazione e la progressione delle ombre
/// Ispirato al sistema di Sung Jinwoo in Solo Leveling
library;

import 'dart:developer' as dev;
import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../../../data/models/enemy_data.dart';

/// Dati di un'ombra estratta
class ShadowData {
  final String id;
  final String nome;
  final String nomeOriginale; // nome del nemico da cui è stata estratta
  final EnemyAIType aiType;
  final ElementType elemento;
  ShadowGrade grado;
  int livello;
  double saluteBase;
  double dannoBase;
  double difesaBase;
  double velocitaBase;
  bool evocata; // attualmente in campo?
  int uccisioni; // nemici eliminati da questa ombra
  double espAccumulata;

  ShadowData({
    required this.id,
    required this.nome,
    required this.nomeOriginale,
    required this.aiType,
    this.elemento = ElementType.none,
    this.grado = ShadowGrade.normal,
    this.livello = 1,
    required this.saluteBase,
    required this.dannoBase,
    required this.difesaBase,
    required this.velocitaBase,
    this.evocata = false,
    this.uccisioni = 0,
    this.espAccumulata = 0,
  });

  /// Salute effettiva considerando grado e livello
  double get saluteEffettiva =>
      saluteBase * grado.moltiplicatoreStats * (1.0 + livello * 0.1);

  /// Danno effettivo considerando grado e livello
  double get dannoEffettivo =>
      dannoBase * grado.moltiplicatoreStats * (1.0 + livello * 0.08);

  /// Difesa effettiva
  double get difesaEffettiva =>
      difesaBase * grado.moltiplicatoreStats * (1.0 + livello * 0.05);

  /// Velocità effettiva
  double get velocitaEffettiva =>
      velocitaBase * (1.0 + livello * 0.02);

  /// Esperienza necessaria per il prossimo livello
  double get espPerProssimoLivello => 100.0 * livello * 1.2;

  /// Aggiungi esperienza e controlla level up
  bool aggiungiEsperienza(double quantita) {
    espAccumulata += quantita;
    if (espAccumulata >= espPerProssimoLivello) {
      espAccumulata -= espPerProssimoLivello;
      livello++;
      dev.log('[OMBRA] $nome è salita al livello $livello!');

      // Controlla promozione di grado
      _controllaPromozione();
      return true;
    }
    return false;
  }

  /// Controlla se l'ombra può essere promossa
  void _controllaPromozione() {
    if (livello >= 50 && grado == ShadowGrade.normal) {
      grado = ShadowGrade.elite;
      dev.log('[OMBRA] $nome promossa a ${grado.nome}!');
    } else if (livello >= 100 && grado == ShadowGrade.elite) {
      grado = ShadowGrade.knight;
      dev.log('[OMBRA] $nome promossa a ${grado.nome}!');
    } else if (livello >= 200 && grado == ShadowGrade.knight) {
      grado = ShadowGrade.eliteKnight;
      dev.log('[OMBRA] $nome promossa a ${grado.nome}!');
    } else if (livello >= 400 && grado == ShadowGrade.eliteKnight) {
      grado = ShadowGrade.marshal;
      dev.log('[OMBRA] $nome promossa a ${grado.nome}!');
    } else if (livello >= 700 && grado == ShadowGrade.marshal) {
      grado = ShadowGrade.grandMarshal;
      dev.log('[OMBRA] $nome promossa a ${grado.nome}!');
    }
  }

  /// Converte in Map per il salvataggio
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'nomeOriginale': nomeOriginale,
    'aiType': aiType.index,
    'elemento': elemento.index,
    'grado': grado.index,
    'livello': livello,
    'saluteBase': saluteBase,
    'dannoBase': dannoBase,
    'difesaBase': difesaBase,
    'velocitaBase': velocitaBase,
    'evocata': evocata,
    'uccisioni': uccisioni,
    'espAccumulata': espAccumulata,
  };

  /// Crea da Map
  factory ShadowData.fromJson(Map<String, dynamic> json) => ShadowData(
    id: json['id'] as String,
    nome: json['nome'] as String,
    nomeOriginale: json['nomeOriginale'] as String,
    aiType: EnemyAIType.values[json['aiType'] as int],
    elemento: ElementType.values[json['elemento'] as int? ?? 0],
    grado: ShadowGrade.values[json['grado'] as int? ?? 0],
    livello: json['livello'] as int? ?? 1,
    saluteBase: (json['saluteBase'] as num).toDouble(),
    dannoBase: (json['dannoBase'] as num).toDouble(),
    difesaBase: (json['difesaBase'] as num).toDouble(),
    velocitaBase: (json['velocitaBase'] as num).toDouble(),
    evocata: json['evocata'] as bool? ?? false,
    uccisioni: json['uccisioni'] as int? ?? 0,
    espAccumulata: (json['espAccumulata'] as num?)?.toDouble() ?? 0,
  );
}

/// Sistema di gestione dell'esercito delle ombre
class ShadowArmySystem {
  // Tutte le ombre estratte
  final List<ShadowData> _ombreEstratte = [];

  // Ombre attualmente evocate in campo
  final List<ShadowData> _ombreEvocate = [];

  // Numero massimo di ombre evocabili contemporaneamente
  int _maxOmbreEvocabili = 5;

  // Numero massimo di ombre nell'esercito
  int _maxOmbreTotali = ShadowConstants.maxShadowsEarlyGame;

  // Generatore casuale
  final Random _rng = Random();

  /// Nomi possibili per le ombre (stile Solo Leveling)
  static const List<String> _nomiOmbre = [
    'Igris', 'Tusk', 'Iron', 'Beru', 'Greed', 'Kaisel', 'Tank',
    'Jima', 'Fang', 'Cerberus', 'Shade', 'Wraith', 'Phantom',
    'Specter', 'Reaper', 'Scythe', 'Blade', 'Furia', 'Obsidian',
    'Onyx', 'Shadow', 'Notte', 'Tenebra', 'Oscuro', 'Abisso',
    'Vuoto', 'Eclipse', 'Crepuscolo', 'Mezzanotte', 'Ombra',
  ];

  /// Tenta di estrarre un'ombra da un nemico sconfitto
  ShadowData? tentaEstrazione(EnemyData nemico, {bool isBoss = false}) {
    dev.log('[SHADOW] Tentativo estrazione da ${nemico.nome}...');

    if (!nemico.puoEssereEstratto) {
      dev.log('[SHADOW] Questo nemico non può essere estratto!');
      return null;
    }

    // Controlla se l'esercito è pieno
    if (_ombreEstratte.length >= _maxOmbreTotali) {
      dev.log('[SHADOW] Esercito delle ombre al massimo!');
      return null;
    }

    // Calcola probabilità di estrazione
    final chance = isBoss
        ? ShadowConstants.bossExtractionChance
        : ShadowConstants.extractionBaseChance;

    if (_rng.nextDouble() > chance) {
      dev.log('[SHADOW] Estrazione fallita!');
      return null;
    }

    // Estrazione riuscita!
    final nomeOmbra = _nomiOmbre[_rng.nextInt(_nomiOmbre.length)];

    // Determina il grado iniziale basato sulla forza del nemico
    ShadowGrade gradoIniziale = ShadowGrade.normal;
    if (isBoss) {
      gradoIniziale = ShadowGrade.knight;
    } else if (nemico.livelloBase >= 100) {
      gradoIniziale = ShadowGrade.elite;
    }

    final ombra = ShadowData(
      id: '${nemico.id}_${DateTime.now().millisecondsSinceEpoch}',
      nome: nomeOmbra,
      nomeOriginale: nemico.nome,
      aiType: nemico.aiType,
      elemento: nemico.elemento,
      grado: gradoIniziale,
      saluteBase: nemico.saluteBase * 0.8,
      dannoBase: nemico.dannoBase * 0.7,
      difesaBase: nemico.difesaBase * 0.6,
      velocitaBase: nemico.velocitaBase,
    );

    _ombreEstratte.add(ombra);

    dev.log('[SHADOW] Estrazione riuscita! ${ombra.nome} (${ombra.nomeOriginale}) - Grado: ${ombra.grado.nome}');
    return ombra;
  }

  /// Evoca un'ombra in campo
  bool evocaOmbra(String ombraId) {
    if (_ombreEvocate.length >= _maxOmbreEvocabili) {
      dev.log('[SHADOW] Massimo ombre evocate raggiunto!');
      return false;
    }

    final ombra = _ombreEstratte.firstWhere(
      (o) => o.id == ombraId && !o.evocata,
      orElse: () => ShadowData(
        id: '', nome: '', nomeOriginale: '',
        aiType: EnemyAIType.melee,
        saluteBase: 0, dannoBase: 0, difesaBase: 0, velocitaBase: 0,
      ),
    );

    if (ombra.id.isEmpty) return false;

    ombra.evocata = true;
    _ombreEvocate.add(ombra);

    dev.log('[SHADOW] ${ombra.nome} evocata! (${_ombreEvocate.length}/$_maxOmbreEvocabili)');
    return true;
  }

  /// Richiama un'ombra dal campo
  void richiamaOmbra(String ombraId) {
    final ombra = _ombreEvocate.firstWhere(
      (o) => o.id == ombraId,
      orElse: () => ShadowData(
        id: '', nome: '', nomeOriginale: '',
        aiType: EnemyAIType.melee,
        saluteBase: 0, dannoBase: 0, difesaBase: 0, velocitaBase: 0,
      ),
    );

    if (ombra.id.isEmpty) return;

    ombra.evocata = false;
    _ombreEvocate.remove(ombra);

    dev.log('[SHADOW] ${ombra.nome} richiamata');
  }

  /// Evoca tutte le ombre disponibili
  int evocaTutte() {
    int evocate = 0;
    for (final ombra in _ombreEstratte) {
      if (!ombra.evocata && _ombreEvocate.length < _maxOmbreEvocabili) {
        ombra.evocata = true;
        _ombreEvocate.add(ombra);
        evocate++;
      }
    }
    dev.log('[SHADOW] $evocate ombre evocate!');
    return evocate;
  }

  /// Richiama tutte le ombre
  void richiamaTutte() {
    for (final ombra in _ombreEvocate) {
      ombra.evocata = false;
    }
    _ombreEvocate.clear();
    dev.log('[SHADOW] Tutte le ombre richiamate');
  }

  /// Distribuisci esperienza a tutte le ombre evocate
  void distribuisciEsperienza(double espTotale) {
    if (_ombreEvocate.isEmpty) return;

    final espPerOmbra = espTotale * ShadowConstants.shadowExpShare / _ombreEvocate.length;
    for (final ombra in _ombreEvocate) {
      ombra.aggiungiEsperienza(espPerOmbra);
    }
  }

  /// Aggiorna il numero massimo di ombre basato sul livello del player
  void aggiornaLimiti(int livelloPlayer) {
    if (livelloPlayer >= 200) {
      _maxOmbreTotali = ShadowConstants.maxShadowsEndGame;
      _maxOmbreEvocabili = 30;
    } else if (livelloPlayer >= 100) {
      _maxOmbreTotali = ShadowConstants.maxShadowsLateGame;
      _maxOmbreEvocabili = 20;
    } else if (livelloPlayer >= 50) {
      _maxOmbreTotali = ShadowConstants.maxShadowsMidGame;
      _maxOmbreEvocabili = 10;
    } else {
      _maxOmbreTotali = ShadowConstants.maxShadowsEarlyGame;
      _maxOmbreEvocabili = 5;
    }
  }

  /// Ottieni tutte le ombre estratte
  List<ShadowData> get ombreEstratte => List.unmodifiable(_ombreEstratte);

  /// Ottieni le ombre attualmente evocate
  List<ShadowData> get ombreEvocate => List.unmodifiable(_ombreEvocate);

  /// Numero totale di ombre
  int get totaleOmbre => _ombreEstratte.length;

  /// Numero ombre evocate
  int get numOmbreEvocate => _ombreEvocate.length;

  /// Numero massimo evocabili
  int get maxOmbreEvocabili => _maxOmbreEvocabili;

  /// Numero massimo totali
  int get maxOmbreTotali => _maxOmbreTotali;

  /// L'ombra più forte
  ShadowData? get ombraPiuForte {
    if (_ombreEstratte.isEmpty) return null;
    return _ombreEstratte.reduce(
      (a, b) => a.dannoEffettivo > b.dannoEffettivo ? a : b,
    );
  }

  /// Serializzazione per il salvataggio
  List<Map<String, dynamic>> toJson() {
    return _ombreEstratte.map((o) => o.toJson()).toList();
  }

  /// Deserializzazione dal salvataggio
  void fromJson(List<dynamic> json) {
    _ombreEstratte.clear();
    _ombreEvocate.clear();
    for (final o in json) {
      _ombreEstratte.add(ShadowData.fromJson(o as Map<String, dynamic>));
    }
  }
}
