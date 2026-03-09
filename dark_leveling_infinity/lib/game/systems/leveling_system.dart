/// Sistema di livellamento di Dark Leveling Infinity
/// Gestisce la progressione del player, i punti stat e le abilità
library;

import 'dart:developer' as dev;
import '../../data/models/player_data.dart';

/// Dati di un'abilità sbloccabile
class SkillNode {
  final String id;
  final String nome;
  final String descrizione;
  final int livelloRichiesto;
  final int costo; // punti abilità
  final String? prerequisitoId;
  final SkillCategory categoria;
  bool sbloccata;

  SkillNode({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.livelloRichiesto,
    this.costo = 1,
    this.prerequisitoId,
    required this.categoria,
    this.sbloccata = false,
  });
}

/// Categoria dell'abilità
enum SkillCategory { combattimento, ombre, sopravvivenza, passiva }

/// Sistema di livellamento e skill tree
class LevelingSystem {
  // Skill tree completo
  final List<SkillNode> _skillTree = [];

  LevelingSystem() {
    _inizializzaSkillTree();
  }

  /// Inizializza l'albero delle abilità
  void _inizializzaSkillTree() {
    dev.log('[LEVELING] Inizializzazione skill tree...');

    _skillTree.addAll([
      // === COMBATTIMENTO ===
      SkillNode(id: 'fendente', nome: 'Fendente', descrizione: 'Taglio potente in avanti con danno aumentato del 100%.', livelloRichiesto: 1, categoria: SkillCategory.combattimento),
      SkillNode(id: 'colpo_rotante', nome: 'Colpo Rotante', descrizione: 'Attacco circolare a 360° che colpisce tutti i nemici vicini.', livelloRichiesto: 5, prerequisitoId: 'fendente', categoria: SkillCategory.combattimento),
      SkillNode(id: 'carica_oscura', nome: 'Carica Oscura', descrizione: 'Dash in avanti attraverso i nemici infliggendo danni.', livelloRichiesto: 10, prerequisitoId: 'colpo_rotante', categoria: SkillCategory.combattimento),
      SkillNode(id: 'pioggia_lame', nome: 'Pioggia di Lame', descrizione: 'Lame oscure cadono dal cielo colpendo un\'area.', livelloRichiesto: 20, prerequisitoId: 'carica_oscura', categoria: SkillCategory.combattimento),
      SkillNode(id: 'lama_oscura', nome: 'Lama Oscura', descrizione: 'Proiettile di energia oscura a lungo raggio.', livelloRichiesto: 15, prerequisitoId: 'fendente', categoria: SkillCategory.combattimento),
      SkillNode(id: 'nova_ombra', nome: 'Nova di Ombra', descrizione: 'Esplosione di energia oscura che danneggia tutti i nemici vicini.', livelloRichiesto: 30, prerequisitoId: 'lama_oscura', categoria: SkillCategory.combattimento),
      SkillNode(id: 'pugno_fantasma', nome: 'Pugno Fantasma', descrizione: 'Colpo devastante potenziato dall\'energia delle ombre.', livelloRichiesto: 25, prerequisitoId: 'carica_oscura', categoria: SkillCategory.combattimento),
      SkillNode(id: 'urlo_guerra', nome: 'Urlo di Guerra', descrizione: 'Stordisce tutti i nemici nel raggio per 2 secondi.', livelloRichiesto: 35, prerequisitoId: 'nova_ombra', costo: 2, categoria: SkillCategory.combattimento),
      SkillNode(id: 'danza_lame', nome: 'Danza delle Lame', descrizione: 'Serie di 10 colpi rapidi automatici.', livelloRichiesto: 50, prerequisitoId: 'pugno_fantasma', costo: 3, categoria: SkillCategory.combattimento),
      SkillNode(id: 'giudizio_ombra', nome: 'Giudizio dell\'Ombra', descrizione: 'Attacco definitivo che infligge danni devastanti in un\'area enorme.', livelloRichiesto: 100, prerequisitoId: 'danza_lame', costo: 5, categoria: SkillCategory.combattimento),

      // === OMBRE ===
      SkillNode(id: 'estrazione', nome: 'Estrazione Ombra', descrizione: 'Permette di estrarre le ombre dei nemici sconfitti.', livelloRichiesto: 5, categoria: SkillCategory.ombre),
      SkillNode(id: 'scambio_ombre', nome: 'Scambio Ombre', descrizione: 'Teletrasportati alla posizione di un\'ombra evocata.', livelloRichiesto: 15, prerequisitoId: 'estrazione', categoria: SkillCategory.ombre),
      SkillNode(id: 'autorita_sovrano', nome: 'Autorità del Sovrano', descrizione: 'Usa la telecinesi per lanciare i nemici.', livelloRichiesto: 25, prerequisitoId: 'scambio_ombre', costo: 2, categoria: SkillCategory.ombre),
      SkillNode(id: 'dominio_ombra', nome: 'Dominio dell\'Ombra', descrizione: 'Potenzia tutte le ombre evocate del 50%.', livelloRichiesto: 40, prerequisitoId: 'autorita_sovrano', costo: 2, categoria: SkillCategory.ombre),
      SkillNode(id: 'estrazione_massa', nome: 'Estrazione di Massa', descrizione: 'Estrai le ombre di tutti i nemici sconfitti nell\'area.', livelloRichiesto: 60, prerequisitoId: 'dominio_ombra', costo: 3, categoria: SkillCategory.ombre),
      SkillNode(id: 'esercito_infinito', nome: 'Esercito Infinito', descrizione: 'Raddoppia il numero massimo di ombre evocabili.', livelloRichiesto: 80, prerequisitoId: 'estrazione_massa', costo: 5, categoria: SkillCategory.ombre),
      SkillNode(id: 'monarca_ombre', nome: 'Monarca delle Ombre', descrizione: 'Sblocca il potere supremo: evoca tutte le ombre contemporaneamente.', livelloRichiesto: 200, prerequisitoId: 'esercito_infinito', costo: 10, categoria: SkillCategory.ombre),

      // === SOPRAVVIVENZA ===
      SkillNode(id: 'rigenerazione', nome: 'Rigenerazione', descrizione: 'Aumenta la rigenerazione HP del 100%.', livelloRichiesto: 3, categoria: SkillCategory.sopravvivenza),
      SkillNode(id: 'pelle_acciaio', nome: 'Pelle d\'Acciaio', descrizione: 'Aumenta la difesa del 25%.', livelloRichiesto: 8, prerequisitoId: 'rigenerazione', categoria: SkillCategory.sopravvivenza),
      SkillNode(id: 'schivata_ombra', nome: 'Schivata d\'Ombra', descrizione: 'Riduce il cooldown della schivata del 30%.', livelloRichiesto: 12, prerequisitoId: 'pelle_acciaio', categoria: SkillCategory.sopravvivenza),
      SkillNode(id: 'vampirismo', nome: 'Vampirismo', descrizione: 'Recupera il 5% dei danni inflitti come HP.', livelloRichiesto: 20, prerequisitoId: 'schivata_ombra', costo: 2, categoria: SkillCategory.sopravvivenza),
      SkillNode(id: 'volonta_ferro', nome: 'Volontà di Ferro', descrizione: 'Sopravvivi a un colpo letale con 1 HP (cooldown 60s).', livelloRichiesto: 50, prerequisitoId: 'vampirismo', costo: 3, categoria: SkillCategory.sopravvivenza),
      SkillNode(id: 'immortalita', nome: 'Pseudo-Immortalità', descrizione: 'Riduci tutti i danni ricevuti del 20%.', livelloRichiesto: 100, prerequisitoId: 'volonta_ferro', costo: 5, categoria: SkillCategory.sopravvivenza),

      // === PASSIVE ===
      SkillNode(id: 'occhio_cacciatore', nome: 'Occhio del Cacciatore', descrizione: 'Rivela le debolezze dei nemici (+10% critico).', livelloRichiesto: 5, categoria: SkillCategory.passiva),
      SkillNode(id: 'aura_terrore', nome: 'Aura del Terrore', descrizione: 'I nemici deboli fuggono dalla tua presenza.', livelloRichiesto: 15, prerequisitoId: 'occhio_cacciatore', categoria: SkillCategory.passiva),
      SkillNode(id: 'istinto_assassino', nome: 'Istinto Assassino', descrizione: 'Danno critico aumentato del 50%.', livelloRichiesto: 25, prerequisitoId: 'occhio_cacciatore', costo: 2, categoria: SkillCategory.passiva),
      SkillNode(id: 'cacciatore_esperto', nome: 'Cacciatore Esperto', descrizione: 'EXP guadagnata aumentata del 30%.', livelloRichiesto: 10, categoria: SkillCategory.passiva),
      SkillNode(id: 'fortuna_cacciatore', nome: 'Fortuna del Cacciatore', descrizione: 'Drop rate aumentato del 25%.', livelloRichiesto: 20, prerequisitoId: 'cacciatore_esperto', categoria: SkillCategory.passiva),
      SkillNode(id: 'senso_pericolo', nome: 'Senso del Pericolo', descrizione: 'Avverte della presenza di trappole e nemici nascosti.', livelloRichiesto: 30, prerequisitoId: 'aura_terrore', costo: 2, categoria: SkillCategory.passiva),
    ]);

    dev.log('[LEVELING] ${_skillTree.length} abilità nell\'albero');
  }

