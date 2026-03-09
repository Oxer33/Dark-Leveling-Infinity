/// Sistema Quest di Dark Leveling Infinity
/// Gestisce missioni giornaliere, principali e secondarie
library;

import 'dart:developer' as dev;
import '../../data/models/quest_data.dart';
import '../../data/models/player_data.dart';

/// Sistema di gestione delle quest
class QuestSystem {
  // Quest attive
  final List<QuestData> _questAttive = [];
  final List<QuestData> _questCompletate = [];

  // Timer per le quest giornaliere
  DateTime? _ultimoResetGiornaliero;

  /// Inizializza il sistema quest con le quest di default
  void inizializza() {
    dev.log('[QUEST] Inizializzazione sistema quest...');
    _generaQuestGiornaliere();
    _generaQuestPrincipali();
  }

  /// Aggiorna il sistema quest ogni frame
  void update(double dt, PlayerData playerData) {
    // Controlla se è ora di resettare le quest giornaliere
    _controllaResetGiornaliero();

    // Controlla progresso quest
    for (final quest in _questAttive) {
      if (quest.stato == QuestStatus.inCorso) {
        if (quest.tuttiObiettiviCompletati) {
          quest.stato = QuestStatus.completata;
          dev.log('[QUEST] Quest completata: ${quest.titolo}');
        }
      }
    }
  }

  /// Aggiorna il progresso di un obiettivo quest
  void aggiornaProgresso(QuestObjectiveType tipo, {String? targetId, int quantita = 1}) {
    for (final quest in _questAttive) {
      if (quest.stato != QuestStatus.inCorso) continue;

      for (final obiettivo in quest.obiettivi) {
        if (obiettivo.tipo == tipo) {
          if (targetId != null && obiettivo.targetId != null && obiettivo.targetId != targetId) {
            continue;
          }
          obiettivo.quantitaAttuale += quantita;
        }
      }
    }
  }

  /// Riscuoti la ricompensa di una quest completata
  QuestReward? riscuotiRicompensa(String questId, PlayerData playerData) {
    final quest = _questAttive.firstWhere(
      (q) => q.id == questId && q.stato == QuestStatus.completata,
      orElse: () => QuestData(
        id: '', titolo: '', descrizione: '',
        tipo: QuestType.secondaria,
        obiettivi: [],
        ricompensa: const QuestReward(),
      ),
    );

    if (quest.id.isEmpty) return null;

    // Applica ricompense
    playerData.aggiungiEsperienza(quest.ricompensa.esperienza.toDouble());
    playerData.oro += quest.ricompensa.oro;
    playerData.gemme += quest.ricompensa.gemme;

    quest.stato = QuestStatus.riscossa;
    _questAttive.remove(quest);
    _questCompletate.add(quest);

    dev.log('[QUEST] Ricompensa riscossa: ${quest.titolo}');
    return quest.ricompensa;
  }

  /// Ottieni le quest attive
  List<QuestData> get questAttive => List.unmodifiable(_questAttive);

  /// Ottieni le quest giornaliere
  List<QuestData> get questGiornaliere =>
      _questAttive.where((q) => q.tipo == QuestType.giornaliera).toList();

  /// Ottieni le quest principali
  List<QuestData> get questPrincipali =>
      _questAttive.where((q) => q.tipo == QuestType.principale).toList();

  // --- Generazione Quest ---

