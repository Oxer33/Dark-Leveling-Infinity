/// Servizio di salvataggio persistente per Dark Leveling Infinity
/// Gestisce il salvataggio e caricamento dei dati di gioco tramite SharedPreferences
library;

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/player_data.dart';

/// Chiavi di salvataggio
class SaveKeys {
  static const String playerData = 'player_data';
  static const String questData = 'quest_data';
  static const String shadowArmy = 'shadow_army';
  static const String settings = 'settings';
  static const String hasSaveGame = 'has_save_game';
  static const String firstLaunch = 'first_launch';
}

/// Servizio per il salvataggio/caricamento dei dati di gioco
class SaveService {
  static SaveService? _instance;
  SharedPreferences? _prefs;

  SaveService._();

  /// Singleton instance
  static SaveService get instance {
    _instance ??= SaveService._();
    return _instance!;
  }

  /// Inizializza il servizio
  Future<void> inizializza() async {
    dev.log('[SAVE] Inizializzazione servizio salvataggio...');
    _prefs = await SharedPreferences.getInstance();
    dev.log('[SAVE] Servizio salvataggio pronto!');
  }

  /// Salva i dati del player
  Future<bool> salvaPlayerData(PlayerData data) async {
    try {
      final json = jsonEncode(data.toJson());
      await _prefs?.setString(SaveKeys.playerData, json);
      await _prefs?.setBool(SaveKeys.hasSaveGame, true);
      dev.log('[SAVE] Dati player salvati con successo!');
      return true;
    } catch (e) {
      dev.log('[SAVE] ERRORE salvataggio player: $e');
      return false;
    }
  }

  /// Carica i dati del player
  PlayerData? caricaPlayerData() {
    try {
      final json = _prefs?.getString(SaveKeys.playerData);
      if (json == null) {
        dev.log('[SAVE] Nessun salvataggio trovato');
        return null;
      }

      final data = PlayerData.fromJson(jsonDecode(json) as Map<String, dynamic>);
      dev.log('[SAVE] Dati player caricati! Livello: ${data.livello}, Rango: ${data.rango.nome}');
      return data;
    } catch (e) {
      dev.log('[SAVE] ERRORE caricamento player: $e');
      return null;
    }
  }

  /// Salva i dati delle quest
  Future<bool> salvaQuestData(List<Map<String, dynamic>> quests) async {
    try {
      final json = jsonEncode(quests);
      await _prefs?.setString(SaveKeys.questData, json);
      dev.log('[SAVE] Dati quest salvati!');
      return true;
    } catch (e) {
      dev.log('[SAVE] ERRORE salvataggio quest: $e');
      return false;
    }
  }

  /// Carica i dati delle quest
  List<Map<String, dynamic>>? caricaQuestData() {
    try {
      final json = _prefs?.getString(SaveKeys.questData);
      if (json == null) return null;

      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      dev.log('[SAVE] ERRORE caricamento quest: $e');
      return null;
    }
  }

  /// Salva le impostazioni
  Future<void> salvaImpostazioni(Map<String, dynamic> settings) async {
    try {
      final json = jsonEncode(settings);
      await _prefs?.setString(SaveKeys.settings, json);
      dev.log('[SAVE] Impostazioni salvate!');
    } catch (e) {
      dev.log('[SAVE] ERRORE salvataggio impostazioni: $e');
    }
  }

  /// Carica le impostazioni
  Map<String, dynamic> caricaImpostazioni() {
    try {
      final json = _prefs?.getString(SaveKeys.settings);
      if (json == null) {
        return _impostazioniDefault();
      }
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      dev.log('[SAVE] ERRORE caricamento impostazioni: $e');
      return _impostazioniDefault();
    }
  }

  /// Controlla se esiste un salvataggio
  bool hasSalvataggio() {
    return _prefs?.getBool(SaveKeys.hasSaveGame) ?? false;
  }

  /// Controlla se è il primo avvio
  bool isPrimoAvvio() {
    return _prefs?.getBool(SaveKeys.firstLaunch) ?? true;
  }

  /// Marca il primo avvio come completato
  Future<void> marcaPrimoAvvioCompletato() async {
    await _prefs?.setBool(SaveKeys.firstLaunch, false);
  }

  /// Cancella tutti i dati di salvataggio
  Future<void> cancellaTutto() async {
    dev.log('[SAVE] Cancellazione di tutti i dati...');
    await _prefs?.clear();
    dev.log('[SAVE] Tutti i dati cancellati!');
  }

  /// Impostazioni di default
  Map<String, dynamic> _impostazioniDefault() {
    return {
      'volumeMusica': 0.7,
      'volumeEffetti': 0.8,
      'vibrazioni': true,
      'qualitaGrafica': 'alta',
      'mostraFPS': false,
      'mostraDanni': true,
      'joystickLato': 'sinistro', // sinistro o destro
    };
  }
}
