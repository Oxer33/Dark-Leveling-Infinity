/// Overlay Level Up di Dark Leveling Infinity
/// Mostra l'animazione di level up e permette di assegnare punti stat
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/player_data.dart';

/// Overlay che appare quando il player sale di livello
class LevelUpOverlay extends StatefulWidget {
  final PlayerData playerData;
  final Function(String stat) onAssegnaPunto;
  final VoidCallback onChiudi;

  const LevelUpOverlay({
    super.key,
    required this.playerData,
    required this.onAssegnaPunto,
    required this.onChiudi,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.overlayDark,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.backgroundMedium,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GameColors.accentGold.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.accentGold.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titolo LEVEL UP!
              Text(
                GameStrings.levelUp,
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: GameColors.accentGold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: GameColors.glowGold, blurRadius: 20),
                  ],
                ),
              ).animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                  .then()
                  .shimmer(duration: 1000.ms, color: GameColors.accentGold.withValues(alpha: 0.3)),

              const SizedBox(height: 8),

              // Livello raggiunto
              Text(
                '${GameStrings.livello} ${widget.playerData.livello}',
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GameColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms),

              // Rango
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(widget.playerData.rango.coloreHex).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(widget.playerData.rango.coloreHex),
                  ),
                ),
                child: Text(
                  widget.playerData.rango.nome,
                  style: TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(widget.playerData.rango.coloreHex),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // Punti stat disponibili
              if (widget.playerData.puntiStatDisponibili > 0) ...[
                Text(
                  '${GameStrings.puntiStatistiche}: ${widget.playerData.puntiStatDisponibili}',
                  style: const TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GameColors.accentCyan,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats con pulsanti +
                _buildStatRow(GameStrings.forza, 'forza', widget.playerData.stats.forza, GameColors.healthRed),
                _buildStatRow(GameStrings.agilita, 'agilita', widget.playerData.stats.agilita, GameColors.expGreen),
                _buildStatRow(GameStrings.vitalita, 'vitalita', widget.playerData.stats.vitalita, GameColors.staminaYellow),
                _buildStatRow(GameStrings.intelligenza, 'intelligenza', widget.playerData.stats.intelligenza, GameColors.manaBlue),
                _buildStatRow(GameStrings.percezione, 'percezione', widget.playerData.stats.percezione, GameColors.neonPurple),
              ],

              const SizedBox(height: 20),

              // Messaggio sistema
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GameColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: GameColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${GameStrings.sistemaMsg} Il tuo potere cresce. Continua così, Cacciatore.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 10,
                    color: GameColors.neonPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              // Pulsante Chiudi
              GestureDetector(
                onTap: widget.onChiudi,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: GameColors.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GameColors.primaryPurple.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'CONTINUA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'GameFont',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: GameColors.primaryPurple,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
      ),
    );
  }

  /// Riga per assegnare punti a una stat
  Widget _buildStatRow(String nome, String chiave, int valore, Color colore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              nome,
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 12,
                color: colore,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$valore',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'GameFont',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: GameColors.textPrimary,
              ),
            ),
          ),
          // Pulsante +
          if (widget.playerData.puntiStatDisponibili > 0)
            GestureDetector(
              onTap: () {
                widget.onAssegnaPunto(chiave);
                setState(() {});
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colore.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: colore.withValues(alpha: 0.5)),
                ),
                child: Icon(Icons.add, color: colore, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
