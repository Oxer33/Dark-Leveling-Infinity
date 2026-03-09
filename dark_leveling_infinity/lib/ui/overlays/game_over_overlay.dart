/// Overlay Game Over di Dark Leveling Infinity
/// Mostra statistiche della run e opzioni post-morte
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/player_data.dart';

/// Overlay che appare quando il player muore
class GameOverOverlay extends StatelessWidget {
  final PlayerData playerData;
  final VoidCallback onRiprova;
  final VoidCallback onMenu;
  final int nemiciSconfitti;

  const GameOverOverlay({
    super.key,
    required this.playerData,
    required this.onRiprova,
    required this.onMenu,
    this.nemiciSconfitti = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.overlayDark,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.backgroundMedium,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GameColors.healthRed.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.healthRed.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titolo Game Over
              Text(
                GameStrings.gameOver,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: GameColors.healthRed,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 20),

              // Statistiche della run
              _buildStatistica('Nemici Sconfitti', '$nemiciSconfitti'),
              _buildStatistica('Livello Raggiunto', '${playerData.livello}'),
              _buildStatistica('Rango', playerData.rango.nome),
              _buildStatistica('Combo Massima', '${playerData.comboMassima}'),
              _buildStatistica('Oro Guadagnato', '${playerData.oro}'),

              const SizedBox(height: 24),

              // Messaggio motivazionale
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GameColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GameColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${GameStrings.sistemaMsg} Un vero Cacciatore non si arrende mai. Alzati e combatti ancora.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 11,
                    color: GameColors.neonPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              const SizedBox(height: 20),

              // Pulsanti
              _buildPulsante(
                testo: GameStrings.riprova,
                icona: Icons.refresh_rounded,
                colore: GameColors.primaryPurple,
                onTap: onRiprova,
              ),
              const SizedBox(height: 10),
              _buildPulsante(
                testo: GameStrings.tornaAlMenu,
                icona: Icons.home_rounded,
                colore: GameColors.textDimmed,
                onTap: onMenu,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildStatistica(String etichetta, String valore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etichetta,
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 12,
              color: GameColors.textSecondary,
            ),
          ),
          Text(
            valore,
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsante({
    required String testo,
    required IconData icona,
    required Color colore,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colore.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colore.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, color: colore, size: 20),
            const SizedBox(width: 8),
            Text(
              testo,
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colore,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