  /// Genera le quest giornaliere
  void _generaQuestGiornaliere() {
    dev.log('[QUEST] Generazione quest giornaliere...');

    _questAttive.addAll([
      QuestData(
        id: 'daily_uccidi_50',
        titolo: 'Caccia Giornaliera',
        descrizione: 'Sconfiggi 50 nemici in qualsiasi dungeon.',
        tipo: QuestType.giornaliera,
        stato: QuestStatus.inCorso,
        obiettivi: [
          QuestObjective(
            id: 'obj_uccidi_50',
            descrizione: 'Sconfiggi 50 nemici',
            tipo: QuestObjectiveType.uccidiNemici,
            quantitaRichiesta: 50,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 500, oro: 200, gemme: 5),
        messaggioSistema: 'Quest giornaliera: Sconfiggi 50 nemici.',
      ),
      QuestData(
        id: 'daily_gate_3',
        titolo: 'Esploratore di Gate',
        descrizione: 'Completa 3 gate di qualsiasi rango.',
        tipo: QuestType.giornaliera,
        stato: QuestStatus.inCorso,
        obiettivi: [
          QuestObjective(
            id: 'obj_gate_3',
            descrizione: 'Completa 3 gate',
            tipo: QuestObjectiveType.completaGate,
            quantitaRichiesta: 3,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 800, oro: 300, gemme: 10),
        messaggioSistema: 'Quest giornaliera: Completa 3 gate.',
      ),
      QuestData(
        id: 'daily_combo_20',
        titolo: 'Maestro della Combo',
        descrizione: 'Raggiungi una combo di 20 colpi.',
        tipo: QuestType.giornaliera,
        stato: QuestStatus.inCorso,
        obiettivi: [
          QuestObjective(
            id: 'obj_combo_20',
            descrizione: 'Raggiungi combo 20',
            tipo: QuestObjectiveType.raggiungiCombo,
            quantitaRichiesta: 20,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 300, oro: 150, gemme: 3),
        messaggioSistema: 'Quest giornaliera: Raggiungi combo 20.',
      ),
      QuestData(
        id: 'daily_ombre_5',
        titolo: 'Collezionista di Ombre',
        descrizione: 'Estrai 5 ombre da nemici sconfitti.',
        tipo: QuestType.giornaliera,
        stato: QuestStatus.inCorso,
        obiettivi: [
          QuestObjective(
            id: 'obj_ombre_5',
            descrizione: 'Estrai 5 ombre',
            tipo: QuestObjectiveType.estraiOmbre,
            quantitaRichiesta: 5,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 600, oro: 250, gemme: 8),
        messaggioSistema: 'Quest giornaliera: Estrai 5 ombre.',
      ),
    ]);

    _ultimoResetGiornaliero = DateTime.now();
  }

  /// Genera le quest della storia principale
  void _generaQuestPrincipali() {
    dev.log('[QUEST] Generazione quest principali...');

    _questAttive.addAll([
      QuestData(
        id: 'main_01',
        titolo: 'Il Risveglio',
        descrizione: 'Completa il tuo primo Gate E per scoprire il potere nascosto dentro di te.',
        tipo: QuestType.principale,
        stato: QuestStatus.inCorso,
        obiettivi: [
          QuestObjective(
            id: 'obj_main_01',
            descrizione: 'Completa un Gate E',
            tipo: QuestObjectiveType.completaGate,
            quantitaRichiesta: 1,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 1000, oro: 500, gemme: 20),
        messaggioSistema: '[SISTEMA] Una nuova quest è stata assegnata: Il Risveglio.',
      ),
      QuestData(
        id: 'main_02',
        titolo: 'Il Potere delle Ombre',
        descrizione: 'Estrai la tua prima ombra e scopri il potere dell\'Estrazione.',
        tipo: QuestType.principale,
        stato: QuestStatus.bloccata,
        livelloRichiesto: 5,
        questPrerequisito: 'main_01',
        obiettivi: [
          QuestObjective(
            id: 'obj_main_02',
            descrizione: 'Estrai la tua prima ombra',
            tipo: QuestObjectiveType.estraiOmbre,
            quantitaRichiesta: 1,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 2000, oro: 1000, gemme: 30),
        messaggioSistema: '[SISTEMA] Capacità sbloccata: Estrazione dell\'Ombra.',
      ),
      QuestData(
        id: 'main_03',
        titolo: 'Rango D',
        descrizione: 'Raggiungi il livello 10 e dimostra di essere degno del rango D.',
        tipo: QuestType.principale,
        stato: QuestStatus.bloccata,
        livelloRichiesto: 10,
        questPrerequisito: 'main_02',
        obiettivi: [
          QuestObjective(
            id: 'obj_main_03',
            descrizione: 'Raggiungi livello 10',
            tipo: QuestObjectiveType.raggiungiLivello,
            quantitaRichiesta: 10,
          ),
        ],
        ricompensa: const QuestReward(esperienza: 3000, oro: 1500, gemme: 50, puntiAbilita: 3),
        messaggioSistema: '[SISTEMA] Promozione a Rango D disponibile.',
      ),
    ]);
  }

  /// Controlla se è necessario resettare le quest giornaliere
  void _controllaResetGiornaliero() {
    if (_ultimoResetGiornaliero == null) return;

    final ora = DateTime.now();
    final differenza = ora.difference(_ultimoResetGiornaliero!);

    if (differenza.inHours >= 24) {
      dev.log('[QUEST] Reset quest giornaliere!');
      _questAttive.removeWhere((q) => q.tipo == QuestType.giornaliera);
      _generaQuestGiornaliere();
    }
  }

  /// Serializzazione per il salvataggio
  List<Map<String, dynamic>> toJson() {
    return _questAttive.map((q) => q.toJson()).toList();
  }

  /// Deserializzazione dal salvataggio
  void fromJson(List<dynamic> json) {
    _questAttive.clear();
    for (final q in json) {
      _questAttive.add(QuestData.fromJson(q as Map<String, dynamic>));
    }
  }
}
