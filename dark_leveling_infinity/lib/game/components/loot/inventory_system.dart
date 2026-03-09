/// Sistema di inventario e loot di Dark Leveling Infinity
/// Gestisce oggetti, equipaggiamento, drop e crafting
library;

import 'dart:developer' as dev;
import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../../../data/models/item_data.dart';
import '../../../data/models/enemy_data.dart';

/// Sistema di inventario completo
class InventorySystem {
  // Inventario del player
  final List<ItemInstance> _inventario = [];
  
  // Equipaggiamento indossato (slot -> item)
  final Map<ItemType, ItemInstance?> _equipaggiamento = {
    ItemType.arma: null,
    ItemType.armatura: null,
    ItemType.elmo: null,
    ItemType.guanti: null,
    ItemType.stivali: null,
    ItemType.anello: null,
    ItemType.collana: null,
  };

  // Capacità massima inventario
  int _capacitaMax = 50;

  // Database items statici
  static final List<ItemData> _databaseItems = _generaDatabaseItems();

  // Generatore casuale
  final Random _rng = Random();

  /// Aggiungi un item all'inventario
  bool aggiungiItem(String itemDataId, {int quantita = 1}) {
    final itemData = getItemDataById(itemDataId);
    if (itemData == null) {
      dev.log('[INVENTARIO] Item non trovato: $itemDataId');
      return false;
    }

    // Controlla se l'item è impilabile e già presente
    if (itemData.impilabile) {
      final esistente = _inventario.firstWhere(
        (i) => i.itemDataId == itemDataId,
        orElse: () => ItemInstance(instanceId: '', itemDataId: ''),
      );

      if (esistente.instanceId.isNotEmpty) {
        esistente.quantita += quantita;
        dev.log('[INVENTARIO] ${itemData.nome} x$quantita aggiunto (totale: ${esistente.quantita})');
        return true;
      }
    }

    // Controlla spazio nell'inventario
    if (_inventario.length >= _capacitaMax) {
      dev.log('[INVENTARIO] Inventario pieno!');
      return false;
    }

    // Crea nuova istanza
    final instance = ItemInstance(
      instanceId: '${itemDataId}_${DateTime.now().millisecondsSinceEpoch}',
      itemDataId: itemDataId,
      quantita: quantita,
    );

    _inventario.add(instance);
    dev.log('[INVENTARIO] ${itemData.nome} aggiunto all\'inventario');
    return true;
  }

  /// Rimuovi un item dall'inventario
  bool rimuoviItem(String instanceId, {int quantita = 1}) {
    final item = _inventario.firstWhere(
      (i) => i.instanceId == instanceId,
      orElse: () => ItemInstance(instanceId: '', itemDataId: ''),
    );

    if (item.instanceId.isEmpty) return false;

    item.quantita -= quantita;
    if (item.quantita <= 0) {
      _inventario.remove(item);
    }

    dev.log('[INVENTARIO] Item rimosso');
    return true;
  }

  /// Equipaggia un item
  bool equipaggia(String instanceId) {
    final item = _inventario.firstWhere(
      (i) => i.instanceId == instanceId,
      orElse: () => ItemInstance(instanceId: '', itemDataId: ''),
    );

    if (item.instanceId.isEmpty) return false;

    final itemData = getItemDataById(item.itemDataId);
    if (itemData == null) return false;

    // Controlla se il tipo è equipaggiabile
    if (!_equipaggiamento.containsKey(itemData.tipo)) {
      dev.log('[INVENTARIO] Questo item non è equipaggiabile');
      return false;
    }

    // Rimuovi l'item attualmente equipaggiato (se presente)
    final attuale = _equipaggiamento[itemData.tipo];
    if (attuale != null) {
      attuale.equipaggiato = false;
    }

    // Equipaggia il nuovo item
    item.equipaggiato = true;
    _equipaggiamento[itemData.tipo] = item;

    dev.log('[INVENTARIO] ${itemData.nome} equipaggiato!');
    return true;
  }

  /// Rimuovi equipaggiamento da uno slot
  bool rimuoviEquipaggiamento(ItemType slot) {
    final item = _equipaggiamento[slot];
    if (item == null) return false;

    item.equipaggiato = false;
    _equipaggiamento[slot] = null;

    dev.log('[INVENTARIO] Equipaggiamento rimosso dallo slot $slot');
    return true;
  }

