/// Sistema Achievements e Daily Login Rewards per Dark Leveling Infinity
/// Gestisce trofei, ricompense giornaliere e progressione a lungo termine
library;

import 'dart:developer' as dev;

/// Categoria dell'achievement
enum AchievementCategory { combattimento, esplorazione, ombre, progressione, collezione }

/// Singolo achievement/trofeo
class Achievement {
  final String id;
  final String titolo;
  final String descrizione;
  final AchievementCategory categoria;
  final int obiettivo; // valore da raggiungere
  int progresso; // valore corrente
  bool sbloccato;
  final int gemmeRicompensa;
  final int oroRicompensa;
  final String? iconaId;

  Achievement({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.categoria,
    required this.obiettivo,
    this.progresso = 0,
    this.sbloccato = false,
    this.gemmeRicompensa = 0,
    this.oroRicompensa = 0,
    this.iconaId,
  });

  double get percentuale => (progresso / obiettivo).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id, 'progresso': progresso, 'sbloccato': sbloccato,
  };
}

/// Ricompensa del login giornaliero
class DailyReward {
  final int giorno; // 1-30
  final int gemme;
  final int oro;
  final String? itemId;
  final String descrizione;
  bool riscosso;

  DailyReward({
    required this.giorno,
    this.gemme = 0,
    this.oro = 0,
    this.itemId,
    required this.descrizione,
    this.riscosso = false,
  });
}

/// Sistema di achievements e daily rewards
class AchievementSystem {
  final List<Achievement> _achievements = [];
  final List<DailyReward> _dailyRewards = [];
  int _giornoCorrente = 1;
  DateTime? _ultimoLogin;
  int _loginConsecutivi = 0;

  // Callback
  Function(Achievement)? onAchievementSbloccato;
  Function(DailyReward)? onDailyRewardDisponibile;

  AchievementSystem() {
    _inizializzaAchievements();
    _inizializzaDailyRewards();
  }

