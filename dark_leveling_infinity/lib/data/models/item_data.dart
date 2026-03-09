/// Modello dati per gli oggetti del gioco
/// Armi, armature, consumabili, materiali per il crafting
library;

import '../../core/constants/game_constants.dart';

/// Tipo di oggetto
enum ItemType {
  arma,
  armatura,
  elmo,
  guanti,
  stivali,
  anello,
  collana,
  consumabile,
  materiale,
  chiave,
  gemma,
  runa,
}

/// Sottotipo di arma
enum WeaponType {
  spada,
  pugnale,
  ascia,
  lancia,
  martello,
  arco,
  bastone,
  katana,
  falce,
  pugni,
}

/// Effetto di un oggetto sulle stats
class StatBonus {
  final int forza;
  final int agilita;
  final int vitalita;
  final int intelligenza;
  final int percezione;
  final double bonusSalute;
  final double bonusMana;
  final double bonusDanno;
  final double bonusDifesa;
  final double bonusVelocita;
  final double bonusCritico;
  final double bonusEvasione;

  const StatBonus({
    this.forza = 0,
    this.agilita = 0,
    this.vitalita = 0,
    this.intelligenza = 0,
    this.percezione = 0,
    this.bonusSalute = 0,
    this.bonusMana = 0,
    this.bonusDanno = 0,
    this.bonusDifesa = 0,
    this.bonusVelocita = 0,
    this.bonusCritico = 0,
    this.bonusEvasione = 0,
  });

  Map<String, dynamic> toJson() => {
    'forza': forza,
    'agilita': agilita,
    'vitalita': vitalita,
    'intelligenza': intelligenza,
    'percezione': percezione,
    'bonusSalute': bonusSalute,
    'bonusMana': bonusMana,
    'bonusDanno': bonusDanno,
    'bonusDifesa': bonusDifesa,
    'bonusVelocita': bonusVelocita,
    'bonusCritico': bonusCritico,
    'bonusEvasione': bonusEvasione,
  };

  factory StatBonus.fromJson(Map<String, dynamic> json) => StatBonus(
    forza: json['forza'] as int? ?? 0,
    agilita: json['agilita'] as int? ?? 0,
    vitalita: json['vitalita'] as int? ?? 0,
    intelligenza: json['intelligenza'] as int? ?? 0,
    percezione: json['percezione'] as int? ?? 0,
    bonusSalute: (json['bonusSalute'] as num?)?.toDouble() ?? 0,
    bonusMana: (json['bonusMana'] as num?)?.toDouble() ?? 0,
    bonusDanno: (json['bonusDanno'] as num?)?.toDouble() ?? 0,
    bonusDifesa: (json['bonusDifesa'] as num?)?.toDouble() ?? 0,
    bonusVelocita: (json['bonusVelocita'] as num?)?.toDouble() ?? 0,
    bonusCritico: (json['bonusCritico'] as num?)?.toDouble() ?? 0,
    bonusEvasione: (json['bonusEvasione'] as num?)?.toDouble() ?? 0,
  );
}

/// Effetto speciale di un oggetto
class ItemEffect {
  final String id;
  final String nome;
  final String descrizione;
  final double valore;
  final double durata; // secondi, 0 = permanente

  const ItemEffect({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.valore,
    this.durata = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descrizione': descrizione,
    'valore': valore,
    'durata': durata,
  };

  factory ItemEffect.fromJson(Map<String, dynamic> json) => ItemEffect(
    id: json['id'] as String,
    nome: json['nome'] as String,
    descrizione: json['descrizione'] as String,
    valore: (json['valore'] as num).toDouble(),
    durata: (json['durata'] as num?)?.toDouble() ?? 0,
  );
}

/// Dati di un oggetto
class ItemData {
  final String id;
  final String nome;
  final String descrizione;
  final ItemType tipo;
  final ItemRarity rarita;
  final int livelloRichiesto;
  final StatBonus bonus;
  final List<ItemEffect> effetti;
  final int prezzoVendita;
  final int prezzoAcquisto;
  final bool impilabile;
  final int quantitaMax; // per oggetti impilabili
  final String spriteKey;
  final WeaponType? tipoArma;

  const ItemData({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.tipo,
    required this.rarita,
    this.livelloRichiesto = 1,
    this.bonus = const StatBonus(),
    this.effetti = const [],
    this.prezzoVendita = 0,
    this.prezzoAcquisto = 0,
    this.impilabile = false,
    this.quantitaMax = 1,
    required this.spriteKey,
    this.tipoArma,
  });
}

/// Istanza di un oggetto nell'inventario (con quantità e stato)
class ItemInstance {
  final String instanceId; // ID unico per questa istanza
  final String itemDataId; // Riferimento all'ItemData
  int quantita;
  bool equipaggiato;
  int potenziamento; // livello di upgrade (+1, +2, etc.)

  ItemInstance({
    required this.instanceId,
    required this.itemDataId,
    this.quantita = 1,
    this.equipaggiato = false,
    this.potenziamento = 0,
  });

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'itemDataId': itemDataId,
    'quantita': quantita,
    'equipaggiato': equipaggiato,
    'potenziamento': potenziamento,
  };

  factory ItemInstance.fromJson(Map<String, dynamic> json) => ItemInstance(
    instanceId: json['instanceId'] as String,
    itemDataId: json['itemDataId'] as String,
    quantita: json['quantita'] as int? ?? 1,
    equipaggiato: json['equipaggiato'] as bool? ?? false,
    potenziamento: json['potenziamento'] as int? ?? 0,
  );
}

/// Ricetta di crafting
class CraftingRecipe {
  final String id;
  final String nomeRicetta;
  final String risultatoItemId;
  final Map<String, int> materialiRichiesti; // itemId -> quantità
  final int oroRichiesto;
  final int livelloRichiesto;

  const CraftingRecipe({
    required this.id,
    required this.nomeRicetta,
    required this.risultatoItemId,
    required this.materialiRichiesti,
    this.oroRichiesto = 0,
    this.livelloRichiesto = 1,
  });
}
