/// Modello dati del giocatore
/// Contiene tutte le informazioni persistenti del player
library;

import '../../core/constants/game_constants.dart';

/// Statistiche base del player
class PlayerStats {
  int forza;
  int agilita;
  int vitalita;
  int intelligenza;
  int percezione;

  PlayerStats({
    this.forza = PlayerConstants.baseStrength,
    this.agilita = PlayerConstants.baseAgility,
    this.vitalita = PlayerConstants.baseVitality,
    this.intelligenza = PlayerConstants.baseIntelligence,
    this.percezione = PlayerConstants.basePerception,
  });

  /// Salute massima calcolata dalla vitalità
  double get saluteMax => PlayerConstants.baseHealth + (vitalita * 10.0);

  /// Mana massimo calcolato dall'intelligenza
  double get manaMax => PlayerConstants.baseMana + (intelligenza * 5.0);

  /// Danno fisico base
  double get dannoFisico => forza * 2.5;

  /// Danno magico base
  double get dannoMagico => intelligenza * 2.0;

  /// Velocità movimento
  double get velocita => PlayerConstants.baseSpeed + (agilita * 1.5);

  /// Possibilità critico
  double get critChance =>
      CombatConstants.baseCriticalChance + (percezione * 0.002);

  /// Evasione
  double get evasione => agilita * 0.003;

  /// Difesa fisica
  double get difesaFisica => vitalita * 1.5 + forza * 0.5;

  /// Difesa magica
  double get difesaMagica => intelligenza * 1.0 + percezione * 0.5;

  /// Converte le stats in Map per il salvataggio
  Map<String, dynamic> toJson() => {
    'forza': forza,
    'agilita': agilita,
    'vitalita': vitalita,
    'intelligenza': intelligenza,
    'percezione': percezione,
  };

  /// Crea PlayerStats da Map
  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    forza: json['forza'] as int? ?? PlayerConstants.baseStrength,
    agilita: json['agilita'] as int? ?? PlayerConstants.baseAgility,
    vitalita: json['vitalita'] as int? ?? PlayerConstants.baseVitality,
    intelligenza:
        json['intelligenza'] as int? ?? PlayerConstants.baseIntelligence,
    percezione:
        json['percezione'] as int? ?? PlayerConstants.basePerception,
  );
}

/// Dati completi del player per il salvataggio
class PlayerData {
  String nome;
  int livello;
  double esperienza;
  double espPerProssimoLivello;
  double saluteAttuale;
  double manaAttuale;
  PlayerStats stats;
  int puntiStatDisponibili;
  int puntiAbilitaDisponibili;
  HunterRank rango;
  int oro;
  int gemme;
  int gatesCompletati;
  int nemiciSconfitti;
  int bosssSconfitti;
  int mortiTotali;
  double tempoGiocatoSecondi;
  int comboMassima;
  int livelloMaxRaggiunto;
  List<String> abilitaSbloccate;
  List<String> equipaggiamentoIds;
  List<String> inventarioIds;
  DateTime ultimoAccesso;

  PlayerData({
    this.nome = 'Cacciatore',
    this.livello = 1,
    this.esperienza = 0,
    this.espPerProssimoLivello = 100,
    this.saluteAttuale = 100,
    this.manaAttuale = 50,
    PlayerStats? stats,
    this.puntiStatDisponibili = 0,
    this.puntiAbilitaDisponibili = 0,
    this.rango = HunterRank.e,
    this.oro = 0,
    this.gemme = 0,
    this.gatesCompletati = 0,
    this.nemiciSconfitti = 0,
    this.bosssSconfitti = 0,
    this.mortiTotali = 0,
    this.tempoGiocatoSecondi = 0,
    this.comboMassima = 0,
    this.livelloMaxRaggiunto = 1,
    List<String>? abilitaSbloccate,
    List<String>? equipaggiamentoIds,
    List<String>? inventarioIds,
    DateTime? ultimoAccesso,
  }) : stats = stats ?? PlayerStats(),
       abilitaSbloccate = abilitaSbloccate ?? [],
       equipaggiamentoIds = equipaggiamentoIds ?? [],
       inventarioIds = inventarioIds ?? [],
       ultimoAccesso = ultimoAccesso ?? DateTime.now();

  /// Calcola l'exp necessaria per il prossimo livello
  static double calcolaExpNecessaria(int livello) {
    return PlayerConstants.baseExpToLevel *
        (livello * PlayerConstants.expMultiplier);
  }