  void _inizializzaAchievements() {
    _achievements.addAll([
      // === COMBATTIMENTO ===
      Achievement(id: 'kill_10', titolo: 'Primo Sangue', descrizione: 'Sconfiggi 10 nemici', categoria: AchievementCategory.combattimento, obiettivo: 10, gemmeRicompensa: 5, oroRicompensa: 100),
      Achievement(id: 'kill_100', titolo: 'Cacciatore Novizio', descrizione: 'Sconfiggi 100 nemici', categoria: AchievementCategory.combattimento, obiettivo: 100, gemmeRicompensa: 15, oroRicompensa: 500),
      Achievement(id: 'kill_1000', titolo: 'Macchina da Guerra', descrizione: 'Sconfiggi 1.000 nemici', categoria: AchievementCategory.combattimento, obiettivo: 1000, gemmeRicompensa: 50, oroRicompensa: 2000),
      Achievement(id: 'kill_10000', titolo: 'Leggenda Vivente', descrizione: 'Sconfiggi 10.000 nemici', categoria: AchievementCategory.combattimento, obiettivo: 10000, gemmeRicompensa: 200, oroRicompensa: 10000),
      Achievement(id: 'boss_1', titolo: 'Uccisore di Boss', descrizione: 'Sconfiggi il tuo primo boss', categoria: AchievementCategory.combattimento, obiettivo: 1, gemmeRicompensa: 20, oroRicompensa: 500),
      Achievement(id: 'boss_10', titolo: 'Cacciatore di Boss', descrizione: 'Sconfiggi 10 boss', categoria: AchievementCategory.combattimento, obiettivo: 10, gemmeRicompensa: 50, oroRicompensa: 2000),
      Achievement(id: 'boss_30', titolo: 'Flagello dei Boss', descrizione: 'Sconfiggi tutti i 30 boss unici', categoria: AchievementCategory.combattimento, obiettivo: 30, gemmeRicompensa: 500, oroRicompensa: 50000),
      Achievement(id: 'combo_20', titolo: 'Combo Starter', descrizione: 'Raggiungi una combo di 20', categoria: AchievementCategory.combattimento, obiettivo: 20, gemmeRicompensa: 10, oroRicompensa: 200),
      Achievement(id: 'combo_50', titolo: 'Combo Master', descrizione: 'Raggiungi una combo di 50', categoria: AchievementCategory.combattimento, obiettivo: 50, gemmeRicompensa: 30, oroRicompensa: 1000),
      Achievement(id: 'combo_100', titolo: 'Combo Infinita', descrizione: 'Raggiungi una combo di 100', categoria: AchievementCategory.combattimento, obiettivo: 100, gemmeRicompensa: 100, oroRicompensa: 5000),
      Achievement(id: 'nodamage_gate', titolo: 'Intoccabile', descrizione: 'Completa un Gate senza subire danni', categoria: AchievementCategory.combattimento, obiettivo: 1, gemmeRicompensa: 50, oroRicompensa: 3000),

      // === ESPLORAZIONE ===
      Achievement(id: 'gate_1', titolo: 'Esploratore', descrizione: 'Completa il primo Gate', categoria: AchievementCategory.esplorazione, obiettivo: 1, gemmeRicompensa: 10, oroRicompensa: 200),
      Achievement(id: 'gate_50', titolo: 'Veterano dei Gate', descrizione: 'Completa 50 Gate', categoria: AchievementCategory.esplorazione, obiettivo: 50, gemmeRicompensa: 50, oroRicompensa: 3000),
      Achievement(id: 'gate_s', titolo: 'Gate S Completato', descrizione: 'Completa un Gate di rango S', categoria: AchievementCategory.esplorazione, obiettivo: 1, gemmeRicompensa: 200, oroRicompensa: 20000),
      Achievement(id: 'gate_monarch', titolo: 'Sfidante dei Monarchi', descrizione: 'Completa un Gate Monarca', categoria: AchievementCategory.esplorazione, obiettivo: 1, gemmeRicompensa: 500, oroRicompensa: 100000),
      Achievement(id: 'biomi_5', titolo: 'Scopritore', descrizione: 'Visita 5 biomi diversi', categoria: AchievementCategory.esplorazione, obiettivo: 5, gemmeRicompensa: 20, oroRicompensa: 1000),
      Achievement(id: 'biomi_10', titolo: 'Esploratore Supremo', descrizione: 'Visita tutti i 10 biomi', categoria: AchievementCategory.esplorazione, obiettivo: 10, gemmeRicompensa: 100, oroRicompensa: 10000),

      // === OMBRE ===
      Achievement(id: 'shadow_1', titolo: 'Prima Ombra', descrizione: 'Estrai la tua prima ombra', categoria: AchievementCategory.ombre, obiettivo: 1, gemmeRicompensa: 15, oroRicompensa: 300),
      Achievement(id: 'shadow_10', titolo: 'Comandante delle Ombre', descrizione: 'Estrai 10 ombre', categoria: AchievementCategory.ombre, obiettivo: 10, gemmeRicompensa: 30, oroRicompensa: 1000),
      Achievement(id: 'shadow_50', titolo: 'Esercito Crescente', descrizione: 'Estrai 50 ombre', categoria: AchievementCategory.ombre, obiettivo: 50, gemmeRicompensa: 100, oroRicompensa: 5000),
      Achievement(id: 'shadow_knight', titolo: 'Primo Cavaliere', descrizione: 'Promuovi un\'ombra a Cavaliere', categoria: AchievementCategory.ombre, obiettivo: 1, gemmeRicompensa: 50, oroRicompensa: 3000),
      Achievement(id: 'shadow_marshal', titolo: 'Maresciallo dell\'Ombra', descrizione: 'Promuovi un\'ombra a Maresciallo', categoria: AchievementCategory.ombre, obiettivo: 1, gemmeRicompensa: 200, oroRicompensa: 20000),

      // === PROGRESSIONE ===
      Achievement(id: 'level_10', titolo: 'Rango D', descrizione: 'Raggiungi il livello 10', categoria: AchievementCategory.progressione, obiettivo: 10, gemmeRicompensa: 10, oroRicompensa: 300),
      Achievement(id: 'level_25', titolo: 'Rango C', descrizione: 'Raggiungi il livello 25', categoria: AchievementCategory.progressione, obiettivo: 25, gemmeRicompensa: 20, oroRicompensa: 800),
      Achievement(id: 'level_50', titolo: 'Rango B', descrizione: 'Raggiungi il livello 50', categoria: AchievementCategory.progressione, obiettivo: 50, gemmeRicompensa: 40, oroRicompensa: 2000),
      Achievement(id: 'level_100', titolo: 'Rango A', descrizione: 'Raggiungi il livello 100', categoria: AchievementCategory.progressione, obiettivo: 100, gemmeRicompensa: 100, oroRicompensa: 5000),
      Achievement(id: 'level_200', titolo: 'Rango S', descrizione: 'Raggiungi il livello 200', categoria: AchievementCategory.progressione, obiettivo: 200, gemmeRicompensa: 200, oroRicompensa: 15000),
      Achievement(id: 'level_500', titolo: 'Nazionale', descrizione: 'Raggiungi il livello 500', categoria: AchievementCategory.progressione, obiettivo: 500, gemmeRicompensa: 500, oroRicompensa: 50000),
      Achievement(id: 'level_999', titolo: 'Monarca Supremo', descrizione: 'Raggiungi il livello 999', categoria: AchievementCategory.progressione, obiettivo: 999, gemmeRicompensa: 2000, oroRicompensa: 500000),
      Achievement(id: 'skill_all', titolo: 'Maestro delle Arti', descrizione: 'Sblocca tutte le abilità', categoria: AchievementCategory.progressione, obiettivo: 32, gemmeRicompensa: 300, oroRicompensa: 30000),

      // === COLLEZIONE ===
      Achievement(id: 'item_epic', titolo: 'Primo Epico', descrizione: 'Ottieni un oggetto Epico', categoria: AchievementCategory.collezione, obiettivo: 1, gemmeRicompensa: 15, oroRicompensa: 500),
      Achievement(id: 'item_legend', titolo: 'Leggenda Trovata', descrizione: 'Ottieni un oggetto Leggendario', categoria: AchievementCategory.collezione, obiettivo: 1, gemmeRicompensa: 50, oroRicompensa: 3000),
      Achievement(id: 'item_mythic', titolo: 'Mitico!', descrizione: 'Ottieni un oggetto Mitico', categoria: AchievementCategory.collezione, obiettivo: 1, gemmeRicompensa: 200, oroRicompensa: 20000),
      Achievement(id: 'item_divine', titolo: 'Tocco Divino', descrizione: 'Ottieni un oggetto Divino', categoria: AchievementCategory.collezione, obiettivo: 1, gemmeRicompensa: 1000, oroRicompensa: 100000),
      Achievement(id: 'gold_100k', titolo: 'Ricco', descrizione: 'Accumula 100.000 oro', categoria: AchievementCategory.collezione, obiettivo: 100000, gemmeRicompensa: 50, oroRicompensa: 10000),
      Achievement(id: 'gold_1m', titolo: 'Milionario', descrizione: 'Accumula 1.000.000 oro', categoria: AchievementCategory.collezione, obiettivo: 1000000, gemmeRicompensa: 200, oroRicompensa: 100000),
      Achievement(id: 'login_7', titolo: 'Cacciatore Fedele', descrizione: 'Accedi per 7 giorni consecutivi', categoria: AchievementCategory.collezione, obiettivo: 7, gemmeRicompensa: 30, oroRicompensa: 1000),
      Achievement(id: 'login_30', titolo: 'Dedizione Totale', descrizione: 'Accedi per 30 giorni consecutivi', categoria: AchievementCategory.collezione, obiettivo: 30, gemmeRicompensa: 200, oroRicompensa: 20000),
    ]);

    dev.log('[ACHIEVEMENTS] ${_achievements.length} achievements inizializzati');
  }

