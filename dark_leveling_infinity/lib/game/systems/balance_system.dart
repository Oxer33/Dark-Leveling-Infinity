/// Sistema di bilanciamento di Dark Leveling Infinity
/// Gestisce scaling difficoltà, curve di progressione, e calibrazione combat
library;

import 'dart:developer' as dev;
import 'dart:math';

import '../../core/constants/game_constants.dart';
import '../../data/models/enemy_data.dart';

/// Configurazione di difficoltà del gioco
enum DifficoltaGioco {
  facile(moltiplicatoreDannoNemici: 0.7, moltiplicatoreHPNemici: 0.8, moltiplicatoreExp: 1.3, moltiplicatoreOro: 1.2, nome: 'Facile'),
  normale(moltiplicatoreDannoNemici: 1.0, moltiplicatoreHPNemici: 1.0, moltiplicatoreExp: 1.0, moltiplicatoreOro: 1.0, nome: 'Normale'),
  difficile(moltiplicatoreDannoNemici: 1.5, moltiplicatoreHPNemici: 1.3, moltiplicatoreExp: 0.8, moltiplicatoreOro: 0.9, nome: 'Difficile'),
  incubo(moltiplicatoreDannoNemici: 2.0, moltiplicatoreHPNemici: 2.0, moltiplicatoreExp: 0.6, moltiplicatoreOro: 0.7, nome: 'Incubo'),
  monarca(moltiplicatoreDannoNemici: 3.0, moltiplicatoreHPNemici: 3.0, moltiplicatoreExp: 0.5, moltiplicatoreOro: 0.5, nome: 'Monarca');

  final double moltiplicatoreDannoNemici;
  final double moltiplicatoreHPNemici;
  final double moltiplicatoreExp;
  final double moltiplicatoreOro;
  final String nome;

  const DifficoltaGioco({
    required this.moltiplicatoreDannoNemici,
    required this.moltiplicatoreHPNemici,
    required this.moltiplicatoreExp,
    required this.moltiplicatoreOro,
    required this.nome,
  });
}

/// Sistema di bilanciamento e scaling della difficoltà
class BalanceSystem {
  // Difficoltà corrente
  DifficoltaGioco _difficolta = DifficoltaGioco.normale;

  // Difficoltà adattiva basata sulle performance del player
  double _moltiplicatoreDifficoltaAdattiva = 1.0;

  // Metriche per l'adattamento della difficoltà
  int _mortiRecenti = 0; // morti nelle ultime 10 stanze
  int _stanzeSenzaMorti = 0; // stanze consecutive senza morire
  double tempoDannoMedioRicevuto = 0; // danno ricevuto per secondo
  int nemiciSconfittiConsecutivi = 0;

  // Timer per il reset delle metriche
  double _timerResetMetriche = 0;
  static const double _intervalloResetMetriche = 300.0; // 5 minuti

  /// Calcola le stats di un nemico bilanciate per il livello del player
  EnemyBalancedStats calcolaStatsNemico({
    required EnemyData nemico,
    required int livelloPlayer,
    required GateRank rangoGate,
    bool isBoss = false,
  }) {
    // Calcola il differenziale di livello
    final diffLivello = livelloPlayer - nemico.livelloBase;
    final scalingFactor = _calcolaScalingFactor(diffLivello);

    // Calcola HP bilanciato
    double hp = nemico.saluteBase * scalingFactor;
    hp *= _difficolta.moltiplicatoreHPNemici;
    hp *= _moltiplicatoreDifficoltaAdattiva;

    // Calcola danno bilanciato
    double danno = nemico.dannoBase * scalingFactor * 0.8; // leggermente meno aggressivo
    danno *= _difficolta.moltiplicatoreDannoNemici;
    danno *= _moltiplicatoreDifficoltaAdattiva;

    // Calcola difesa bilanciata
    double difesa = nemico.difesaBase * scalingFactor * 0.7;

    // Calcola velocità (leggermente scalata)
    double velocita = nemico.velocitaBase * (1.0 + diffLivello * 0.005);

    // Boss hanno stats extra
    if (isBoss) {
      hp *= 2.5;
      danno *= 1.5;
      difesa *= 1.5;
    }

    // Calcola ricompense
    double exp = nemico.expRicompensa * _calcolaRicompensaScaling(diffLivello);
    exp *= _difficolta.moltiplicatoreExp;

    int oro = (nemico.oroRicompensa * _calcolaRicompensaScaling(diffLivello)).toInt();
    oro = (oro * _difficolta.moltiplicatoreOro).toInt();

    return EnemyBalancedStats(
      salute: hp.clamp(10, 999999),
      danno: danno.clamp(1, 99999),
      difesa: difesa.clamp(0, 9999),
      velocita: velocita.clamp(10, 300),
      expRicompensa: exp.clamp(1, 999999),
      oroRicompensa: oro.clamp(1, 999999),
    );
  }

  /// Calcola il fattore di scaling basato sulla differenza di livello
  double _calcolaScalingFactor(int diffLivello) {
    if (diffLivello <= 0) {
      // Il nemico è di livello uguale o superiore - scala poco
      return 1.0 + (diffLivello.abs() * 0.03);
    } else if (diffLivello <= 10) {
      // Player leggermente più forte - scaling moderato
      return 1.0 + diffLivello * 0.08;
    } else if (diffLivello <= 50) {
      // Player significativamente più forte - scaling ridotto
      return 1.8 + (diffLivello - 10) * 0.04;
    } else {
      // Player molto più forte - scaling minimo
      return 3.4 + (diffLivello - 50) * 0.02;
    }
  }

