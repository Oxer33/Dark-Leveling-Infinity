/// Costanti principali del gioco Dark Leveling Infinity
/// Contiene tutti i valori numerici e configurazioni globali
library;

/// Dimensioni del mondo e delle tile
class WorldConstants {
  static const double tileSize = 32.0;
  static const int chunkSize = 16; // 16x16 tiles per chunk
  static const int renderDistance = 3; // chunks visibili intorno al player
  static const int maxActiveChunks = 49; // (renderDistance*2+1)^2
  static const double worldScale = 1.0;
}

/// Costanti del player
class PlayerConstants {
  // Stats base iniziali (E-Rank)
  static const int baseStrength = 10;
  static const int baseAgility = 10;
  static const int baseVitality = 10;
  static const int baseIntelligence = 10;
  static const int basePerception = 10;
  static const double baseHealth = 100.0;
  static const double baseMana = 50.0;
  static const double baseSpeed = 120.0;
  static const double baseAttackRange = 48.0;
  static const double baseAttackCooldown = 0.5; // secondi

  // Progressione livelli
  static const int maxLevel = 999;
  static const double expMultiplier = 1.15; // crescita esponenziale exp
  static const int baseExpToLevel = 100;
  static const int statPointsPerLevel = 5;
  static const int skillPointsPerLevel = 1;

  // Movimento
  static const double sprintMultiplier = 1.8;
  static const double dodgeDistance = 64.0;
  static const double dodgeCooldown = 1.5;
  static const double dodgeInvincibilityDuration = 0.3;
}

/// Ranghi Hunter (ispirati a Solo Leveling)
enum HunterRank {
  e(nome: 'E-Rank', livelloMinimo: 1, coloreHex: 0xFF808080),
  d(nome: 'D-Rank', livelloMinimo: 10, coloreHex: 0xFF4CAF50),
  c(nome: 'C-Rank', livelloMinimo: 25, coloreHex: 0xFF2196F3),
  b(nome: 'B-Rank', livelloMinimo: 50, coloreHex: 0xFF9C27B0),
  a(nome: 'A-Rank', livelloMinimo: 100, coloreHex: 0xFFFF9800),
  s(nome: 'S-Rank', livelloMinimo: 200, coloreHex: 0xFFFF5722),
  national(nome: 'Nazionale', livelloMinimo: 400, coloreHex: 0xFFFFD700),
  monarch(nome: 'Monarca', livelloMinimo: 700, coloreHex: 0xFF000000);

  final String nome;
  final int livelloMinimo;
  final int coloreHex;

  const HunterRank({
    required this.nome,
    required this.livelloMinimo,
    required this.coloreHex,
  });
}

/// Ranghi dei Gate/Dungeon
enum GateRank {
  e(nome: 'Gate E', livelloConsigliato: 1, coloreHex: 0xFF808080, numStanze: 5),
  d(nome: 'Gate D', livelloConsigliato: 10, coloreHex: 0xFF4CAF50, numStanze: 8),
  c(nome: 'Gate C', livelloConsigliato: 25, coloreHex: 0xFF2196F3, numStanze: 12),
  b(nome: 'Gate B', livelloConsigliato: 50, coloreHex: 0xFF9C27B0, numStanze: 16),
  a(nome: 'Gate A', livelloConsigliato: 100, coloreHex: 0xFFFF9800, numStanze: 20),
  s(nome: 'Gate S', livelloConsigliato: 200, coloreHex: 0xFFFF5722, numStanze: 25),
  red(nome: 'Gate Rosso', livelloConsigliato: 300, coloreHex: 0xFFB71C1C, numStanze: 30),
  monarch(nome: 'Gate Monarca', livelloConsigliato: 500, coloreHex: 0xFF000000, numStanze: 50);

  final String nome;
  final int livelloConsigliato;
  final int coloreHex;
  final int numStanze;

  const GateRank({
    required this.nome,
    required this.livelloConsigliato,
    required this.coloreHex,
    required this.numStanze,
  });
}

/// Rarità degli oggetti
enum ItemRarity {
  comune(nome: 'Comune', coloreHex: 0xFF9E9E9E, dropRate: 0.50),
  nonComune(nome: 'Non Comune', coloreHex: 0xFF4CAF50, dropRate: 0.25),
  raro(nome: 'Raro', coloreHex: 0xFF2196F3, dropRate: 0.15),
  epico(nome: 'Epico', coloreHex: 0xFF9C27B0, dropRate: 0.07),
  leggendario(nome: 'Leggendario', coloreHex: 0xFFFF9800, dropRate: 0.025),
  mitico(nome: 'Mitico', coloreHex: 0xFFFF5722, dropRate: 0.004),
  divino(nome: 'Divino', coloreHex: 0xFFFFD700, dropRate: 0.001);

  final String nome;
  final int coloreHex;
  final double dropRate;

  const ItemRarity({
    required this.nome,
    required this.coloreHex,
    required this.dropRate,
  });
}

/// Costanti del combat system
class CombatConstants {
  static const double criticalHitMultiplier = 2.0;
  static const double baseCriticalChance = 0.05;
  static const double comboWindowSeconds = 1.5;
  static const int maxComboHits = 50;
  static const double comboMultiplierStep = 0.1;
  static const double knockbackForce = 200.0;
  static const double stunDuration = 0.5;
  static const double poisonTickInterval = 1.0;
  static const double burnTickInterval = 0.5;
  static const double freezeSlowFactor = 0.5;
}

/// Costanti Shadow Army
class ShadowConstants {
  static const int maxShadowsEarlyGame = 10;
  static const int maxShadowsMidGame = 50;
  static const int maxShadowsLateGame = 200;
  static const int maxShadowsEndGame = 1000;
  static const double extractionBaseChance = 0.30;
  static const double bossExtractionChance = 0.80;
  static const double shadowExpShare = 0.5;
}

/// Gradi delle ombre
enum ShadowGrade {
  normal(nome: 'Normale', moltiplicatoreStats: 1.0),
  elite(nome: 'Elite', moltiplicatoreStats: 1.5),
  knight(nome: 'Cavaliere', moltiplicatoreStats: 2.5),
  eliteKnight(nome: 'Cavaliere Elite', moltiplicatoreStats: 4.0),
  marshal(nome: 'Maresciallo', moltiplicatoreStats: 7.0),
  grandMarshal(nome: 'Gran Maresciallo', moltiplicatoreStats: 12.0);

  final String nome;
  final double moltiplicatoreStats;

  const ShadowGrade({
    required this.nome,
    required this.moltiplicatoreStats,
  });
}

/// Costanti Market / IAP
class MarketConstants {
  // ID prodotti per lo store
  static const String gemsPack1 = 'gems_100';
  static const String gemsPack2 = 'gems_500';
  static const String gemsPack3 = 'gems_1200';
  static const String gemsPack4 = 'gems_5000';
  static const String monthlyPass = 'monthly_hunter_pass';
  static const String starterPack = 'starter_pack';
  static const String premiumBattlePass = 'premium_battle_pass';

  // Valori gemme
  static const int gems100Price = 99; // centesimi
  static const int gems500Price = 499;
  static const int gems1200Price = 999;
  static const int gems5000Price = 2999;
}
