/// Modello dati per le quest e missioni
/// Sistema di quest giornaliere, principali e secondarie
library;

/// Tipo di quest
enum QuestType {
  /// Missione della storia principale
  principale,

  /// Missione giornaliera (reset ogni 24h)
  giornaliera,

  /// Missione settimanale
  settimanale,

  /// Missione secondaria opzionale
  secondaria,

  /// Sfida speciale a tempo
  sfida,

  /// Missione dell'esercito delle ombre
  ombre,
}

/// Stato della quest
enum QuestStatus {
  /// Non ancora sbloccata
  bloccata,

  /// Disponibile ma non accettata
  disponibile,

  /// In corso
  inCorso,

  /// Completata ma ricompensa non riscossa
  completata,

  /// Ricompensa riscossa
  riscossa,

  /// Fallita (scaduta o condizioni non soddisfatte)
  fallita,
}

/// Obiettivo di una quest
class QuestObjective {
  final String id;
  final String descrizione;
  final QuestObjectiveType tipo;
  final int quantitaRichiesta;
  int quantitaAttuale;
  final String? targetId; // ID nemico/item specifico se necessario

  QuestObjective({
    required this.id,
    required this.descrizione,
    required this.tipo,
    required this.quantitaRichiesta,
    this.quantitaAttuale = 0,
    this.targetId,
  });

  /// Controlla se l'obiettivo è completato
  bool get completato => quantitaAttuale >= quantitaRichiesta;

  /// Progresso in percentuale
  double get progresso =>
      (quantitaAttuale / quantitaRichiesta).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'descrizione': descrizione,
    'tipo': tipo.index,
    'quantitaRichiesta': quantitaRichiesta,
    'quantitaAttuale': quantitaAttuale,
    'targetId': targetId,
  };

  factory QuestObjective.fromJson(Map<String, dynamic> json) =>
      QuestObjective(
        id: json['id'] as String,
        descrizione: json['descrizione'] as String,
        tipo: QuestObjectiveType.values[json['tipo'] as int],
        quantitaRichiesta: json['quantitaRichiesta'] as int,
        quantitaAttuale: json['quantitaAttuale'] as int? ?? 0,
        targetId: json['targetId'] as String?,
      );
}

/// Tipo di obiettivo
enum QuestObjectiveType {
  /// Uccidi X nemici
  uccidiNemici,

  /// Uccidi un boss specifico
  uccidiBoss,

  /// Completa X dungeon/gate
  completaGate,

  /// Raccogli X oggetti
  raccogliOggetti,

  /// Raggiungi livello X
  raggiungiLivello,

  /// Estrai X ombre
  estraiOmbre,

  /// Raggiungi combo di X
  raggiungiCombo,

  /// Sopravvivi X secondi
  sopravvivi,

  /// Guadagna X oro
  guadagnaOro,

  /// Potenzia un'ombra X volte
  potenziaOmbra,

  /// Usa un'abilità X volte
  usaAbilita,

  /// Completa un gate senza subire danni
  gateSenzaDanni,
}

/// Ricompensa di una quest
class QuestReward {
  final int esperienza;
  final int oro;
  final int gemme;
  final List<String> itemIds;
  final int puntiAbilita;

  const QuestReward({
    this.esperienza = 0,
    this.oro = 0,
    this.gemme = 0,
    this.itemIds = const [],
    this.puntiAbilita = 0,
  });

  Map<String, dynamic> toJson() => {
    'esperienza': esperienza,
    'oro': oro,
    'gemme': gemme,
    'itemIds': itemIds,
    'puntiAbilita': puntiAbilita,
  };

  factory QuestReward.fromJson(Map<String, dynamic> json) => QuestReward(
    esperienza: json['esperienza'] as int? ?? 0,
    oro: json['oro'] as int? ?? 0,
    gemme: json['gemme'] as int? ?? 0,
    itemIds: (json['itemIds'] as List?)?.cast<String>() ?? [],
    puntiAbilita: json['puntiAbilita'] as int? ?? 0,
  );
}

/// Dati completi di una quest
class QuestData {
  final String id;
  final String titolo;
  final String descrizione;
  final QuestType tipo;
  QuestStatus stato;
  final int livelloRichiesto;
  final List<QuestObjective> obiettivi;
  final QuestReward ricompensa;
  final String? questPrerequisito; // ID della quest precedente
  final Duration? durata; // tempo limite (null = nessun limite)
  DateTime? dataInizio;
  final String messaggioSistema; // Messaggio stile [SISTEMA]

  QuestData({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.tipo,
    this.stato = QuestStatus.disponibile,
    this.livelloRichiesto = 1,
    required this.obiettivi,
    required this.ricompensa,
    this.questPrerequisito,
    this.durata,
    this.dataInizio,
    this.messaggioSistema = '',
  });

  /// Controlla se tutti gli obiettivi sono completati
  bool get tuttiObiettiviCompletati =>
      obiettivi.every((obj) => obj.completato);

  /// Progresso totale della quest
  double get progressoTotale {
    if (obiettivi.isEmpty) return 0.0;
    final somma = obiettivi.fold(0.0, (sum, obj) => sum + obj.progresso);
    return somma / obiettivi.length;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titolo': titolo,
    'descrizione': descrizione,
    'tipo': tipo.index,
    'stato': stato.index,
    'livelloRichiesto': livelloRichiesto,
    'obiettivi': obiettivi.map((o) => o.toJson()).toList(),
    'ricompensa': ricompensa.toJson(),
    'questPrerequisito': questPrerequisito,
    'durata': durata?.inSeconds,
    'dataInizio': dataInizio?.toIso8601String(),
    'messaggioSistema': messaggioSistema,
  };

  factory QuestData.fromJson(Map<String, dynamic> json) => QuestData(
    id: json['id'] as String,
    titolo: json['titolo'] as String,
    descrizione: json['descrizione'] as String,
    tipo: QuestType.values[json['tipo'] as int],
    stato: QuestStatus.values[json['stato'] as int? ?? 0],
    livelloRichiesto: json['livelloRichiesto'] as int? ?? 1,
    obiettivi:
        (json['obiettivi'] as List)
            .map((o) => QuestObjective.fromJson(o as Map<String, dynamic>))
            .toList(),
    ricompensa: QuestReward.fromJson(
      json['ricompensa'] as Map<String, dynamic>,
    ),
    questPrerequisito: json['questPrerequisito'] as String?,
    durata:
        json['durata'] != null
            ? Duration(seconds: json['durata'] as int)
            : null,
    dataInizio:
        json['dataInizio'] != null
            ? DateTime.parse(json['dataInizio'] as String)
            : null,
    messaggioSistema: json['messaggioSistema'] as String? ?? '',
  );
}
