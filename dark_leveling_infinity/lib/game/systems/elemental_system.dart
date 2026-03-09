/// Sistema di Reazioni Elementali per Dark Leveling Infinity
/// Combinazioni di elementi che creano effetti devastanti
/// Ispirato a Genshin Impact con twist oscuro stile Solo Leveling
library;

import 'dart:developer' as dev;

import '../../data/models/enemy_data.dart';

/// Reazione elementale risultante dalla combinazione di due elementi
class ReazioneElementale {
  final String nome;
  final String descrizione;
  final ElementType elemento1;
  final ElementType elemento2;
  final double moltiplicatoreDanno;
  final double durataEffetto; // secondi
  final ReazioneEffetto effetto;
  final int coloreHex;

  const ReazioneElementale({
    required this.nome,
    required this.descrizione,
    required this.elemento1,
    required this.elemento2,
    required this.moltiplicatoreDanno,
    this.durataEffetto = 3.0,
    required this.effetto,
    required this.coloreHex,
  });
}

/// Tipo di effetto della reazione
enum ReazioneEffetto {
  /// Esplosione ad area (Fuoco + fulmine)
  esplosione,

  /// Vapore che acceca (Fuoco + Ghiaccio)
  vapore,

  /// Conduce elettricità nell'acqua (Ghiaccio + Fulmine)
  superconduzione,

  /// Cristallizza il nemico (Terra + qualsiasi)
  cristallizzazione,

  /// Corrode armatura (Veleno + Fuoco)
  corrosione,

  /// Terrore oscuro (Oscuro + Fulmine)
  terrore,

  /// Purificazione (Sacro + Oscuro)
  purificazione,

  /// Tempesta d'ombra (Ombra + Vento)
  tempestaOmbra,

  /// Gelo infernale (Ghiaccio + Oscuro)
  geloInfernale,

  /// Fiamma sacra (Fuoco + Sacro)
  fiammaSacra,

  /// Peste tossica (Veleno + Vento)
  pesteTossica,

  /// Terremoto (Terra + Fulmine)
  terremoto,

  /// Nebbia velenosa (Veleno + Ghiaccio)
  nebbiaVelenosa,

  /// Tempesta di fuoco (Fuoco + Vento)
  tempestaFuoco,

  /// Lama del vuoto (Ombra + Oscuro)
  lamaVuoto,
}

/// Sistema che gestisce le reazioni elementali in combattimento
class ElementalSystem {
  // Cache degli elementi applicati ai nemici: enemyId -> [elementi attivi]
  final Map<String, List<_ElementoApplicato>> _elementiAttivi = {};