  /// Aggiunge esperienza e gestisce il level up
  bool aggiungiEsperienza(double quantita) {
    esperienza += quantita;
    if (esperienza >= espPerProssimoLivello) {
      // Level up!
      esperienza -= espPerProssimoLivello;
      livello++;
      if (livello > livelloMaxRaggiunto) livelloMaxRaggiunto = livello;
      espPerProssimoLivello = calcolaExpNecessaria(livello);
      puntiStatDisponibili += PlayerConstants.statPointsPerLevel;
      puntiAbilitaDisponibili += PlayerConstants.skillPointsPerLevel;

      // Ripristina salute e mana al level up
      saluteAttuale = stats.saluteMax;
      manaAttuale = stats.manaMax;

      // Aggiorna rango
      _aggiornaRango();
      return true; // Level up avvenuto
    }
    return false;
  }

  /// Aggiorna il rango del cacciatore basato sul livello
  void _aggiornaRango() {
    for (final rank in HunterRank.values.reversed) {
      if (livello >= rank.livelloMinimo) {
        rango = rank;
        return;
      }
    }
  }

  /// Converte in Map per il salvataggio
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'livello': livello,
    'esperienza': esperienza,
    'espPerProssimoLivello': espPerProssimoLivello,
    'saluteAttuale': saluteAttuale,
    'manaAttuale': manaAttuale,
    'stats': stats.toJson(),
    'puntiStatDisponibili': puntiStatDisponibili,
    'puntiAbilitaDisponibili': puntiAbilitaDisponibili,
    'rango': rango.index,
    'oro': oro,
    'gemme': gemme,
    'gatesCompletati': gatesCompletati,
    'nemiciSconfitti': nemiciSconfitti,
    'bosssSconfitti': bosssSconfitti,
    'mortiTotali': mortiTotali,
    'tempoGiocatoSecondi': tempoGiocatoSecondi,
    'comboMassima': comboMassima,
    'livelloMaxRaggiunto': livelloMaxRaggiunto,
    'abilitaSbloccate': abilitaSbloccate,
    'equipaggiamentoIds': equipaggiamentoIds,
    'inventarioIds': inventarioIds,
    'ultimoAccesso': ultimoAccesso.toIso8601String(),
  };

  /// Crea da Map
  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
    nome: json['nome'] as String? ?? 'Cacciatore',
    livello: json['livello'] as int? ?? 1,
    esperienza: (json['esperienza'] as num?)?.toDouble() ?? 0,
    espPerProssimoLivello:
        (json['espPerProssimoLivello'] as num?)?.toDouble() ?? 100,
    saluteAttuale: (json['saluteAttuale'] as num?)?.toDouble() ?? 100,
    manaAttuale: (json['manaAttuale'] as num?)?.toDouble() ?? 50,
    stats:
        json['stats'] != null
            ? PlayerStats.fromJson(json['stats'] as Map<String, dynamic>)
            : null,
    puntiStatDisponibili: json['puntiStatDisponibili'] as int? ?? 0,
    puntiAbilitaDisponibili: json['puntiAbilitaDisponibili'] as int? ?? 0,
    rango: HunterRank.values[json['rango'] as int? ?? 0],
    oro: json['oro'] as int? ?? 0,
    gemme: json['gemme'] as int? ?? 0,
    gatesCompletati: json['gatesCompletati'] as int? ?? 0,
    nemiciSconfitti: json['nemiciSconfitti'] as int? ?? 0,
    bosssSconfitti: json['bosssSconfitti'] as int? ?? 0,
    mortiTotali: json['mortiTotali'] as int? ?? 0,
    tempoGiocatoSecondi:
        (json['tempoGiocatoSecondi'] as num?)?.toDouble() ?? 0,
    comboMassima: json['comboMassima'] as int? ?? 0,
    livelloMaxRaggiunto: json['livelloMaxRaggiunto'] as int? ?? 1,
    abilitaSbloccate:
        (json['abilitaSbloccate'] as List?)?.cast<String>() ?? [],
    equipaggiamentoIds:
        (json['equipaggiamentoIds'] as List?)?.cast<String>() ?? [],
    inventarioIds: (json['inventarioIds'] as List?)?.cast<String>() ?? [],
    ultimoAccesso:
        json['ultimoAccesso'] != null
            ? DateTime.parse(json['ultimoAccesso'] as String)
            : null,
  );
}