  /// Genera loot da un nemico sconfitto
  List<ItemInstance> generaLoot(EnemyData nemico, {bool isBoss = false}) {
    dev.log('[LOOT] Generazione loot da ${nemico.nome}...');
    final loot = <ItemInstance>[];

    // Numero di drops basato sulla forza del nemico
    int numDrops = 1;
    if (isBoss) numDrops = 3 + _rng.nextInt(3); // 3-5 drops per boss
    else if (nemico.livelloBase > 100) numDrops = 1 + _rng.nextInt(2);

    for (int i = 0; i < numDrops; i++) {
      // Determina la rarità del drop
      final rarita = _determinaRarita(
        dropRateBonus: nemico.dropRateBonus,
        isBoss: isBoss,
      );

      // Trova un item appropriato
      final itemsPossibili = _databaseItems.where((item) =>
        item.rarita == rarita && item.livelloRichiesto <= nemico.livelloBase + 10,
      ).toList();

      if (itemsPossibili.isNotEmpty) {
        final itemData = itemsPossibili[_rng.nextInt(itemsPossibili.length)];
        final instance = ItemInstance(
          instanceId: '${itemData.id}_${DateTime.now().millisecondsSinceEpoch}_$i',
          itemDataId: itemData.id,
        );
        loot.add(instance);

        // Aggiungi direttamente all'inventario
        aggiungiItem(itemData.id);
      }
    }

    // Drop oro (sempre)
    dev.log('[LOOT] ${loot.length} items droppati da ${nemico.nome}');
    return loot;
  }

  /// Determina la rarità di un drop
  ItemRarity _determinaRarita({double dropRateBonus = 0, bool isBoss = false}) {
    double roll = _rng.nextDouble() - dropRateBonus;
    if (isBoss) roll -= 0.15; // Boss hanno drop migliori

    if (roll < ItemRarity.divino.dropRate) return ItemRarity.divino;
    if (roll < ItemRarity.mitico.dropRate) return ItemRarity.mitico;
    if (roll < ItemRarity.leggendario.dropRate) return ItemRarity.leggendario;
    if (roll < ItemRarity.epico.dropRate) return ItemRarity.epico;
    if (roll < ItemRarity.raro.dropRate) return ItemRarity.raro;
    if (roll < ItemRarity.nonComune.dropRate) return ItemRarity.nonComune;
    return ItemRarity.comune;
  }

  /// Calcola i bonus totali dall'equipaggiamento
  StatBonus calcolaBonusTotali() {
    int forza = 0, agilita = 0, vitalita = 0, intelligenza = 0, percezione = 0;
    double bonusSalute = 0, bonusMana = 0, bonusDanno = 0, bonusDifesa = 0;
    double bonusVelocita = 0, bonusCritico = 0, bonusEvasione = 0;

    for (final entry in _equipaggiamento.entries) {
      final item = entry.value;
      if (item == null) continue;

      final itemData = getItemDataById(item.itemDataId);
      if (itemData == null) continue;

      final bonus = itemData.bonus;
      forza += bonus.forza;
      agilita += bonus.agilita;
      vitalita += bonus.vitalita;
      intelligenza += bonus.intelligenza;
      percezione += bonus.percezione;
      bonusSalute += bonus.bonusSalute;
      bonusMana += bonus.bonusMana;
      bonusDanno += bonus.bonusDanno;
      bonusDifesa += bonus.bonusDifesa;
      bonusVelocita += bonus.bonusVelocita;
      bonusCritico += bonus.bonusCritico;
      bonusEvasione += bonus.bonusEvasione;
    }

    return StatBonus(
      forza: forza,
      agilita: agilita,
      vitalita: vitalita,
      intelligenza: intelligenza,
      percezione: percezione,
      bonusSalute: bonusSalute,
      bonusMana: bonusMana,
      bonusDanno: bonusDanno,
      bonusDifesa: bonusDifesa,
      bonusVelocita: bonusVelocita,
      bonusCritico: bonusCritico,
      bonusEvasione: bonusEvasione,
    );
  }