  void _inizializzaDailyRewards() {
    for (int giorno = 1; giorno <= 30; giorno++) {
      int gemme = 5 + (giorno ~/ 3) * 5;
      int oro = 100 + giorno * 50;

      // Bonus ogni 7 giorni
      if (giorno % 7 == 0) {
        gemme *= 3;
        oro *= 3;
      }

      // Bonus giorno 30
      if (giorno == 30) {
        gemme = 200;
        oro = 10000;
      }

      _dailyRewards.add(DailyReward(
        giorno: giorno,
        gemme: gemme,
        oro: oro,
        descrizione: 'Giorno $giorno',
      ));
    }

    dev.log('[DAILY] ${_dailyRewards.length} daily rewards inizializzati');
  }

  /// Aggiorna il progresso di un achievement
  void aggiornaProgresso(String id, int valore) {
    for (final achievement in _achievements) {
      if (achievement.id == id && !achievement.sbloccato) {
        achievement.progresso = valore;
        if (achievement.progresso >= achievement.obiettivo) {
          achievement.sbloccato = true;
          dev.log('[ACHIEVEMENTS] Sbloccato: ${achievement.titolo}!');
          onAchievementSbloccato?.call(achievement);
        }
      }
    }
  }

  /// Incrementa il progresso di un achievement
  void incrementaProgresso(String id, {int quantita = 1}) {
    for (final achievement in _achievements) {
      if (achievement.id == id && !achievement.sbloccato) {
        achievement.progresso += quantita;
        if (achievement.progresso >= achievement.obiettivo) {
          achievement.sbloccato = true;
          dev.log('[ACHIEVEMENTS] Sbloccato: ${achievement.titolo}!');
          onAchievementSbloccato?.call(achievement);
        }
      }
    }
  }