  /// Sblocca un'abilità
  bool sbloccaAbilita(String skillId, PlayerData playerData) {
    final skill = _skillTree.firstWhere(
      (s) => s.id == skillId,
      orElse: () => SkillNode(id: '', nome: '', descrizione: '', livelloRichiesto: 0, categoria: SkillCategory.combattimento),
    );

    if (skill.id.isEmpty) return false;
    if (skill.sbloccata) return false;

    // Controlla livello
    if (playerData.livello < skill.livelloRichiesto) {
      dev.log('[LEVELING] Livello insufficiente per ${skill.nome}');
      return false;
    }

    // Controlla prerequisito
    if (skill.prerequisitoId != null) {
      final prereq = _skillTree.firstWhere(
        (s) => s.id == skill.prerequisitoId,
        orElse: () => SkillNode(id: '', nome: '', descrizione: '', livelloRichiesto: 0, categoria: SkillCategory.combattimento),
      );
      if (!prereq.sbloccata) {
        dev.log('[LEVELING] Prerequisito ${prereq.nome} non sbloccato');
        return false;
      }
    }

    // Controlla punti abilità
    if (playerData.puntiAbilitaDisponibili < skill.costo) {
      dev.log('[LEVELING] Punti abilità insufficienti');
      return false;
    }

    // Sblocca!
    skill.sbloccata = true;
    playerData.puntiAbilitaDisponibili -= skill.costo;
    playerData.abilitaSbloccate.add(skillId);

    dev.log('[LEVELING] Abilità sbloccata: ${skill.nome}!');
    return true;
  }

