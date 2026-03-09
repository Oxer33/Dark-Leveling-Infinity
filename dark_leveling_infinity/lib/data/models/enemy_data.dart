/// Modello dati per i nemici del gioco
/// Definisce le strutture base per nemici e boss
library;

import '../../core/constants/game_constants.dart';

/// Tipo di comportamento AI del nemico
enum EnemyAIType {
  /// Si muove verso il player e attacca in mischia
  melee,

  /// Mantiene distanza e attacca da lontano
  ranged,

  /// Si muove velocemente e colpisce poi fugge
  hitAndRun,

  /// Si teletrasporta vicino al player
  teleporter,

  /// Evoca altri nemici
  summoner,

  /// Si difende e contrattacca
  tank,

  /// Cura i nemici alleati
  healer,

  /// Esplode quando vicino al player
  kamikaze,

  /// Si mimetizza e attacca a sorpresa
  stealth,

  /// Vola e attacca dall'alto
  flyer,

  /// Attacca in area con magie potenti
  areaMage,

  /// Si divide in copie più piccole
  splitter,

  /// Crea trappole
  trapper,

  /// Avvelena con attacchi prolungati
  poisoner,

  /// Congela e rallenta
  freezer,

  /// Brucia con attacchi di fuoco
  burner,

  /// Assorbe vita dal player
  vampiric,

  /// Riflette i danni
  reflector,

  /// Crea scudi per sé e alleati
  shielder,

  /// Si potenzia nel tempo
  berserker,
}

/// Tipo di elemento del nemico
enum ElementType {
  none,
  fire,
  ice,
  lightning,
  poison,
  dark,
  holy,
  shadow,
  wind,
  earth,
}

/// Dati base di un nemico
class EnemyData {
  final String id;
  final String nome;
  final String descrizione;
  final int livelloBase;
  final double saluteBase;
  final double dannoBase;
  final double difesaBase;
  final double velocitaBase;
  final double rangeAttacco;
  final double cooldownAttacco;
  final EnemyAIType aiType;
  final ElementType elemento;
  final GateRank rangoMinimo;
  final double expRicompensa;
  final int oroRicompensa;
  final double dropRateBonus;
  final bool puoEssereEstratto; // per le ombre
  final List<String> abilitaSpeciali;
  final String spriteKey;
  final double dimensione; // scala dello sprite

  const EnemyData({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.livelloBase,
    required this.saluteBase,
    required this.dannoBase,
    required this.difesaBase,
    required this.velocitaBase,
    required this.rangeAttacco,
    required this.cooldownAttacco,
    required this.aiType,
    this.elemento = ElementType.none,
    required this.rangoMinimo,
    required this.expRicompensa,
    required this.oroRicompensa,
    this.dropRateBonus = 0.0,
    this.puoEssereEstratto = true,
    this.abilitaSpeciali = const [],
    required this.spriteKey,
    this.dimensione = 1.0,
  });

  /// Calcola stats scalate per livello dungeon
  double saluteScalata(int livelloDungeon) {
    final moltiplicatore = 1.0 + (livelloDungeon - livelloBase) * 0.15;
    return saluteBase * moltiplicatore.clamp(0.5, 100.0);
  }

  double dannoScalato(int livelloDungeon) {
    final moltiplicatore = 1.0 + (livelloDungeon - livelloBase) * 0.12;
    return dannoBase * moltiplicatore.clamp(0.5, 50.0);
  }

  double difesaScalata(int livelloDungeon) {
    final moltiplicatore = 1.0 + (livelloDungeon - livelloBase) * 0.10;
    return difesaBase * moltiplicatore.clamp(0.5, 30.0);
  }
}

/// Dati specifici di un boss
class BossData extends EnemyData {
  final List<BossPhase> fasi;
  final String titolo; // es: "Re delle Formiche"
  final bool hasCutscene;
  final double dimensioneBoss;
  final List<String> attacchiSpeciali;
  final double chanceDropLeggendario;

  const BossData({
    required super.id,
    required super.nome,
    required super.descrizione,
    required super.livelloBase,
    required super.saluteBase,
    required super.dannoBase,
    required super.difesaBase,
    required super.velocitaBase,
    required super.rangeAttacco,
    required super.cooldownAttacco,
    required super.aiType,
    super.elemento,
    required super.rangoMinimo,
    required super.expRicompensa,
    required super.oroRicompensa,
    super.dropRateBonus = 0.2,
    super.puoEssereEstratto = true,
    super.abilitaSpeciali,
    required super.spriteKey,
    required this.fasi,
    required this.titolo,
    this.hasCutscene = true,
    this.dimensioneBoss = 2.0,
    this.attacchiSpeciali = const [],
    this.chanceDropLeggendario = 0.15,
  }) : super(dimensione: dimensioneBoss);
}

/// Fase di un boss fight
class BossPhase {
  final double sogliaSalute; // % salute per attivare la fase (1.0 = 100%)
  final double moltiplicatoreDanno;
  final double moltiplicatoreVelocita;
  final List<String> nuoviAttacchi;
  final String? dialogoFase;
  final bool invulnerabileDuranteTransizione;

  const BossPhase({
    required this.sogliaSalute,
    this.moltiplicatoreDanno = 1.0,
    this.moltiplicatoreVelocita = 1.0,
    this.nuoviAttacchi = const [],
    this.dialogoFase,
    this.invulnerabileDuranteTransizione = true,
  });
}
