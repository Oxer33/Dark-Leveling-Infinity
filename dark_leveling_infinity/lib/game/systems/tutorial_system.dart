/// Sistema Tutorial interattivo per Dark Leveling Infinity
/// Guida il giocatore attraverso le meccaniche di base con popup contestuali
library;

import 'dart:developer' as dev;

/// Step del tutorial con testo e condizione di completamento
class TutorialStep {
  final String id;
  final String titolo;
  final String descrizione;
  final String? icona;
  final TutorialTrigger trigger;
  bool completato;

  TutorialStep({
    required this.id,
    required this.titolo,
    required this.descrizione,
    this.icona,
    required this.trigger,
    this.completato = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'completato': completato,
  };
}

/// Trigger per mostrare un passo del tutorial
enum TutorialTrigger {
  primoAvvio,          // All'inizio del gioco
  primoMovimento,      // Quando il player si muove per la prima volta
  primoNemico,         // Quando incontra il primo nemico
  primoAttacco,        // Quando attacca per la prima volta
  primaSchivata,       // Quando schiva per la prima volta
  primoLoot,           // Quando raccoglie il primo loot
  primaAbilita,        // Quando usa la prima abilità
  primoLevelUp,        // Al primo level up
  primaEstrazione,     // Quando tenta la prima estrazione ombra
  primaEvocazione,     // Quando evoca la prima ombra
  primoBoss,           // Quando incontra il primo boss
  primoGateD,          // Quando sblocca il Gate D
  primoEquipaggiamento, // Quando equipaggia il primo oggetto
  primaQuest,          // Quando completa la prima quest
  primoMarket,         // Quando apre il market
}

/// Sistema di tutorial progressivo e contestuale
class TutorialSystem {
  // Tutti gli step del tutorial
  final List<TutorialStep> _steps = [];
  
  // Step corrente da mostrare (null = nessun tutorial attivo)
  TutorialStep? _stepCorrente;
  
  // Tutorial completato?
  bool _tutorialCompletato = false;
  
  // Callback per mostrare il popup
  Function(TutorialStep)? onMostraStep;
  Function()? onNascondiStep;

  TutorialSystem() {
    _inizializzaSteps();
  }