  /// Assegna un punto stat
  bool assegnaPuntoStat(String stat, PlayerData playerData) {
    if (playerData.puntiStatDisponibili <= 0) return false;

    switch (stat) {
      case 'forza':
        playerData.stats.forza++;
        break;
      case 'agilita':
        playerData.stats.agilita++;
        break;
      case 'vitalita':
        playerData.stats.vitalita++;
        break;
      case 'intelligenza':
        playerData.stats.intelligenza++;
        break;
      case 'percezione':
        playerData.stats.percezione++;
        break;
      default:
        return false;
    }

    playerData.puntiStatDisponibili--;
    dev.log('[LEVELING] Punto stat assegnato a $stat');
    return true;
  }

  /// Ottieni l'albero delle abilità
  List<SkillNode> get skillTree => List.unmodifiable(_skillTree);

  /// Ottieni abilità per categoria
  List<SkillNode> getAbilitaPerCategoria(SkillCategory categoria) {
    return _skillTree.where((s) => s.categoria == categoria).toList();
  }

  /// Ottieni abilità sbloccate
  List<SkillNode> get abilitaSbloccate {
    return _skillTree.where((s) => s.sbloccata).toList();
  }

  /// Controlla se un'abilità è sbloccata
  bool isAbilitaSbloccata(String skillId) {
    return _skillTree.any((s) => s.id == skillId && s.sbloccata);
  }
}