  /// Vendi un item
  int vendiItem(String instanceId) {
    final item = _inventario.firstWhere(
      (i) => i.instanceId == instanceId,
      orElse: () => ItemInstance(instanceId: '', itemDataId: ''),
    );

    if (item.instanceId.isEmpty) return 0;

    final itemData = getItemDataById(item.itemDataId);
    if (itemData == null) return 0;

    final prezzo = itemData.prezzoVendita * item.quantita;
    _inventario.remove(item);

    dev.log('[INVENTARIO] ${itemData.nome} venduto per $prezzo oro');
    return prezzo;
  }

  /// Ottieni l'inventario completo
  List<ItemInstance> get inventario => List.unmodifiable(_inventario);

  /// Ottieni l'equipaggiamento
  Map<ItemType, ItemInstance?> get equipaggiamento => Map.unmodifiable(_equipaggiamento);

  /// Spazio rimanente
  int get spazioRimanente => _capacitaMax - _inventario.length;

  /// Ottieni dati di un item dal database
  static ItemData? getItemDataById(String id) {
    try {
      return _databaseItems.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Serializzazione
  Map<String, dynamic> toJson() => {
    'inventario': _inventario.map((i) => i.toJson()).toList(),
    'equipaggiamento': _equipaggiamento.map(
      (key, value) => MapEntry(key.index.toString(), value?.toJson()),
    ),
  };

  /// Deserializzazione
  void fromJson(Map<String, dynamic> json) {
    _inventario.clear();
    if (json['inventario'] != null) {
      for (final item in json['inventario'] as List) {
        _inventario.add(ItemInstance.fromJson(item as Map<String, dynamic>));
      }
    }
  }

  /// Genera il database completo degli items
  static List<ItemData> _generaDatabaseItems() {
    return [
      // === ARMI ===
      // Spade
      const ItemData(id: 'spada_arrugginita', nome: 'Spada Arrugginita', descrizione: 'Una vecchia spada ancora funzionante.', tipo: ItemType.arma, rarita: ItemRarity.comune, tipoArma: WeaponType.spada, bonus: StatBonus(bonusDanno: 5), prezzoVendita: 10, prezzoAcquisto: 50, spriteKey: 'spada_arrugginita'),
      const ItemData(id: 'spada_acciaio', nome: 'Spada d\'Acciaio', descrizione: 'Una spada ben forgiata.', tipo: ItemType.arma, rarita: ItemRarity.nonComune, livelloRichiesto: 5, tipoArma: WeaponType.spada, bonus: StatBonus(bonusDanno: 15, forza: 2), prezzoVendita: 50, prezzoAcquisto: 200, spriteKey: 'spada_acciaio'),
      const ItemData(id: 'lama_ombra', nome: 'Lama dell\'Ombra', descrizione: 'Una lama avvolta nell\'oscurità.', tipo: ItemType.arma, rarita: ItemRarity.raro, livelloRichiesto: 15, tipoArma: WeaponType.spada, bonus: StatBonus(bonusDanno: 35, forza: 5, agilita: 3), prezzoVendita: 200, prezzoAcquisto: 800, spriteKey: 'lama_ombra'),
      const ItemData(id: 'katana_cacciatore', nome: 'Katana del Cacciatore', descrizione: 'Arma leggendaria dei cacciatori S-Rank.', tipo: ItemType.arma, rarita: ItemRarity.epico, livelloRichiesto: 30, tipoArma: WeaponType.katana, bonus: StatBonus(bonusDanno: 70, forza: 10, agilita: 8, bonusCritico: 0.05), prezzoVendita: 1000, prezzoAcquisto: 5000, spriteKey: 'katana_cacciatore'),
      const ItemData(id: 'lama_monarca', nome: 'Lama del Monarca', descrizione: 'La spada del Monarca delle Ombre.', tipo: ItemType.arma, rarita: ItemRarity.leggendario, livelloRichiesto: 100, tipoArma: WeaponType.spada, bonus: StatBonus(bonusDanno: 200, forza: 30, agilita: 20, bonusCritico: 0.15), prezzoVendita: 10000, prezzoAcquisto: 50000, spriteKey: 'lama_monarca'),
      const ItemData(id: 'pugnale_assassino', nome: 'Pugnale dell\'Assassino', descrizione: 'Pugnale veloce per colpi rapidi.', tipo: ItemType.arma, rarita: ItemRarity.raro, livelloRichiesto: 20, tipoArma: WeaponType.pugnale, bonus: StatBonus(bonusDanno: 25, agilita: 8, bonusCritico: 0.08), prezzoVendita: 180, prezzoAcquisto: 700, spriteKey: 'pugnale_assassino'),
      const ItemData(id: 'ascia_berserker', nome: 'Ascia del Berserker', descrizione: 'Ascia pesante per colpi devastanti.', tipo: ItemType.arma, rarita: ItemRarity.epico, livelloRichiesto: 40, tipoArma: WeaponType.ascia, bonus: StatBonus(bonusDanno: 90, forza: 15), prezzoVendita: 1500, prezzoAcquisto: 7000, spriteKey: 'ascia_berserker'),
      const ItemData(id: 'bastone_arcano', nome: 'Bastone Arcano', descrizione: 'Bastone che amplifica la magia oscura.', tipo: ItemType.arma, rarita: ItemRarity.raro, livelloRichiesto: 15, tipoArma: WeaponType.bastone, bonus: StatBonus(bonusDanno: 20, intelligenza: 10, bonusMana: 50), prezzoVendita: 250, prezzoAcquisto: 900, spriteKey: 'bastone_arcano'),
      const ItemData(id: 'falce_morte', nome: 'Falce della Morte', descrizione: 'L\'arma della morte stessa.', tipo: ItemType.arma, rarita: ItemRarity.mitico, livelloRichiesto: 200, tipoArma: WeaponType.falce, bonus: StatBonus(bonusDanno: 500, forza: 50, agilita: 30, bonusCritico: 0.25), prezzoVendita: 50000, prezzoAcquisto: 200000, spriteKey: 'falce_morte'),
      const ItemData(id: 'pugni_ombra', nome: 'Guanti dell\'Ombra', descrizione: 'Guanti che concentrano l\'energia oscura nei pugni.', tipo: ItemType.arma, rarita: ItemRarity.epico, livelloRichiesto: 50, tipoArma: WeaponType.pugni, bonus: StatBonus(bonusDanno: 60, forza: 8, agilita: 12, bonusCritico: 0.10), prezzoVendita: 2000, prezzoAcquisto: 8000, spriteKey: 'pugni_ombra'),

      // === ARMATURE ===
      const ItemData(id: 'armatura_cuoio', nome: 'Armatura di Cuoio', descrizione: 'Protezione base per cacciatori novizi.', tipo: ItemType.armatura, rarita: ItemRarity.comune, bonus: StatBonus(bonusDifesa: 5, bonusSalute: 20), prezzoVendita: 15, prezzoAcquisto: 60, spriteKey: 'armatura_cuoio'),
      const ItemData(id: 'armatura_acciaio', nome: 'Armatura d\'Acciaio', descrizione: 'Armatura solida e affidabile.', tipo: ItemType.armatura, rarita: ItemRarity.nonComune, livelloRichiesto: 10, bonus: StatBonus(bonusDifesa: 15, bonusSalute: 50, vitalita: 3), prezzoVendita: 80, prezzoAcquisto: 300, spriteKey: 'armatura_acciaio'),
      const ItemData(id: 'armatura_ombra', nome: 'Armatura dell\'Ombra', descrizione: 'Armatura fusa con l\'essenza delle ombre.', tipo: ItemType.armatura, rarita: ItemRarity.raro, livelloRichiesto: 25, bonus: StatBonus(bonusDifesa: 35, bonusSalute: 100, vitalita: 5, bonusEvasione: 0.03), prezzoVendita: 300, prezzoAcquisto: 1200, spriteKey: 'armatura_ombra'),
      const ItemData(id: 'armatura_monarca', nome: 'Armatura del Monarca', descrizione: 'L\'armatura suprema del Monarca delle Ombre.', tipo: ItemType.armatura, rarita: ItemRarity.leggendario, livelloRichiesto: 100, bonus: StatBonus(bonusDifesa: 150, bonusSalute: 500, vitalita: 25, bonusEvasione: 0.10), prezzoVendita: 15000, prezzoAcquisto: 60000, spriteKey: 'armatura_monarca'),

      // === CONSUMABILI ===
      const ItemData(id: 'pozione_hp_piccola', nome: 'Pozione di Vita Piccola', descrizione: 'Ripristina 50 HP.', tipo: ItemType.consumabile, rarita: ItemRarity.comune, impilabile: true, quantitaMax: 99, prezzoVendita: 5, prezzoAcquisto: 20, spriteKey: 'pozione_hp_piccola', effetti: [ItemEffect(id: 'cura_50', nome: 'Cura', descrizione: '+50 HP', valore: 50)]),
      const ItemData(id: 'pozione_hp_media', nome: 'Pozione di Vita Media', descrizione: 'Ripristina 200 HP.', tipo: ItemType.consumabile, rarita: ItemRarity.nonComune, livelloRichiesto: 10, impilabile: true, quantitaMax: 99, prezzoVendita: 20, prezzoAcquisto: 80, spriteKey: 'pozione_hp_media', effetti: [ItemEffect(id: 'cura_200', nome: 'Cura', descrizione: '+200 HP', valore: 200)]),
      const ItemData(id: 'pozione_hp_grande', nome: 'Pozione di Vita Grande', descrizione: 'Ripristina 500 HP.', tipo: ItemType.consumabile, rarita: ItemRarity.raro, livelloRichiesto: 30, impilabile: true, quantitaMax: 50, prezzoVendita: 50, prezzoAcquisto: 200, spriteKey: 'pozione_hp_grande', effetti: [ItemEffect(id: 'cura_500', nome: 'Cura', descrizione: '+500 HP', valore: 500)]),
      const ItemData(id: 'pozione_mp_piccola', nome: 'Pozione di Mana Piccola', descrizione: 'Ripristina 30 MP.', tipo: ItemType.consumabile, rarita: ItemRarity.comune, impilabile: true, quantitaMax: 99, prezzoVendita: 5, prezzoAcquisto: 25, spriteKey: 'pozione_mp_piccola', effetti: [ItemEffect(id: 'mana_30', nome: 'Mana', descrizione: '+30 MP', valore: 30)]),
      const ItemData(id: 'pozione_mp_media', nome: 'Pozione di Mana Media', descrizione: 'Ripristina 100 MP.', tipo: ItemType.consumabile, rarita: ItemRarity.nonComune, livelloRichiesto: 10, impilabile: true, quantitaMax: 99, prezzoVendita: 20, prezzoAcquisto: 90, spriteKey: 'pozione_mp_media', effetti: [ItemEffect(id: 'mana_100', nome: 'Mana', descrizione: '+100 MP', valore: 100)]),
      const ItemData(id: 'elisir_potere', nome: 'Elisir del Potere', descrizione: '+50% danno per 60 secondi.', tipo: ItemType.consumabile, rarita: ItemRarity.epico, livelloRichiesto: 30, impilabile: true, quantitaMax: 10, prezzoVendita: 100, prezzoAcquisto: 500, spriteKey: 'elisir_potere', effetti: [ItemEffect(id: 'potere_50', nome: 'Potere', descrizione: '+50% Danno', valore: 0.5, durata: 60)]),

      // === MATERIALI ===
      const ItemData(id: 'frammento_ombra', nome: 'Frammento d\'Ombra', descrizione: 'Essenza cristallizzata dell\'oscurità.', tipo: ItemType.materiale, rarita: ItemRarity.comune, impilabile: true, quantitaMax: 999, prezzoVendita: 2, spriteKey: 'frammento_ombra'),
      const ItemData(id: 'cristallo_mana', nome: 'Cristallo di Mana', descrizione: 'Un cristallo che pulsa di energia magica.', tipo: ItemType.materiale, rarita: ItemRarity.nonComune, impilabile: true, quantitaMax: 999, prezzoVendita: 10, spriteKey: 'cristallo_mana'),
      const ItemData(id: 'nucleo_boss', nome: 'Nucleo di Boss', descrizione: 'Il nucleo di energia di un potente boss.', tipo: ItemType.materiale, rarita: ItemRarity.raro, impilabile: true, quantitaMax: 99, prezzoVendita: 100, spriteKey: 'nucleo_boss'),
      const ItemData(id: 'essenza_monarca', nome: 'Essenza del Monarca', descrizione: 'L\'essenza pura di un Monarca.', tipo: ItemType.materiale, rarita: ItemRarity.leggendario, impilabile: true, quantitaMax: 10, prezzoVendita: 5000, spriteKey: 'essenza_monarca'),
    ];
  }
}