  /// Calcola il moltiplicatore delle ricompense
  double _calcolaRicompensaScaling(int diffLivello) {
    if (diffLivello < -10) {
      // Nemico molto più forte - ricompense extra
      return 1.5 + diffLivello.abs() * 0.05;
    } else if (diffLivello > 20) {
      // Nemico molto più debole - ricompense ridotte
      return max(0.1, 1.0 - (diffLivello - 20) * 0.03);
    }
    return 1.0;
  }

  /// Aggiorna le metriche di difficoltà adattiva
  void aggiornaMetriche(double dt) {
    _timerResetMetriche += dt;
    if (_timerResetMetriche >= _intervalloResetMetriche) {
      _timerResetMetriche = 0;
      _ricalcolaDifficoltaAdattiva();
    }
  }

  /// Registra una morte del player
  void registraMorte() {
    _mortiRecenti++;
    _stanzeSenzaMorti = 0;
    _ricalcolaDifficoltaAdattiva();
    dev.log('[BALANCE] Morte registrata. Morti recenti: $_mortiRecenti');
  }

  /// Registra il completamento di una stanza
  void registraStanzaCompletata() {
    _stanzeSenzaMorti++;
    nemiciSconfittiConsecutivi = 0;
    if (_stanzeSenzaMorti > 20) {
      _ricalcolaDifficoltaAdattiva();
    }
  }

  /// Registra un nemico sconfitto
  void registraNemicoSconfitto() {
    nemiciSconfittiConsecutivi++;
  }

  /// Ricalcola il moltiplicatore di difficoltà adattiva
  void _ricalcolaDifficoltaAdattiva() {
    double nuovaMoltiplicatore = 1.0;

    // Se il player muore troppo, riduci la difficoltà
    if (_mortiRecenti >= 5) {
      nuovaMoltiplicatore *= 0.7;
      dev.log('[BALANCE] Troppe morti, riduzione difficoltà');
    } else if (_mortiRecenti >= 3) {
      nuovaMoltiplicatore *= 0.85;
    }

    // Se il player non muore mai, aumenta la difficoltà
    if (_stanzeSenzaMorti >= 30) {
      nuovaMoltiplicatore *= 1.3;
      dev.log('[BALANCE] Troppo facile, aumento difficoltà');
    } else if (_stanzeSenzaMorti >= 15) {
      nuovaMoltiplicatore *= 1.15;
    }

    // Smooth transition
    _moltiplicatoreDifficoltaAdattiva = _moltiplicatoreDifficoltaAdattiva * 0.8 +
        nuovaMoltiplicatore * 0.2;

    // Clamp per sicurezza
    _moltiplicatoreDifficoltaAdattiva = _moltiplicatoreDifficoltaAdattiva.clamp(0.5, 2.0);

    // Reset metriche periodico
    _mortiRecenti = max(0, _mortiRecenti - 1);

    dev.log('[BALANCE] Difficoltà adattiva: ${_moltiplicatoreDifficoltaAdattiva.toStringAsFixed(2)}');
  }

  /// Calcola il numero ottimale di nemici per stanza
  int calcolaNumNemiciPerStanza({
    required int livelloPlayer,
    required GateRank rangoGate,
    required int dimensioneStanza,
  }) {
    // Base: 2-5 nemici, scala con la dimensione della stanza
    int base = 2 + (dimensioneStanza ~/ 20);

    // Scala con il rango del gate
    base += rangoGate.index;

    // Riduci se la difficoltà adattiva è bassa
    if (_moltiplicatoreDifficoltaAdattiva < 0.8) {
      base = (base * 0.7).ceil();
    }

    return base.clamp(1, 15);
  }

  /// Calcola il drop rate per un nemico
  double calcolaDropRate({
    required EnemyData nemico,
    required int livelloPlayer,
    bool isBoss = false,
  }) {
    double dropRate = 0.15; // 15% base

    // Boss hanno drop rate molto più alto
    if (isBoss) {
      dropRate = 0.80;
    }

    // Bonus basato sulla differenza di livello
    final diffLivello = nemico.livelloBase - livelloPlayer;
    if (diffLivello > 0) {
      dropRate += diffLivello * 0.01; // nemici più forti droppano di più
    }

    // Bonus dal nemico stesso
    dropRate += nemico.dropRateBonus;

    return dropRate.clamp(0.05, 1.0);
  }

  /// Ottieni la difficoltà corrente
  DifficoltaGioco get difficolta => _difficolta;

  /// Imposta la difficoltà
  set difficolta(DifficoltaGioco nuova) {
    _difficolta = nuova;
    dev.log('[BALANCE] Difficoltà impostata: ${nuova.nome}');
  }

  /// Ottieni il moltiplicatore adattivo corrente
  double get moltiplicatoreAdattivo => _moltiplicatoreDifficoltaAdattiva;
}

/// Stats bilanciate calcolate dal balance system
class EnemyBalancedStats {
  final double salute;
  final double danno;
  final double difesa;
  final double velocita;
  final double expRicompensa;
  final int oroRicompensa;

  const EnemyBalancedStats({
    required this.salute,
    required this.danno,
    required this.difesa,
    required this.velocita,
    required this.expRicompensa,
    required this.oroRicompensa,
  });
}