  // Database delle reazioni
  static const List<ReazioneElementale> _reazioni = [
    // Fuoco combinations
    ReazioneElementale(nome: 'Esplosione', descrizione: 'Esplosione devastante ad area', elemento1: ElementType.fire, elemento2: ElementType.lightning, moltiplicatoreDanno: 3.0, effetto: ReazioneEffetto.esplosione, coloreHex: 0xFFFF6F00),
    ReazioneElementale(nome: 'Vapore', descrizione: 'Nuvola di vapore accecante', elemento1: ElementType.fire, elemento2: ElementType.ice, moltiplicatoreDanno: 2.0, durataEffetto: 4.0, effetto: ReazioneEffetto.vapore, coloreHex: 0xFF90CAF9),
    ReazioneElementale(nome: 'Corrosione', descrizione: 'Acido che corrode l\'armatura', elemento1: ElementType.fire, elemento2: ElementType.poison, moltiplicatoreDanno: 2.5, durataEffetto: 5.0, effetto: ReazioneEffetto.corrosione, coloreHex: 0xFF827717),
    ReazioneElementale(nome: 'Fiamma Sacra', descrizione: 'Fiamma purificatrice divina', elemento1: ElementType.fire, elemento2: ElementType.holy, moltiplicatoreDanno: 3.5, effetto: ReazioneEffetto.fiammaSacra, coloreHex: 0xFFFFD54F),
    ReazioneElementale(nome: 'Tempesta di Fuoco', descrizione: 'Tornado infuocato', elemento1: ElementType.fire, elemento2: ElementType.wind, moltiplicatoreDanno: 2.8, effetto: ReazioneEffetto.tempestaFuoco, coloreHex: 0xFFFF3D00),

    // Ghiaccio combinations
    ReazioneElementale(nome: 'Superconduzione', descrizione: 'Scarica elettrica nel ghiaccio', elemento1: ElementType.ice, elemento2: ElementType.lightning, moltiplicatoreDanno: 2.5, effetto: ReazioneEffetto.superconduzione, coloreHex: 0xFF00E5FF),
    ReazioneElementale(nome: 'Gelo Infernale', descrizione: 'Ghiaccio oscuro che divora', elemento1: ElementType.ice, elemento2: ElementType.dark, moltiplicatoreDanno: 3.0, durataEffetto: 4.0, effetto: ReazioneEffetto.geloInfernale, coloreHex: 0xFF1A237E),
    ReazioneElementale(nome: 'Nebbia Velenosa', descrizione: 'Nebbia gelida tossica', elemento1: ElementType.ice, elemento2: ElementType.poison, moltiplicatoreDanno: 2.0, durataEffetto: 6.0, effetto: ReazioneEffetto.nebbiaVelenosa, coloreHex: 0xFF1B5E20),

    // Fulmine combinations
    ReazioneElementale(nome: 'Terrore Oscuro', descrizione: 'Fulmine oscuro paralizzante', elemento1: ElementType.lightning, elemento2: ElementType.dark, moltiplicatoreDanno: 3.0, durataEffetto: 2.0, effetto: ReazioneEffetto.terrore, coloreHex: 0xFF4A148C),
    ReazioneElementale(nome: 'Terremoto', descrizione: 'La terra trema sotto i fulmini', elemento1: ElementType.lightning, elemento2: ElementType.earth, moltiplicatoreDanno: 2.5, effetto: ReazioneEffetto.terremoto, coloreHex: 0xFF795548),

    // Terra combinations
    ReazioneElementale(nome: 'Cristallizzazione', descrizione: 'Intrappola in un cristallo', elemento1: ElementType.earth, elemento2: ElementType.ice, moltiplicatoreDanno: 1.5, durataEffetto: 3.0, effetto: ReazioneEffetto.cristallizzazione, coloreHex: 0xFF00BCD4),

    // Oscuro/Ombra combinations
    ReazioneElementale(nome: 'Purificazione', descrizione: 'Luce e ombra si annullano', elemento1: ElementType.dark, elemento2: ElementType.holy, moltiplicatoreDanno: 4.0, effetto: ReazioneEffetto.purificazione, coloreHex: 0xFFFFFFFF),
    ReazioneElementale(nome: 'Lama del Vuoto', descrizione: 'Il nulla divora tutto', elemento1: ElementType.shadow, elemento2: ElementType.dark, moltiplicatoreDanno: 3.5, effetto: ReazioneEffetto.lamaVuoto, coloreHex: 0xFF000000),
    ReazioneElementale(nome: 'Tempesta d\'Ombra', descrizione: 'Vento oscuro che taglia', elemento1: ElementType.shadow, elemento2: ElementType.wind, moltiplicatoreDanno: 2.8, effetto: ReazioneEffetto.tempestaOmbra, coloreHex: 0xFF311B92),

    // Veleno combinations
    ReazioneElementale(nome: 'Peste Tossica', descrizione: 'Il vento sparge il veleno', elemento1: ElementType.poison, elemento2: ElementType.wind, moltiplicatoreDanno: 2.0, durataEffetto: 8.0, effetto: ReazioneEffetto.pesteTossica, coloreHex: 0xFF33691E),
  ];

  /// Applica un elemento a un nemico e controlla le reazioni
  ReazioneElementale? applicaElemento(String nemicoId, ElementType elemento) {
    // Crea la lista se non esiste
    _elementiAttivi.putIfAbsent(nemicoId, () => []);

    // Rimuovi elementi scaduti
    _elementiAttivi[nemicoId]!.removeWhere((e) => e.scaduto);

    // Controlla se c'è un elemento attivo che può reagire
    for (final elementoAttivo in _elementiAttivi[nemicoId]!) {
      final reazione = _cercaReazione(elementoAttivo.tipo, elemento);
      if (reazione != null) {
        // Reazione trovata! Rimuovi l'elemento che ha reagito
        _elementiAttivi[nemicoId]!.remove(elementoAttivo);
        dev.log('[ELEMENTALE] Reazione: ${reazione.nome}! (${elementoAttivo.tipo} + $elemento)');
        return reazione;
      }
    }

    // Nessuna reazione, aggiungi l'elemento
    _elementiAttivi[nemicoId]!.add(_ElementoApplicato(
      tipo: elemento,
      scadenza: DateTime.now().add(const Duration(seconds: 10)),
    ));

    return null; // Nessuna reazione
  }

  /// Cerca una reazione tra due elementi
  ReazioneElementale? _cercaReazione(ElementType a, ElementType b) {
    for (final reazione in _reazioni) {
      if ((reazione.elemento1 == a && reazione.elemento2 == b) ||
          (reazione.elemento1 == b && reazione.elemento2 == a)) {
        return reazione;
      }
    }
    return null;
  }

  /// Rimuovi tutti gli elementi da un nemico (alla morte)
  void rimuoviElementi(String nemicoId) {
    _elementiAttivi.remove(nemicoId);
  }