  /// Inizializza tutti gli step del tutorial
  void _inizializzaSteps() {
    _steps.addAll([
      TutorialStep(
        id: 'benvenuto',
        titolo: 'Benvenuto, Cacciatore!',
        descrizione: 'Sei stato risvegliato come Cacciatore. Il tuo potere è ancora debole, ma crescerà. Usa il JOYSTICK a sinistra per muoverti.',
        trigger: TutorialTrigger.primoAvvio,
      ),
      TutorialStep(
        id: 'movimento',
        titolo: 'Movimento',
        descrizione: 'Ottimo! Trascina il joystick per muoverti in qualsiasi direzione. Esplora il dungeon e trova i nemici.',
        trigger: TutorialTrigger.primoMovimento,
      ),
      TutorialStep(
        id: 'combattimento',
        titolo: 'Combattimento',
        descrizione: 'Un nemico! Premi il pulsante ATTACCO (⚡) a destra per attaccare. Colpisci i nemici per guadagnare esperienza!',
        trigger: TutorialTrigger.primoNemico,
      ),
      TutorialStep(
        id: 'schivata',
        titolo: 'Schivata',
        descrizione: 'Premi il pulsante SCHIVA (➡➡) per evitare gli attacchi nemici. Sei invulnerabile durante la schivata!',
        trigger: TutorialTrigger.primoAttacco,
      ),
      TutorialStep(
        id: 'combo',
        titolo: 'Sistema Combo',
        descrizione: 'Colpisci rapidamente per aumentare la COMBO! Più alta la combo, più danni infliggi. Non smettere di attaccare!',
        trigger: TutorialTrigger.primaSchivata,
      ),
      TutorialStep(
        id: 'loot',
        titolo: 'Bottino',
        descrizione: 'I nemici sconfitti lasciano oggetti e oro. Gli oggetti hanno diverse rarità: da Comune a Divino!',
        trigger: TutorialTrigger.primoLoot,
      ),
      TutorialStep(
        id: 'abilita',
        titolo: 'Abilità',
        descrizione: 'Usa i pulsanti Q1-Q4 per attivare le tue abilità speciali. Ogni abilità costa Mana (barra blu) e ha un cooldown.',
        trigger: TutorialTrigger.primaAbilita,
      ),
      TutorialStep(
        id: 'levelup',
        titolo: 'Livello Su!',
        descrizione: 'Complimenti! Assegna i punti statistiche per diventare più forte. Forza=Danno, Agilità=Velocità, Vitalità=HP, Intelligenza=Mana, Percezione=Critico.',
        trigger: TutorialTrigger.primoLevelUp,
      ),
      TutorialStep(
        id: 'estrazione',
        titolo: 'Estrazione dell\'Ombra',
        descrizione: '[SISTEMA] Capacità sbloccata: Estrazione dell\'Ombra. Dopo aver sconfitto un nemico, puoi tentare di estrarne l\'ombra per il tuo esercito!',
        trigger: TutorialTrigger.primaEstrazione,
      ),
      TutorialStep(
        id: 'evocazione',
        titolo: 'Esercito delle Ombre',
        descrizione: 'Premi il pulsante OMBRE (👥) per evocare le tue ombre in battaglia. Le ombre combattono autonomamente al tuo fianco!',
        trigger: TutorialTrigger.primaEvocazione,
      ),
      TutorialStep(
        id: 'boss',
        titolo: 'Boss Fight!',
        descrizione: 'Un potente nemico! I boss hanno fasi multiple e attacchi speciali. Studia i loro pattern e schiva al momento giusto!',
        trigger: TutorialTrigger.primoBoss,
      ),
      TutorialStep(
        id: 'gate_d',
        titolo: 'Nuovo Rango!',
        descrizione: 'Hai raggiunto il Rango D! Ora puoi accedere ai Gate D con nemici più forti e ricompense migliori. Il tuo viaggio è appena iniziato...',
        trigger: TutorialTrigger.primoGateD,
      ),
      TutorialStep(
        id: 'equipaggiamento',
        titolo: 'Equipaggiamento',
        descrizione: 'Equipaggia armi e armature per aumentare le tue statistiche. Controlla l\'inventario per gestire i tuoi oggetti!',
        trigger: TutorialTrigger.primoEquipaggiamento,
      ),
      TutorialStep(
        id: 'quest',
        titolo: 'Missioni',
        descrizione: 'Completa le missioni giornaliere per guadagnare ricompense extra! Le missioni si resettano ogni 24 ore.',
        trigger: TutorialTrigger.primaQuest,
      ),
      TutorialStep(
        id: 'market',
        titolo: 'Negozio',
        descrizione: 'Nel Market puoi acquistare gemme, pass e oggetti speciali per potenziare il tuo cacciatore!',
        trigger: TutorialTrigger.primoMarket,
      ),
    ]);

    dev.log('[TUTORIAL] ${_steps.length} step di tutorial inizializzati');
  }

  /// Triggera un evento e controlla se mostrare un tutorial
  void triggerEvento(TutorialTrigger trigger) {
    if (_tutorialCompletato) return;

    // Cerca lo step corrispondente
    for (final step in _steps) {
      if (step.trigger == trigger && !step.completato) {
        _mostraStep(step);
        return;
      }
    }
  }

  /// Mostra uno step del tutorial
  void _mostraStep(TutorialStep step) {
    _stepCorrente = step;
    dev.log('[TUTORIAL] Mostrando: ${step.titolo}');
    onMostraStep?.call(step);
  }

  /// Completa lo step corrente
  void completaStepCorrente() {
    if (_stepCorrente != null) {
      _stepCorrente!.completato = true;
      dev.log('[TUTORIAL] Completato: ${_stepCorrente!.titolo}');
      _stepCorrente = null;
      onNascondiStep?.call();

      // Controlla se tutti gli step sono completati
      if (_steps.every((s) => s.completato)) {
        _tutorialCompletato = true;
        dev.log('[TUTORIAL] Tutorial completato!');
      }
    }
  }

  /// Step corrente attivo
  TutorialStep? get stepCorrente => _stepCorrente;

  /// Tutorial completato?
  bool get completato => _tutorialCompletato;

  /// Serializzazione
  List<Map<String, dynamic>> toJson() {
    return _steps.map((s) => s.toJson()).toList();
  }

  /// Deserializzazione
  void fromJson(List<dynamic> json) {
    for (final data in json) {
      final id = (data as Map<String, dynamic>)['id'] as String;
      final completato = data['completato'] as bool;
      for (final step in _steps) {
        if (step.id == id) {
          step.completato = completato;
        }
      }
    }

    _tutorialCompletato = _steps.every((s) => s.completato);
  }
}
