/// Overlay di pausa del gioco
/// Mostra le opzioni di pausa con sfondo sfocato
library;

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';

/// Overlay che appare quando il gioco è in pausa
class PauseOverlay extends StatelessWidget {
  final VoidCallback onRiprendi;
  final VoidCallback onImpostazioni;
  final VoidCallback onMenu;
  final VoidCallback onSalva;

  const PauseOverlay({
    super.key,
    required this.onRiprendi,
    required this.onImpostazioni,
    required this.onMenu,
    required this.onSalva,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.overlayDark,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.backgroundMedium,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GameColors.primaryPurple.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titolo
              const Text(
                GameStrings.pausa,
                style: TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: GameColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),

              // Pulsante Riprendi
              _buildPulsante(
                testo: GameStrings.riprendi,
                icona: Icons.play_arrow_rounded,
                colore: GameColors.primaryPurple,
                onTap: onRiprendi,
              ),
              const SizedBox(height: 10),

              // Pulsante Salva
              _buildPulsante(
                testo: 'Salva Partita',
                icona: Icons.save_rounded,
                colore: GameColors.accentCyan,
                onTap: onSalva,
              ),
              const SizedBox(height: 10),

              // Pulsante Impostazioni
              _buildPulsante(
                testo: GameStrings.impostazioni,
                icona: Icons.settings_rounded,
                colore: GameColors.textDimmed,
                onTap: onImpostazioni,
              ),
              const SizedBox(height: 10),

              // Pulsante Torna al Menu
              _buildPulsante(
                testo: GameStrings.tornaAlMenu,
                icona: Icons.home_rounded,
                colore: GameColors.healthRed,
                onTap: onMenu,
              ),
            ],
          ),
        ),
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