  /// Ottieni gli elementi attivi su un nemico
  List<ElementType> getElementiAttivi(String nemicoId) {
    return _elementiAttivi[nemicoId]
        ?.where((e) => !e.scaduto)
        .map((e) => e.tipo)
        .toList() ?? [];
  }

  /// Ottieni tutte le reazioni possibili
  static List<ReazioneElementale> get reazioni => _reazioni;

  /// Pulisci tutti i dati
  void pulisci() {
    _elementiAttivi.clear();
  }
}

/// Elemento applicato a un nemico con timer di scadenza
class _ElementoApplicato {
  final ElementType tipo;
  final DateTime scadenza;

  _ElementoApplicato({required this.tipo, required this.scadenza});

  bool get scaduto => DateTime.now().isAfter(scadenza);
}

/// Buff/Debuff applicabile al player o ai nemici
class StatusEffect {
  final String id;
  final String nome;
  final StatusEffectType tipo;
  final double valore; // percentuale o valore assoluto
  double durataRimanente; // secondi
  final int coloreHex;
  final bool positivo; // true = buff, false = debuff

  StatusEffect({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.valore,
    required this.durataRimanente,
    required this.coloreHex,
    this.positivo = false,
  });

  bool get scaduto => durataRimanente <= 0;
}

/// Tipi di status effect
enum StatusEffectType {
  /// Aumenta il danno inflitto
  bonusDanno,
  /// Riduce il danno inflitto
  malusDanno,
  /// Aumenta la velocità di movimento
  bonusVelocita,
  /// Riduce la velocità di movimento
  rallentamento,
  /// Rigenera HP nel tempo
  rigenerazioneHP,
  /// Perde HP nel tempo (DOT)
  dannoNelTempo,
  /// Aumenta la difesa
  bonusDifesa,
  /// Riduce la difesa
  malusDifesa,
  /// Aumenta il critical rate
  bonusCritico,
  /// Aumenta l'EXP guadagnata
  bonusExp,
  /// Aumenta l'oro guadagnato
  bonusOro,
  /// Aumenta il drop rate
  bonusDropRate,
  /// Invulnerabilità
  invulnerabile,
  /// Stordimento (non può agire)
  stordimento,
  /// Silenzio (non può usare abilità)
  silenzio,
  /// Cecità (range ridotto)
  cecita,
  /// Confusione (movimenti invertiti)
  confusione,
  /// Aura che danneggia i nemici vicini
  auraDanno,
  /// Scudo che assorbe danni
  scudo,
  /// Riflette una percentuale di danni
  riflessione,
}

/// Sistema di gestione dei buff/debuff
class StatusEffectManager {
  final List<StatusEffect> _effettiAttivi = [];

  /// Aggiungi un effetto
  void aggiungi(StatusEffect effetto) {
    // Controlla se lo stesso effetto è già attivo
    final esistente = _effettiAttivi.where((e) => e.id == effetto.id).toList();
    if (esistente.isNotEmpty) {
      // Rinnova la durata
      esistente.first.durataRimanente = effetto.durataRimanente;
      return;
    }

    _effettiAttivi.add(effetto);
    dev.log('[STATUS] Effetto aggiunto: ${effetto.nome} (${effetto.durataRimanente}s)');
  }

  /// Aggiorna tutti gli effetti (chiamato ogni frame)
  void update(double dt) {
    for (final effetto in _effettiAttivi) {
      effetto.durataRimanente -= dt;
    }
    _effettiAttivi.removeWhere((e) => e.scaduto);
  }

  /// Rimuovi un effetto specifico
  void rimuovi(String id) {
    _effettiAttivi.removeWhere((e) => e.id == id);
  }

  /// Calcola il moltiplicatore totale per un tipo di effetto
  double getMoltiplicatore(StatusEffectType tipo) {
    double totale = 1.0;
    for (final effetto in _effettiAttivi) {
      if (effetto.tipo == tipo) {
        totale *= (1.0 + effetto.valore);
      }
    }
    return totale;
  }

  /// Controlla se un tipo di effetto è attivo
  bool haEffetto(StatusEffectType tipo) {
    return _effettiAttivi.any((e) => e.tipo == tipo && !e.scaduto);
  }

  /// Ottieni tutti gli effetti attivi
  List<StatusEffect> get effettiAttivi => List.unmodifiable(_effettiAttivi);

  /// Ottieni solo i buff attivi
  List<StatusEffect> get buff =>
      _effettiAttivi.where((e) => e.positivo).toList();

  /// Ottieni solo i debuff attivi
  List<StatusEffect> get debuff =>
      _effettiAttivi.where((e) => !e.positivo).toList();

  /// Pulisci tutti gli effetti
  void pulisci() {
    _effettiAttivi.clear();
  }
}
