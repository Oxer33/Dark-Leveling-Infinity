/// Definizioni di tutti i 100 nemici del gioco
/// Ogni nemico ha meccaniche uniche e AI specifica
library;

import '../models/enemy_data.dart';
import '../../core/constants/game_constants.dart';

/// Database di tutti i nemici del gioco
/// Organizzati per rango del Gate in cui appaiono
class EnemyDatabase {
  /// Lista completa dei 100 nemici
  static const List<EnemyData> tuttiINemici = [
    // ============================================
    // GATE E - Nemici base (1-10)
    // ============================================
    EnemyData(
      id: 'goblin_base', nome: 'Goblin', descrizione: 'Un piccolo goblin aggressivo con un coltello arrugginito.',
      livelloBase: 1, saluteBase: 30, dannoBase: 5, difesaBase: 2, velocitaBase: 60,
      rangeAttacco: 32, cooldownAttacco: 1.0, aiType: EnemyAIType.melee,
      rangoMinimo: GateRank.e, expRicompensa: 10, oroRicompensa: 5, spriteKey: 'goblin_base',
    ),
    EnemyData(
      id: 'slime_verde', nome: 'Slime Verde', descrizione: 'Una massa gelatinosa che si divide quando colpita.',
      livelloBase: 1, saluteBase: 20, dannoBase: 3, difesaBase: 1, velocitaBase: 30,
      rangeAttacco: 24, cooldownAttacco: 1.5, aiType: EnemyAIType.splitter,
      rangoMinimo: GateRank.e, expRicompensa: 8, oroRicompensa: 3, spriteKey: 'slime_verde',
    ),
    EnemyData(
      id: 'scheletro_base', nome: 'Scheletro', descrizione: 'Un guerriero non morto con spada e scudo.',
      livelloBase: 2, saluteBase: 40, dannoBase: 8, difesaBase: 5, velocitaBase: 50,
      rangeAttacco: 36, cooldownAttacco: 1.2, aiType: EnemyAIType.melee,
      rangoMinimo: GateRank.e, expRicompensa: 15, oroRicompensa: 8, spriteKey: 'scheletro_base',
    ),
    EnemyData(
      id: 'pipistrello', nome: 'Pipistrello Oscuro', descrizione: 'Vola veloce e morde per succhiare sangue.',
      livelloBase: 2, saluteBase: 15, dannoBase: 6, difesaBase: 1, velocitaBase: 100,
      rangeAttacco: 28, cooldownAttacco: 0.8, aiType: EnemyAIType.flyer,
      rangoMinimo: GateRank.e, expRicompensa: 12, oroRicompensa: 4, spriteKey: 'pipistrello',
    ),
    EnemyData(
      id: 'ragno_piccolo', nome: 'Ragno Velenoso', descrizione: 'Un ragno che avvelena con i suoi morsi.',
      livelloBase: 3, saluteBase: 25, dannoBase: 4, difesaBase: 2, velocitaBase: 70,
      rangeAttacco: 28, cooldownAttacco: 1.0, aiType: EnemyAIType.poisoner,
      elemento: ElementType.poison, rangoMinimo: GateRank.e, expRicompensa: 14, oroRicompensa: 6, spriteKey: 'ragno_piccolo',
    ),
    EnemyData(
      id: 'lupo_grigio', nome: 'Lupo Grigio', descrizione: 'Un lupo veloce che attacca e fugge.',
      livelloBase: 3, saluteBase: 35, dannoBase: 10, difesaBase: 3, velocitaBase: 90,
      rangeAttacco: 32, cooldownAttacco: 0.9, aiType: EnemyAIType.hitAndRun,
      rangoMinimo: GateRank.e, expRicompensa: 18, oroRicompensa: 7, spriteKey: 'lupo_grigio',
    ),
    EnemyData(
      id: 'fungo_esplosivo', nome: 'Fungo Esplosivo', descrizione: 'Si avvicina e esplode causando danni ad area.',
      livelloBase: 4, saluteBase: 10, dannoBase: 25, difesaBase: 0, velocitaBase: 40,
      rangeAttacco: 48, cooldownAttacco: 0, aiType: EnemyAIType.kamikaze,
      rangoMinimo: GateRank.e, expRicompensa: 20, oroRicompensa: 10, spriteKey: 'fungo_esplosivo',
    ),
    EnemyData(
      id: 'goblin_arciere', nome: 'Goblin Arciere', descrizione: 'Un goblin che attacca a distanza con frecce.',
      livelloBase: 4, saluteBase: 20, dannoBase: 7, difesaBase: 1, velocitaBase: 55,
      rangeAttacco: 120, cooldownAttacco: 1.5, aiType: EnemyAIType.ranged,
      rangoMinimo: GateRank.e, expRicompensa: 16, oroRicompensa: 8, spriteKey: 'goblin_arciere',
    ),
    EnemyData(
      id: 'topo_gigante', nome: 'Topo Gigante', descrizione: 'Un roditore enorme che attacca in branco.',
      livelloBase: 1, saluteBase: 12, dannoBase: 4, difesaBase: 1, velocitaBase: 80,
      rangeAttacco: 24, cooldownAttacco: 0.7, aiType: EnemyAIType.melee,
      rangoMinimo: GateRank.e, expRicompensa: 6, oroRicompensa: 2, spriteKey: 'topo_gigante',
    ),
    EnemyData(
      id: 'fantasma_debole', nome: 'Fantasma Debole', descrizione: 'Uno spirito che si rende invisibile periodicamente.',
      livelloBase: 5, saluteBase: 28, dannoBase: 8, difesaBase: 0, velocitaBase: 65,
      rangeAttacco: 32, cooldownAttacco: 1.3, aiType: EnemyAIType.stealth,
      elemento: ElementType.dark, rangoMinimo: GateRank.e, expRicompensa: 22, oroRicompensa: 12, spriteKey: 'fantasma_debole',
    ),

    // ============================================
    // GATE D - Nemici intermedi (11-20)
    // ============================================
    EnemyData(
      id: 'orco_guerriero', nome: 'Orco Guerriero', descrizione: 'Un orco massiccio con una clava pesante.',
      livelloBase: 10, saluteBase: 80, dannoBase: 18, difesaBase: 10, velocitaBase: 45,
      rangeAttacco: 40, cooldownAttacco: 1.5, aiType: EnemyAIType.tank,
      rangoMinimo: GateRank.d, expRicompensa: 35, oroRicompensa: 15, spriteKey: 'orco_guerriero',
    ),
    EnemyData(
      id: 'mago_scheletro', nome: 'Mago Scheletro', descrizione: 'Lancia sfere di fuoco oscuro a distanza.',
      livelloBase: 12, saluteBase: 45, dannoBase: 22, difesaBase: 5, velocitaBase: 40,
      rangeAttacco: 150, cooldownAttacco: 2.0, aiType: EnemyAIType.ranged,
      elemento: ElementType.dark, rangoMinimo: GateRank.d, expRicompensa: 40, oroRicompensa: 20, spriteKey: 'mago_scheletro',
    ),
    EnemyData(
      id: 'lupo_ombra', nome: 'Lupo dell\'Ombra', descrizione: 'Un lupo avvolto nell\'oscurità che si teletrasporta.',
      livelloBase: 11, saluteBase: 55, dannoBase: 20, difesaBase: 6, velocitaBase: 110,
      rangeAttacco: 36, cooldownAttacco: 0.8, aiType: EnemyAIType.teleporter,
      elemento: ElementType.shadow, rangoMinimo: GateRank.d, expRicompensa: 38, oroRicompensa: 18, spriteKey: 'lupo_ombra',
    ),
    EnemyData(
      id: 'golem_pietra', nome: 'Golem di Pietra', descrizione: 'Un costrutto di pietra lento ma resistentissimo.',
      livelloBase: 14, saluteBase: 150, dannoBase: 15, difesaBase: 25, velocitaBase: 25,
      rangeAttacco: 44, cooldownAttacco: 2.5, aiType: EnemyAIType.tank,
      elemento: ElementType.earth, rangoMinimo: GateRank.d, expRicompensa: 50, oroRicompensa: 25, spriteKey: 'golem_pietra',
    ),
    EnemyData(
      id: 'serpente_ghiaccio', nome: 'Serpente di Ghiaccio', descrizione: 'Un serpente che congela tutto ciò che tocca.',
      livelloBase: 13, saluteBase: 50, dannoBase: 14, difesaBase: 8, velocitaBase: 75,
      rangeAttacco: 36, cooldownAttacco: 1.0, aiType: EnemyAIType.freezer,
      elemento: ElementType.ice, rangoMinimo: GateRank.d, expRicompensa: 42, oroRicompensa: 20, spriteKey: 'serpente_ghiaccio',
    ),
    EnemyData(
      id: 'necromante_minore', nome: 'Necromante Minore', descrizione: 'Evoca scheletri per combattere al suo posto.',
      livelloBase: 15, saluteBase: 40, dannoBase: 10, difesaBase: 4, velocitaBase: 35,
      rangeAttacco: 130, cooldownAttacco: 3.0, aiType: EnemyAIType.summoner,
      elemento: ElementType.dark, rangoMinimo: GateRank.d, expRicompensa: 55, oroRicompensa: 28, spriteKey: 'necromante_minore',
    ),
    EnemyData(
      id: 'elementale_fuoco', nome: 'Elementale di Fuoco', descrizione: 'Una creatura fatta di fiamme pure che brucia.',
      livelloBase: 14, saluteBase: 60, dannoBase: 20, difesaBase: 3, velocitaBase: 55,
      rangeAttacco: 80, cooldownAttacco: 1.2, aiType: EnemyAIType.burner,
      elemento: ElementType.fire, rangoMinimo: GateRank.d, expRicompensa: 45, oroRicompensa: 22, spriteKey: 'elementale_fuoco',
    ),
    EnemyData(
      id: 'pianta_carnivora', nome: 'Pianta Carnivora', descrizione: 'Crea trappole con le sue radici e spara spore.',
      livelloBase: 12, saluteBase: 70, dannoBase: 12, difesaBase: 8, velocitaBase: 0,
      rangeAttacco: 100, cooldownAttacco: 2.0, aiType: EnemyAIType.trapper,
      elemento: ElementType.poison, rangoMinimo: GateRank.d, expRicompensa: 35, oroRicompensa: 15, spriteKey: 'pianta_carnivora',
    ),
    EnemyData(
      id: 'vampiro_minore', nome: 'Vampiro Minore', descrizione: 'Assorbe vita con ogni attacco riuscito.',
      livelloBase: 15, saluteBase: 55, dannoBase: 16, difesaBase: 7, velocitaBase: 70,
      rangeAttacco: 32, cooldownAttacco: 1.0, aiType: EnemyAIType.vampiric,
      elemento: ElementType.dark, rangoMinimo: GateRank.d, expRicompensa: 48, oroRicompensa: 24, spriteKey: 'vampiro_minore',
    ),
    EnemyData(
      id: 'guardia_scudo', nome: 'Guardia con Scudo', descrizione: 'Riflette i danni con il suo scudo magico.',
      livelloBase: 13, saluteBase: 90, dannoBase: 10, difesaBase: 20, velocitaBase: 30,
      rangeAttacco: 36, cooldownAttacco: 1.8, aiType: EnemyAIType.reflector,
      rangoMinimo: GateRank.d, expRicompensa: 40, oroRicompensa: 20, spriteKey: 'guardia_scudo',
    ),

    // ============================================
    // GATE C - Nemici avanzati (21-35)
    // ============================================
    EnemyData(
      id: 'cavaliere_nero', nome: 'Cavaliere Nero', descrizione: 'Un cavaliere caduto con armatura nera pesante.',
      livelloBase: 25, saluteBase: 180, dannoBase: 35, difesaBase: 25, velocitaBase: 50,
      rangeAttacco: 44, cooldownAttacco: 1.3, aiType: EnemyAIType.melee,
      elemento: ElementType.dark, rangoMinimo: GateRank.c, expRicompensa: 80, oroRicompensa: 40, spriteKey: 'cavaliere_nero',
    ),
    EnemyData(
      id: 'mago_ghiaccio', nome: 'Mago del Ghiaccio', descrizione: 'Lancia incantesimi di ghiaccio ad area.',
      livelloBase: 27, saluteBase: 100, dannoBase: 45, difesaBase: 10, velocitaBase: 40,
      rangeAttacco: 180, cooldownAttacco: 2.5, aiType: EnemyAIType.areaMage,
      elemento: ElementType.ice, rangoMinimo: GateRank.c, expRicompensa: 90, oroRicompensa: 45, spriteKey: 'mago_ghiaccio',
    ),
    EnemyData(
      id: 'orco_sciamano', nome: 'Orco Sciamano', descrizione: 'Cura gli alleati e potenzia i loro attacchi.',
      livelloBase: 28, saluteBase: 90, dannoBase: 15, difesaBase: 12, velocitaBase: 35,
      rangeAttacco: 120, cooldownAttacco: 3.0, aiType: EnemyAIType.healer,
      rangoMinimo: GateRank.c, expRicompensa: 85, oroRicompensa: 42, spriteKey: 'orco_sciamano',
    ),
    EnemyData(
      id: 'minotauro', nome: 'Minotauro', descrizione: 'Carica il nemico con una forza devastante.',
      livelloBase: 30, saluteBase: 200, dannoBase: 40, difesaBase: 18, velocitaBase: 65,
      rangeAttacco: 48, cooldownAttacco: 1.5, aiType: EnemyAIType.berserker,
      rangoMinimo: GateRank.c, expRicompensa: 100, oroRicompensa: 50, spriteKey: 'minotauro', dimensione: 1.5,
    ),
    EnemyData(
      id: 'naga_guerriera', nome: 'Naga Guerriera', descrizione: 'Donna serpente con doppia spada e movimenti fluidi.',
      livelloBase: 26, saluteBase: 120, dannoBase: 30, difesaBase: 15, velocitaBase: 80,
      rangeAttacco: 40, cooldownAttacco: 0.9, aiType: EnemyAIType.hitAndRun,
      rangoMinimo: GateRank.c, expRicompensa: 88, oroRicompensa: 44, spriteKey: 'naga_guerriera',
    ),
    EnemyData(
      id: 'harpya', nome: 'Arpia', descrizione: 'Creatura alata che attacca con artigli affilati dall\'alto.',
      livelloBase: 25, saluteBase: 80, dannoBase: 28, difesaBase: 8, velocitaBase: 110,
      rangeAttacco: 36, cooldownAttacco: 0.7, aiType: EnemyAIType.flyer,
      elemento: ElementType.wind, rangoMinimo: GateRank.c, expRicompensa: 75, oroRicompensa: 38, spriteKey: 'harpya',
    ),
    EnemyData(
      id: 'golem_fuoco', nome: 'Golem di Fuoco', descrizione: 'Un golem incandescente che brucia tutto intorno.',
      livelloBase: 30, saluteBase: 250, dannoBase: 30, difesaBase: 30, velocitaBase: 20,
      rangeAttacco: 60, cooldownAttacco: 2.5, aiType: EnemyAIType.burner,
      elemento: ElementType.fire, rangoMinimo: GateRank.c, expRicompensa: 110, oroRicompensa: 55, spriteKey: 'golem_fuoco', dimensione: 1.5,
    ),
    EnemyData(
      id: 'assassino_ombra', nome: 'Assassino dell\'Ombra', descrizione: 'Si rende invisibile e colpisce con danni critici.',
      livelloBase: 29, saluteBase: 70, dannoBase: 50, difesaBase: 5, velocitaBase: 120,
      rangeAttacco: 32, cooldownAttacco: 0.6, aiType: EnemyAIType.stealth,
      elemento: ElementType.shadow, rangoMinimo: GateRank.c, expRicompensa: 95, oroRicompensa: 48, spriteKey: 'assassino_ombra',
    ),
    EnemyData(
      id: 'spirito_fulmine', nome: 'Spirito del Fulmine', descrizione: 'Si teletrasporta e colpisce con scariche elettriche.',
      livelloBase: 28, saluteBase: 85, dannoBase: 38, difesaBase: 5, velocitaBase: 140,
      rangeAttacco: 100, cooldownAttacco: 1.0, aiType: EnemyAIType.teleporter,
      elemento: ElementType.lightning, rangoMinimo: GateRank.c, expRicompensa: 92, oroRicompensa: 46, spriteKey: 'spirito_fulmine',
    ),
    EnemyData(
      id: 'troll_rigenerante', nome: 'Troll Rigenerante', descrizione: 'Si rigenera costantemente e diventa più forte quando ferito.',
      livelloBase: 32, saluteBase: 300, dannoBase: 25, difesaBase: 15, velocitaBase: 35,
      rangeAttacco: 48, cooldownAttacco: 1.8, aiType: EnemyAIType.berserker,
      rangoMinimo: GateRank.c, expRicompensa: 120, oroRicompensa: 60, spriteKey: 'troll_rigenerante', dimensione: 1.5,
    ),
    EnemyData(
      id: 'sciame_insetti', nome: 'Sciame d\'Insetti', descrizione: 'Uno sciame di insetti oscuri che avvelena e rallenta.',
      livelloBase: 26, saluteBase: 60, dannoBase: 20, difesaBase: 2, velocitaBase: 90,
      rangeAttacco: 48, cooldownAttacco: 0.5, aiType: EnemyAIType.poisoner,
      elemento: ElementType.poison, rangoMinimo: GateRank.c, expRicompensa: 70, oroRicompensa: 35, spriteKey: 'sciame_insetti',
    ),
    EnemyData(
      id: 'medusa', nome: 'Medusa', descrizione: 'Pietrifica con lo sguardo e attacca con serpenti.',
      livelloBase: 33, saluteBase: 130, dannoBase: 35, difesaBase: 12, velocitaBase: 45,
      rangeAttacco: 110, cooldownAttacco: 2.0, aiType: EnemyAIType.areaMage,
      elemento: ElementType.dark, rangoMinimo: GateRank.c, expRicompensa: 105, oroRicompensa: 52, spriteKey: 'medusa',
    ),
    EnemyData(
      id: 'elementale_terra', nome: 'Elementale di Terra', descrizione: 'Crea muri e terremoti per controllare il campo.',
      livelloBase: 30, saluteBase: 200, dannoBase: 22, difesaBase: 35, velocitaBase: 25,
      rangeAttacco: 80, cooldownAttacco: 2.5, aiType: EnemyAIType.trapper,
      elemento: ElementType.earth, rangoMinimo: GateRank.c, expRicompensa: 95, oroRicompensa: 48, spriteKey: 'elementale_terra', dimensione: 1.3,
    ),
    EnemyData(
      id: 'sirena_oscura', nome: 'Sirena Oscura', descrizione: 'Ammalia i nemici e li attacca mentre sono storditi.',
      livelloBase: 31, saluteBase: 90, dannoBase: 30, difesaBase: 8, velocitaBase: 60,
      rangeAttacco: 100, cooldownAttacco: 2.0, aiType: EnemyAIType.areaMage,
      elemento: ElementType.dark, rangoMinimo: GateRank.c, expRicompensa: 98, oroRicompensa: 49, spriteKey: 'sirena_oscura',
    ),
    EnemyData(
      id: 'chimera', nome: 'Chimera', descrizione: 'Creatura a tre teste che cambia elemento di attacco.',
      livelloBase: 34, saluteBase: 220, dannoBase: 38, difesaBase: 20, velocitaBase: 55,
      rangeAttacco: 60, cooldownAttacco: 1.2, aiType: EnemyAIType.berserker,
      rangoMinimo: GateRank.c, expRicompensa: 130, oroRicompensa: 65, spriteKey: 'chimera', dimensione: 1.5,
    ),

    // ============================================
    // GATE B - Nemici elite (36-55)
    // ============================================
    EnemyData(
      id: 'demone_minore', nome: 'Demone Minore', descrizione: 'Un demone con ali nere e artigli infuocati.',
      livelloBase: 50, saluteBase: 350, dannoBase: 55, difesaBase: 25, velocitaBase: 70,
      rangeAttacco: 44, cooldownAttacco: 1.0, aiType: EnemyAIType.melee,
      elemento: ElementType.fire, rangoMinimo: GateRank.b, expRicompensa: 200, oroRicompensa: 100, spriteKey: 'demone_minore', dimensione: 1.3,
    ),
    EnemyData(
      id: 'lich_minore', nome: 'Lich Minore', descrizione: 'Un mago non morto potente che evoca e attacca.',
      livelloBase: 55, saluteBase: 200, dannoBase: 70, difesaBase: 15, velocitaBase: 35,
      rangeAttacco: 200, cooldownAttacco: 2.0, aiType: EnemyAIType.summoner,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 250, oroRicompensa: 125, spriteKey: 'lich_minore',
    ),
    EnemyData(
      id: 'drago_cucciolo', nome: 'Drago Cucciolo', descrizione: 'Un giovane drago che sputa fiamme e vola.',
      livelloBase: 58, saluteBase: 400, dannoBase: 60, difesaBase: 30, velocitaBase: 80,
      rangeAttacco: 100, cooldownAttacco: 1.5, aiType: EnemyAIType.flyer,
      elemento: ElementType.fire, rangoMinimo: GateRank.b, expRicompensa: 280, oroRicompensa: 140, spriteKey: 'drago_cucciolo', dimensione: 1.8,
    ),
    EnemyData(
      id: 'cavaliere_morte', nome: 'Cavaliere della Morte', descrizione: 'Un guerriero non morto con armatura leggendaria.',
      livelloBase: 55, saluteBase: 450, dannoBase: 50, difesaBase: 40, velocitaBase: 50,
      rangeAttacco: 48, cooldownAttacco: 1.2, aiType: EnemyAIType.tank,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 260, oroRicompensa: 130, spriteKey: 'cavaliere_morte', dimensione: 1.3,
    ),
    EnemyData(
      id: 'djinn', nome: 'Djinn', descrizione: 'Spirito elementale che controlla il vento e le illusioni.',
      livelloBase: 52, saluteBase: 180, dannoBase: 55, difesaBase: 10, velocitaBase: 100,
      rangeAttacco: 150, cooldownAttacco: 1.0, aiType: EnemyAIType.teleporter,
      elemento: ElementType.wind, rangoMinimo: GateRank.b, expRicompensa: 220, oroRicompensa: 110, spriteKey: 'djinn',
    ),
    EnemyData(
      id: 'kraken_tentacolo', nome: 'Tentacolo del Kraken', descrizione: 'Un tentacolo gigante che emerge dal terreno.',
      livelloBase: 56, saluteBase: 300, dannoBase: 45, difesaBase: 20, velocitaBase: 40,
      rangeAttacco: 80, cooldownAttacco: 1.5, aiType: EnemyAIType.trapper,
      rangoMinimo: GateRank.b, expRicompensa: 240, oroRicompensa: 120, spriteKey: 'kraken_tentacolo', dimensione: 1.5,
    ),
    EnemyData(
      id: 'banshee', nome: 'Banshee', descrizione: 'Spirito urlante che causa danni sonori ad area.',
      livelloBase: 53, saluteBase: 150, dannoBase: 60, difesaBase: 5, velocitaBase: 90,
      rangeAttacco: 120, cooldownAttacco: 2.0, aiType: EnemyAIType.areaMage,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 230, oroRicompensa: 115, spriteKey: 'banshee',
    ),
    EnemyData(
      id: 'succube', nome: 'Succube', descrizione: 'Demone che assorbe vita e seduce i nemici.',
      livelloBase: 54, saluteBase: 200, dannoBase: 35, difesaBase: 12, velocitaBase: 75,
      rangeAttacco: 36, cooldownAttacco: 0.8, aiType: EnemyAIType.vampiric,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 235, oroRicompensa: 118, spriteKey: 'succube',
    ),
    EnemyData(
      id: 'idra_piccola', nome: 'Piccola Idra', descrizione: 'Un\'idra con 3 teste che si rigenerano.',
      livelloBase: 58, saluteBase: 500, dannoBase: 40, difesaBase: 22, velocitaBase: 30,
      rangeAttacco: 60, cooldownAttacco: 1.0, aiType: EnemyAIType.splitter,
      rangoMinimo: GateRank.b, expRicompensa: 300, oroRicompensa: 150, spriteKey: 'idra_piccola', dimensione: 1.8,
    ),
    EnemyData(
      id: 'gargoyle', nome: 'Gargoyle', descrizione: 'Si pietrifica per difendersi e poi contrattacca.',
      livelloBase: 52, saluteBase: 280, dannoBase: 35, difesaBase: 40, velocitaBase: 50,
      rangeAttacco: 40, cooldownAttacco: 1.5, aiType: EnemyAIType.reflector,
      elemento: ElementType.earth, rangoMinimo: GateRank.b, expRicompensa: 210, oroRicompensa: 105, spriteKey: 'gargoyle', dimensione: 1.3,
    ),
    EnemyData(
      id: 'mummia_reale', nome: 'Mummia Reale', descrizione: 'Non morto egizio con maledizioni potenti.',
      livelloBase: 56, saluteBase: 350, dannoBase: 45, difesaBase: 25, velocitaBase: 40,
      rangeAttacco: 100, cooldownAttacco: 2.0, aiType: EnemyAIType.areaMage,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 245, oroRicompensa: 122, spriteKey: 'mummia_reale',
    ),
    EnemyData(
      id: 'centauro_arciere', nome: 'Centauro Arciere', descrizione: 'Metà uomo metà cavallo, tira frecce precise in corsa.',
      livelloBase: 53, saluteBase: 250, dannoBase: 40, difesaBase: 18, velocitaBase: 95,
      rangeAttacco: 180, cooldownAttacco: 1.2, aiType: EnemyAIType.ranged,
      rangoMinimo: GateRank.b, expRicompensa: 225, oroRicompensa: 112, spriteKey: 'centauro_arciere', dimensione: 1.3,
    ),
    EnemyData(
      id: 'golem_cristallo', nome: 'Golem di Cristallo', descrizione: 'Genera scudi energetici per sé e i compagni.',
      livelloBase: 55, saluteBase: 380, dannoBase: 25, difesaBase: 45, velocitaBase: 25,
      rangeAttacco: 80, cooldownAttacco: 3.0, aiType: EnemyAIType.shielder,
      elemento: ElementType.holy, rangoMinimo: GateRank.b, expRicompensa: 255, oroRicompensa: 128, spriteKey: 'golem_cristallo', dimensione: 1.5,
    ),
    EnemyData(
      id: 'ninja_ombra', nome: 'Ninja dell\'Ombra', descrizione: 'Guerriero furtivo con shuriken e ninjutsu oscuro.',
      livelloBase: 54, saluteBase: 160, dannoBase: 55, difesaBase: 10, velocitaBase: 130,
      rangeAttacco: 100, cooldownAttacco: 0.6, aiType: EnemyAIType.stealth,
      elemento: ElementType.shadow, rangoMinimo: GateRank.b, expRicompensa: 240, oroRicompensa: 120, spriteKey: 'ninja_ombra',
    ),
    EnemyData(
      id: 'fenice_corrotta', nome: 'Fenice Corrotta', descrizione: 'Uccello di fiamme oscure che rinasce dalle ceneri.',
      livelloBase: 58, saluteBase: 280, dannoBase: 50, difesaBase: 15, velocitaBase: 100,
      rangeAttacco: 80, cooldownAttacco: 1.0, aiType: EnemyAIType.flyer,
      elemento: ElementType.fire, rangoMinimo: GateRank.b, expRicompensa: 290, oroRicompensa: 145, spriteKey: 'fenice_corrotta', dimensione: 1.5,
    ),
    EnemyData(
      id: 'sacerdote_oscuro', nome: 'Sacerdote Oscuro', descrizione: 'Cura i non morti e lancia maledizioni devastanti.',
      livelloBase: 57, saluteBase: 180, dannoBase: 30, difesaBase: 15, velocitaBase: 35,
      rangeAttacco: 150, cooldownAttacco: 2.5, aiType: EnemyAIType.healer,
      elemento: ElementType.dark, rangoMinimo: GateRank.b, expRicompensa: 265, oroRicompensa: 132, spriteKey: 'sacerdote_oscuro',
    ),
    EnemyData(
      id: 'berserker_orco', nome: 'Berserker Orco', descrizione: 'Orco impazzito che diventa più forte quando ferito.',
      livelloBase: 56, saluteBase: 420, dannoBase: 55, difesaBase: 15, velocitaBase: 60,
      rangeAttacco: 48, cooldownAttacco: 0.8, aiType: EnemyAIType.berserker,
      rangoMinimo: GateRank.b, expRicompensa: 270, oroRicompensa: 135, spriteKey: 'berserker_orco', dimensione: 1.5,
    ),
    EnemyData(
      id: 'wraith', nome: 'Wraith', descrizione: 'Spirito vendicativo che attraversa muri e ostacoli.',
      livelloBase: 55, saluteBase: 200, dannoBase: 45, difesaBase: 5, velocitaBase: 85,
      rangeAttacco: 40, cooldownAttacco: 1.0, aiType: EnemyAIType.teleporter,
      elemento: ElementType.shadow, rangoMinimo: GateRank.b, expRicompensa: 250, oroRicompensa: 125, spriteKey: 'wraith',
    ),
    EnemyData(
      id: 'mantide_lama', nome: 'Mantide Lama', descrizione: 'Insetto gigante con arti taglienti come lame.',
      livelloBase: 54, saluteBase: 220, dannoBase: 60, difesaBase: 12, velocitaBase: 110,
      rangeAttacco: 44, cooldownAttacco: 0.5, aiType: EnemyAIType.hitAndRun,
      rangoMinimo: GateRank.b, expRicompensa: 245, oroRicompensa: 122, spriteKey: 'mantide_lama', dimensione: 1.3,
    ),
    EnemyData(
      id: 'bomba_vivente', nome: 'Bomba Vivente', descrizione: 'Creatura instabile che esplode in una grande area.',
      livelloBase: 52, saluteBase: 50, dannoBase: 150, difesaBase: 0, velocitaBase: 60,
      rangeAttacco: 80, cooldownAttacco: 0, aiType: EnemyAIType.kamikaze,
      elemento: ElementType.fire, rangoMinimo: GateRank.b, expRicompensa: 200, oroRicompensa: 100, spriteKey: 'bomba_vivente',
    ),

    // ============================================
    // GATE A - Nemici potenti (56-75)
    // ============================================
    EnemyData(
      id: 'demone_maggiore', nome: 'Demone Maggiore', descrizione: 'Un potente demone con fiamme infernali.',
      livelloBase: 100, saluteBase: 800, dannoBase: 120, difesaBase: 50, velocitaBase: 75,
      rangeAttacco: 56, cooldownAttacco: 1.0, aiType: EnemyAIType.melee,
      elemento: ElementType.fire, rangoMinimo: GateRank.a, expRicompensa: 500, oroRicompensa: 250, spriteKey: 'demone_maggiore', dimensione: 1.8,
    ),
    EnemyData(
      id: 'drago_adulto', nome: 'Drago Adulto', descrizione: 'Un drago in piena maturità con soffio devastante.',
      livelloBase: 110, saluteBase: 1200, dannoBase: 100, difesaBase: 60, velocitaBase: 85,
      rangeAttacco: 150, cooldownAttacco: 2.0, aiType: EnemyAIType.flyer,
      elemento: ElementType.fire, rangoMinimo: GateRank.a, expRicompensa: 600, oroRicompensa: 300, spriteKey: 'drago_adulto', dimensione: 2.0,
    ),
    EnemyData(
      id: 'lich_maggiore', nome: 'Lich Maggiore', descrizione: 'Un potentissimo mago non morto con esercito di servitori.',
      livelloBase: 105, saluteBase: 500, dannoBase: 140, difesaBase: 30, velocitaBase: 35,
      rangeAttacco: 250, cooldownAttacco: 2.5, aiType: EnemyAIType.summoner,
      elemento: ElementType.dark, rangoMinimo: GateRank.a, expRicompensa: 550, oroRicompensa: 275, spriteKey: 'lich_maggiore',
    ),
    EnemyData(
      id: 'formica_soldato', nome: 'Formica Soldato', descrizione: 'Formica gigante con mandibole d\'acciaio, ispirata all\'Isola Jeju.',
      livelloBase: 100, saluteBase: 600, dannoBase: 90, difesaBase: 45, velocitaBase: 90,
      rangeAttacco: 40, cooldownAttacco: 0.7, aiType: EnemyAIType.melee,
      rangoMinimo: GateRank.a, expRicompensa: 480, oroRicompensa: 240, spriteKey: 'formica_soldato', dimensione: 1.5,
    ),
    EnemyData(
      id: 'formica_maga', nome: 'Formica Maga', descrizione: 'Formica che usa magia acida devastante.',
      livelloBase: 105, saluteBase: 400, dannoBase: 130, difesaBase: 25, velocitaBase: 60,
      rangeAttacco: 180, cooldownAttacco: 1.5, aiType: EnemyAIType.areaMage,
      elemento: ElementType.poison, rangoMinimo: GateRank.a, expRicompensa: 520, oroRicompensa: 260, spriteKey: 'formica_maga',
    ),
    EnemyData(
      id: 'gigante_frost', nome: 'Gigante del Gelo', descrizione: 'Un gigante di ghiaccio che congela tutto il campo.',
      livelloBase: 108, saluteBase: 1500, dannoBase: 80, difesaBase: 70, velocitaBase: 30,
      rangeAttacco: 64, cooldownAttacco: 2.0, aiType: EnemyAIType.freezer,
      elemento: ElementType.ice, rangoMinimo: GateRank.a, expRicompensa: 580, oroRicompensa: 290, spriteKey: 'gigante_frost', dimensione: 2.0,
    ),
    EnemyData(
      id: 'arcangelo_caduto', nome: 'Arcangelo Caduto', descrizione: 'Un angelo corrotto con poteri divini e oscuri.',
      livelloBase: 112, saluteBase: 700, dannoBase: 110, difesaBase: 40, velocitaBase: 100,
      rangeAttacco: 120, cooldownAttacco: 1.0, aiType: EnemyAIType.teleporter,
      elemento: ElementType.holy, rangoMinimo: GateRank.a, expRicompensa: 620, oroRicompensa: 310, spriteKey: 'arcangelo_caduto', dimensione: 1.5,
    ),
    EnemyData(
      id: 'kraken', nome: 'Kraken', descrizione: 'Mostro marino colossale con tentacoli enormi.',
      livelloBase: 110, saluteBase: 2000, dannoBase: 70, difesaBase: 50, velocitaBase: 25,
      rangeAttacco: 120, cooldownAttacco: 1.5, aiType: EnemyAIType.trapper,
      rangoMinimo: GateRank.a, expRicompensa: 650, oroRicompensa: 325, spriteKey: 'kraken', dimensione: 2.5,
    ),
    EnemyData(
      id: 'vampiro_antico', nome: 'Vampiro Antico', descrizione: 'Un vampiro millenario con poteri terrificanti.',
      livelloBase: 108, saluteBase: 600, dannoBase: 95, difesaBase: 35, velocitaBase: 110,
      rangeAttacco: 40, cooldownAttacco: 0.6, aiType: EnemyAIType.vampiric,
      elemento: ElementType.dark, rangoMinimo: GateRank.a, expRicompensa: 560, oroRicompensa: 280, spriteKey: 'vampiro_antico',
    ),
    EnemyData(
      id: 'guardiano_portale', nome: 'Guardiano del Portale', descrizione: 'Protettore dei Gate con scudi impenetrabili.',
      livelloBase: 115, saluteBase: 1000, dannoBase: 60, difesaBase: 80, velocitaBase: 40,
      rangeAttacco: 60, cooldownAttacco: 2.0, aiType: EnemyAIType.shielder,
      rangoMinimo: GateRank.a, expRicompensa: 680, oroRicompensa: 340, spriteKey: 'guardiano_portale', dimensione: 1.8,
    ),
    EnemyData(
      id: 'cerbero', nome: 'Cerbero', descrizione: 'Cane a tre teste guardiano degli inferi.',
      livelloBase: 110, saluteBase: 900, dannoBase: 85, difesaBase: 40, velocitaBase: 70,
      rangeAttacco: 60, cooldownAttacco: 0.8, aiType: EnemyAIType.berserker,
      elemento: ElementType.fire, rangoMinimo: GateRank.a, expRicompensa: 600, oroRicompensa: 300, spriteKey: 'cerbero', dimensione: 2.0,
    ),
    EnemyData(
      id: 'spadaccino_celeste', nome: 'Spadaccino Celeste', descrizione: 'Guerriero divino con tecniche di spada perfette.',
      livelloBase: 112, saluteBase: 500, dannoBase: 130, difesaBase: 30, velocitaBase: 120,
      rangeAttacco: 48, cooldownAttacco: 0.4, aiType: EnemyAIType.hitAndRun,
      elemento: ElementType.holy, rangoMinimo: GateRank.a, expRicompensa: 640, oroRicompensa: 320, spriteKey: 'spadaccino_celeste',
    ),
    EnemyData(
      id: 'idra_maggiore', nome: 'Idra Maggiore', descrizione: 'Idra con 7 teste rigeneranti, ogni testa un elemento.',
      livelloBase: 115, saluteBase: 1800, dannoBase: 75, difesaBase: 45, velocitaBase: 30,
      rangeAttacco: 80, cooldownAttacco: 1.0, aiType: EnemyAIType.splitter,
      rangoMinimo: GateRank.a, expRicompensa: 700, oroRicompensa: 350, spriteKey: 'idra_maggiore', dimensione: 2.5,
    ),
    EnemyData(
      id: 'evocatore_demoni', nome: 'Evocatore di Demoni', descrizione: 'Mago oscuro che evoca demoni dal vuoto.',
      livelloBase: 108, saluteBase: 350, dannoBase: 50, difesaBase: 20, velocitaBase: 30,
      rangeAttacco: 200, cooldownAttacco: 4.0, aiType: EnemyAIType.summoner,
      elemento: ElementType.dark, rangoMinimo: GateRank.a, expRicompensa: 560, oroRicompensa: 280, spriteKey: 'evocatore_demoni',
    ),
    EnemyData(
      id: 'golem_adamantio', nome: 'Golem di Adamantio', descrizione: 'Il golem più resistente, quasi indistruttibile.',
      livelloBase: 118, saluteBase: 3000, dannoBase: 50, difesaBase: 100, velocitaBase: 15,
      rangeAttacco: 56, cooldownAttacco: 3.0, aiType: EnemyAIType.reflector,
      elemento: ElementType.earth, rangoMinimo: GateRank.a, expRicompensa: 750, oroRicompensa: 375, spriteKey: 'golem_adamantio', dimensione: 2.5,
    ),
    EnemyData(
      id: 'elementale_fulmine', nome: 'Elementale del Fulmine', descrizione: 'Pura energia elettrica con velocità estrema.',
      livelloBase: 106, saluteBase: 400, dannoBase: 100, difesaBase: 10, velocitaBase: 150,
      rangeAttacco: 120, cooldownAttacco: 0.5, aiType: EnemyAIType.teleporter,
      elemento: ElementType.lightning, rangoMinimo: GateRank.a, expRicompensa: 530, oroRicompensa: 265, spriteKey: 'elementale_fulmine',
    ),
    EnemyData(
      id: 'drago_zombie', nome: 'Drago Zombie', descrizione: 'Drago non morto rianimato da magia oscura.',
      livelloBase: 115, saluteBase: 1400, dannoBase: 95, difesaBase: 55, velocitaBase: 50,
      rangeAttacco: 100, cooldownAttacco: 1.8, aiType: EnemyAIType.burner,
      elemento: ElementType.dark, rangoMinimo: GateRank.a, expRicompensa: 700, oroRicompensa: 350, spriteKey: 'drago_zombie', dimensione: 2.0,
    ),
    EnemyData(
      id: 'spirito_vendetta', nome: 'Spirito della Vendetta', descrizione: 'Assorbe i danni subiti e li rilascia moltiplicati.',
      livelloBase: 112, saluteBase: 550, dannoBase: 40, difesaBase: 30, velocitaBase: 80,
      rangeAttacco: 60, cooldownAttacco: 1.0, aiType: EnemyAIType.reflector,
      elemento: ElementType.shadow, rangoMinimo: GateRank.a, expRicompensa: 620, oroRicompensa: 310, spriteKey: 'spirito_vendetta',
    ),
    EnemyData(
      id: 'chimera_evoluta', nome: 'Chimera Evoluta', descrizione: 'Chimera potenziata con 5 teste elementali.',
      livelloBase: 118, saluteBase: 900, dannoBase: 110, difesaBase: 40, velocitaBase: 65,
      rangeAttacco: 80, cooldownAttacco: 1.0, aiType: EnemyAIType.berserker,
      rangoMinimo: GateRank.a, expRicompensa: 750, oroRicompensa: 375, spriteKey: 'chimera_evoluta', dimensione: 2.0,
    ),
    EnemyData(
      id: 'formica_guardia', nome: 'Formica Guardia Reale', descrizione: 'Elite della colonia, protegge la regina.',
      livelloBase: 110, saluteBase: 800, dannoBase: 100, difesaBase: 55, velocitaBase: 80,
      rangeAttacco: 44, cooldownAttacco: 0.8, aiType: EnemyAIType.tank,
      rangoMinimo: GateRank.a, expRicompensa: 650, oroRicompensa: 325, spriteKey: 'formica_guardia', dimensione: 1.5,
    ),

    // ============================================
    // GATE S - Nemici devastanti (76-90)
    // ============================================
    EnemyData(
      id: 'arcidemonee', nome: 'Arcidemone', descrizione: 'Uno dei demoni più potenti dell\'inferno.',
      livelloBase: 200, saluteBase: 2000, dannoBase: 250, difesaBase: 80, velocitaBase: 80,
      rangeAttacco: 64, cooldownAttacco: 0.8, aiType: EnemyAIType.melee,
      elemento: ElementType.fire, rangoMinimo: GateRank.s, expRicompensa: 1500, oroRicompensa: 750, spriteKey: 'arcidemone', dimensione: 2.0,
    ),
    EnemyData(
      id: 'drago_antico', nome: 'Drago Antico', descrizione: 'Drago millenario con potere supremo.',
      livelloBase: 220, saluteBase: 5000, dannoBase: 200, difesaBase: 100, velocitaBase: 70,
      rangeAttacco: 200, cooldownAttacco: 2.0, aiType: EnemyAIType.flyer,
      elemento: ElementType.fire, rangoMinimo: GateRank.s, expRicompensa: 2000, oroRicompensa: 1000, spriteKey: 'drago_antico', dimensione: 3.0,
    ),
    EnemyData(
      id: 'titano', nome: 'Titano', descrizione: 'Gigante primordiale di proporzioni colossali.',
      livelloBase: 210, saluteBase: 8000, dannoBase: 150, difesaBase: 120, velocitaBase: 20,
      rangeAttacco: 100, cooldownAttacco: 3.0, aiType: EnemyAIType.tank,
      elemento: ElementType.earth, rangoMinimo: GateRank.s, expRicompensa: 1800, oroRicompensa: 900, spriteKey: 'titano', dimensione: 3.0,
    ),
    EnemyData(
      id: 'serafino_oscuro', nome: 'Serafino Oscuro', descrizione: 'Angelo supremo corrotto con 6 ali nere.',
      livelloBase: 215, saluteBase: 3000, dannoBase: 220, difesaBase: 60, velocitaBase: 120,
      rangeAttacco: 150, cooldownAttacco: 0.8, aiType: EnemyAIType.teleporter,
      elemento: ElementType.dark, rangoMinimo: GateRank.s, expRicompensa: 1700, oroRicompensa: 850, spriteKey: 'serafino_oscuro', dimensione: 2.0,
    ),
    EnemyData(
      id: 'leviatano', nome: 'Leviatano', descrizione: 'Serpente marino colossale che controlla le maree.',
      livelloBase: 220, saluteBase: 6000, dannoBase: 180, difesaBase: 90, velocitaBase: 50,
      rangeAttacco: 150, cooldownAttacco: 1.5, aiType: EnemyAIType.areaMage,
      elemento: ElementType.ice, rangoMinimo: GateRank.s, expRicompensa: 2000, oroRicompensa: 1000, spriteKey: 'leviatano', dimensione: 3.0,
    ),
    EnemyData(
      id: 'necro_signore', nome: 'Signore dei Non Morti', descrizione: 'Evoca orde infinite di non morti.',
      livelloBase: 210, saluteBase: 2500, dannoBase: 150, difesaBase: 50, velocitaBase: 35,
      rangeAttacco: 250, cooldownAttacco: 3.0, aiType: EnemyAIType.summoner,
      elemento: ElementType.dark, rangoMinimo: GateRank.s, expRicompensa: 1600, oroRicompensa: 800, spriteKey: 'necro_signore', dimensione: 1.8,
    ),
    EnemyData(
      id: 'fenrir', nome: 'Fenrir', descrizione: 'Il lupo divino divoratore di mondi.',
      livelloBase: 225, saluteBase: 4000, dannoBase: 200, difesaBase: 70, velocitaBase: 130,
      rangeAttacco: 64, cooldownAttacco: 0.5, aiType: EnemyAIType.berserker,
      elemento: ElementType.shadow, rangoMinimo: GateRank.s, expRicompensa: 2200, oroRicompensa: 1100, spriteKey: 'fenrir', dimensione: 2.5,
    ),
    EnemyData(
      id: 'golem_divino', nome: 'Golem Divino', descrizione: 'Costrutto creato dagli dei, quasi invincibile.',
      livelloBase: 218, saluteBase: 10000, dannoBase: 100, difesaBase: 150, velocitaBase: 15,
      rangeAttacco: 80, cooldownAttacco: 3.0, aiType: EnemyAIType.shielder,
      elemento: ElementType.holy, rangoMinimo: GateRank.s, expRicompensa: 1900, oroRicompensa: 950, spriteKey: 'golem_divino', dimensione: 3.0,
    ),
    EnemyData(
      id: 'avatar_caos', nome: 'Avatar del Caos', descrizione: 'Entità caotica che cambia forma e abilità.',
      livelloBase: 225, saluteBase: 3500, dannoBase: 180, difesaBase: 60, velocitaBase: 100,
      rangeAttacco: 100, cooldownAttacco: 1.0, aiType: EnemyAIType.teleporter,
      rangoMinimo: GateRank.s, expRicompensa: 2100, oroRicompensa: 1050, spriteKey: 'avatar_caos', dimensione: 2.0,
    ),
    EnemyData(
      id: 'idra_immortale', nome: 'Idra Immortale', descrizione: 'Idra con 9 teste che non muoiono mai veramente.',
      livelloBase: 230, saluteBase: 7000, dannoBase: 160, difesaBase: 80, velocitaBase: 25,
      rangeAttacco: 100, cooldownAttacco: 0.8, aiType: EnemyAIType.splitter,
      elemento: ElementType.poison, rangoMinimo: GateRank.s, expRicompensa: 2500, oroRicompensa: 1250, spriteKey: 'idra_immortale', dimensione: 3.0,
    ),
    EnemyData(
      id: 'spirito_tempesta', nome: 'Spirito della Tempesta', descrizione: 'Elementale supremo di vento e fulmini.',
      livelloBase: 215, saluteBase: 2200, dannoBase: 200, difesaBase: 30, velocitaBase: 150,
      rangeAttacco: 180, cooldownAttacco: 0.5, aiType: EnemyAIType.areaMage,
      elemento: ElementType.lightning, rangoMinimo: GateRank.s, expRicompensa: 1800, oroRicompensa: 900, spriteKey: 'spirito_tempesta', dimensione: 2.0,
    ),
    EnemyData(
      id: 'vampiro_re', nome: 'Re dei Vampiri', descrizione: 'Il primo e più potente vampiro mai esistito.',
      livelloBase: 222, saluteBase: 3000, dannoBase: 170, difesaBase: 55, velocitaBase: 120,
      rangeAttacco: 48, cooldownAttacco: 0.5, aiType: EnemyAIType.vampiric,
      elemento: ElementType.dark, rangoMinimo: GateRank.s, expRicompensa: 2000, oroRicompensa: 1000, spriteKey: 'vampiro_re', dimensione: 1.5,
    ),
    EnemyData(
      id: 'custode_abisso', nome: 'Custode dell\'Abisso', descrizione: 'Guardiano dei confini tra i mondi.',
      livelloBase: 228, saluteBase: 5000, dannoBase: 190, difesaBase: 100, velocitaBase: 50,
      rangeAttacco: 120, cooldownAttacco: 1.5, aiType: EnemyAIType.reflector,
      elemento: ElementType.shadow, rangoMinimo: GateRank.s, expRicompensa: 2300, oroRicompensa: 1150, spriteKey: 'custode_abisso', dimensione: 2.5,
    ),
    EnemyData(
      id: 'valchiria', nome: 'Valchiria Corrotta', descrizione: 'Guerriera divina caduta con lancia e scudo sacri.',
      livelloBase: 218, saluteBase: 2800, dannoBase: 180, difesaBase: 70, velocitaBase: 100,
      rangeAttacco: 60, cooldownAttacco: 0.8, aiType: EnemyAIType.hitAndRun,
      elemento: ElementType.holy, rangoMinimo: GateRank.s, expRicompensa: 1900, oroRicompensa: 950, spriteKey: 'valchiria', dimensione: 1.5,
    ),
    EnemyData(
      id: 'ragnatela_regina', nome: 'Regina dei Ragni', descrizione: 'Ragno colossale che tesse trappole dimensionali.',
      livelloBase: 220, saluteBase: 3500, dannoBase: 140, difesaBase: 60, velocitaBase: 70,
      rangeAttacco: 150, cooldownAttacco: 2.0, aiType: EnemyAIType.trapper,
      elemento: ElementType.poison, rangoMinimo: GateRank.s, expRicompensa: 2000, oroRicompensa: 1000, spriteKey: 'ragnatela_regina', dimensione: 2.5,
    ),

    // ============================================
    // GATE ROSSO / MONARCA - Nemici supremi (91-100)
    // ============================================
    EnemyData(
      id: 'soldato_monarca', nome: 'Soldato del Monarca', descrizione: 'Guerriero d\'élite al servizio di un Monarca.',
      livelloBase: 300, saluteBase: 5000, dannoBase: 350, difesaBase: 120, velocitaBase: 90,
      rangeAttacco: 56, cooldownAttacco: 0.7, aiType: EnemyAIType.melee,
      elemento: ElementType.shadow, rangoMinimo: GateRank.red, expRicompensa: 5000, oroRicompensa: 2500, spriteKey: 'soldato_monarca', dimensione: 1.8,
    ),
    EnemyData(
      id: 'mago_monarca', nome: 'Mago del Monarca', descrizione: 'Incantatore supremo con magie che distruggono la realtà.',
      livelloBase: 320, saluteBase: 3000, dannoBase: 500, difesaBase: 60, velocitaBase: 50,
      rangeAttacco: 300, cooldownAttacco: 2.0, aiType: EnemyAIType.areaMage,
      elemento: ElementType.shadow, rangoMinimo: GateRank.red, expRicompensa: 6000, oroRicompensa: 3000, spriteKey: 'mago_monarca',
    ),
    EnemyData(
      id: 'drago_ombra', nome: 'Drago dell\'Ombra', descrizione: 'Drago oscuro che dissolve la luce stessa.',
      livelloBase: 350, saluteBase: 15000, dannoBase: 400, difesaBase: 150, velocitaBase: 80,
      rangeAttacco: 200, cooldownAttacco: 1.5, aiType: EnemyAIType.flyer,
      elemento: ElementType.shadow, rangoMinimo: GateRank.red, expRicompensa: 8000, oroRicompensa: 4000, spriteKey: 'drago_ombra', dimensione: 3.5,
    ),
    EnemyData(
      id: 'cavaliere_monarca', nome: 'Cavaliere del Monarca', descrizione: 'Guerriero supremo con scudo e spada dimensionali.',
      livelloBase: 330, saluteBase: 8000, dannoBase: 350, difesaBase: 200, velocitaBase: 60,
      rangeAttacco: 56, cooldownAttacco: 1.0, aiType: EnemyAIType.tank,
      elemento: ElementType.shadow, rangoMinimo: GateRank.red, expRicompensa: 7000, oroRicompensa: 3500, spriteKey: 'cavaliere_monarca', dimensione: 2.0,
    ),
    EnemyData(
      id: 'evocatore_monarca', nome: 'Evocatore del Monarca', descrizione: 'Evoca creature dall\'abisso del nulla.',
      livelloBase: 340, saluteBase: 4000, dannoBase: 300, difesaBase: 80, velocitaBase: 40,
      rangeAttacco: 250, cooldownAttacco: 3.0, aiType: EnemyAIType.summoner,
      elemento: ElementType.shadow, rangoMinimo: GateRank.red, expRicompensa: 7500, oroRicompensa: 3750, spriteKey: 'evocatore_monarca', dimensione: 1.5,
    ),
    EnemyData(
      id: 'assassino_monarca', nome: 'Assassino del Monarca', descrizione: 'Ombra vivente che uccide in un istante.',
      livelloBase: 350, saluteBase: 3000, dannoBase: 600, difesaBase: 40, velocitaBase: 200,
      rangeAttacco: 40, cooldownAttacco: 0.3, aiType: EnemyAIType.stealth,
      elemento: ElementType.shadow, rangoMinimo: GateRank.monarch, expRicompensa: 8000, oroRicompensa: 4000, spriteKey: 'assassino_monarca',
    ),
    EnemyData(
      id: 'golem_monarca', nome: 'Golem del Monarca', descrizione: 'Costrutto di pura energia oscura, invulnerabile.',
      livelloBase: 400, saluteBase: 20000, dannoBase: 200, difesaBase: 300, velocitaBase: 10,
      rangeAttacco: 80, cooldownAttacco: 3.0, aiType: EnemyAIType.shielder,
      elemento: ElementType.shadow, rangoMinimo: GateRank.monarch, expRicompensa: 10000, oroRicompensa: 5000, spriteKey: 'golem_monarca', dimensione: 3.5,
    ),
    EnemyData(
      id: 'drago_divino', nome: 'Drago Divino', descrizione: 'Il drago supremo, signore dei cieli.',
      livelloBase: 450, saluteBase: 25000, dannoBase: 500, difesaBase: 200, velocitaBase: 100,
      rangeAttacco: 300, cooldownAttacco: 2.0, aiType: EnemyAIType.flyer,
      elemento: ElementType.holy, rangoMinimo: GateRank.monarch, expRicompensa: 15000, oroRicompensa: 7500, spriteKey: 'drago_divino', dimensione: 4.0,
    ),
    EnemyData(
      id: 'entita_vuoto', nome: 'Entità del Vuoto', descrizione: 'Creatura che esiste tra le dimensioni.',
      livelloBase: 500, saluteBase: 10000, dannoBase: 800, difesaBase: 100, velocitaBase: 150,
      rangeAttacco: 200, cooldownAttacco: 0.5, aiType: EnemyAIType.teleporter,
      elemento: ElementType.shadow, rangoMinimo: GateRank.monarch, expRicompensa: 20000, oroRicompensa: 10000, spriteKey: 'entita_vuoto', dimensione: 2.5,
    ),
    EnemyData(
      id: 'ombra_suprema', nome: 'Ombra Suprema', descrizione: 'L\'ombra più potente, quasi un Monarca.',
      livelloBase: 600, saluteBase: 30000, dannoBase: 700, difesaBase: 250, velocitaBase: 120,
      rangeAttacco: 100, cooldownAttacco: 0.5, aiType: EnemyAIType.berserker,
      elemento: ElementType.shadow, rangoMinimo: GateRank.monarch, expRicompensa: 30000, oroRicompensa: 15000, spriteKey: 'ombra_suprema', dimensione: 3.0,
    ),
  ];

  /// Ottieni nemici filtrati per rango del gate
  static List<EnemyData> getNemiciPerGate(GateRank rango) {
    return tuttiINemici.where((e) => e.rangoMinimo == rango).toList();
  }

  /// Ottieni un nemico per ID
  static EnemyData? getNemicoById(String id) {
    try {
      return tuttiINemici.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