  /// Controlla il login giornaliero
  DailyReward? controllaLogin() {
    final ora = DateTime.now();

    if (_ultimoLogin != null) {
      final differenza = ora.difference(_ultimoLogin!);
      if (differenza.inHours < 24) {
        return null; // Già loggato oggi
      }
      if (differenza.inHours > 48) {
        _loginConsecutivi = 0; // Reset se salti un giorno
        _giornoCorrente = 1;
      }
    }

    _ultimoLogin = ora;
    _loginConsecutivi++;

    // Aggiorna achievement login
    aggiornaProgresso('login_7', _loginConsecutivi);
    aggiornaProgresso('login_30', _loginConsecutivi);

    if (_giornoCorrente <= _dailyRewards.length) {
      final reward = _dailyRewards[_giornoCorrente - 1];
      _giornoCorrente++;
      if (_giornoCorrente > 30) _giornoCorrente = 1;

      dev.log('[DAILY] Login giorno $_loginConsecutivi, ricompensa: ${reward.gemme} gemme, ${reward.oro} oro');
      onDailyRewardDisponibile?.call(reward);
      return reward;
    }

    return null;
  }

  /// Ottieni tutti gli achievements
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  /// Ottieni achievements per categoria
  List<Achievement> getPerCategoria(AchievementCategory cat) =>
      _achievements.where((a) => a.categoria == cat).toList();

  /// Ottieni achievements sbloccati
  List<Achievement> get sbloccati => _achievements.where((a) => a.sbloccato).toList();

  /// Percentuale completamento totale
  double get percentualeCompletamento {
    final tot = _achievements.length;
    final sblocc = sbloccati.length;
    return tot > 0 ? sblocc / tot : 0;
  }

  /// Ottieni daily rewards
  List<DailyReward> get dailyRewards => List.unmodifiable(_dailyRewards);

  /// Giorno corrente
  int get giornoCorrente => _giornoCorrente;

  /// Login consecutivi
  int get loginConsecutivi => _loginConsecutivi;

  /// Serializzazione
  Map<String, dynamic> toJson() => {
    'achievements': _achievements.map((a) => a.toJson()).toList(),
    'giornoCorrente': _giornoCorrente,
    'ultimoLogin': _ultimoLogin?.toIso8601String(),
    'loginConsecutivi': _loginConsecutivi,
  };

  /// Deserializzazione
  void fromJson(Map<String, dynamic> json) {
    if (json['achievements'] != null) {
      for (final data in json['achievements'] as List) {
        final id = (data as Map<String, dynamic>)['id'] as String;
        for (final a in _achievements) {
          if (a.id == id) {
            a.progresso = data['progresso'] as int? ?? 0;
            a.sbloccato = data['sbloccato'] as bool? ?? false;
          }
        }
      }
    }
    _giornoCorrente = json['giornoCorrente'] as int? ?? 1;
    _loginConsecutivi = json['loginConsecutivi'] as int? ?? 0;
    if (json['ultimoLogin'] != null) {
      _ultimoLogin = DateTime.parse(json['ultimoLogin'] as String);
    }
  }
}
