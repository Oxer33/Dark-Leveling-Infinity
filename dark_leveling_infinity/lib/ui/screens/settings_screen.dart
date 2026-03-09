/// Schermata Impostazioni di Dark Leveling Infinity
/// Permette di configurare audio, grafica, controlli e altro
library;

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/services/save_service.dart';

/// Schermata delle impostazioni del gioco
class SettingsScreen extends StatefulWidget {
  final VoidCallback onChiudi;

  const SettingsScreen({super.key, required this.onChiudi});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Impostazioni correnti
  late Map<String, dynamic> _impostazioni;

  @override
  void initState() {
    super.initState();
    _impostazioni = SaveService.instance.caricaImpostazioni();
    dev.log('[SETTINGS] Impostazioni caricate: $_impostazioni');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Contenuto scrollabile
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // === AUDIO ===
                  _buildSezione('Audio'),
                  _buildSlider(
                    etichetta: GameStrings.musica,
                    icona: Icons.music_note_rounded,
                    valore: (_impostazioni['volumeMusica'] as num).toDouble(),
                    onChanged: (v) => _aggiornaImpostazione('volumeMusica', v),
                  ),
                  _buildSlider(
                    etichetta: GameStrings.effettiSonori,
                    icona: Icons.volume_up_rounded,
                    valore: (_impostazioni['volumeEffetti'] as num).toDouble(),
                    onChanged: (v) => _aggiornaImpostazione('volumeEffetti', v),
                  ),

                  const SizedBox(height: 12),

                  // === GAMEPLAY ===
                  _buildSezione('Gameplay'),
                  _buildSwitch(
                    etichetta: GameStrings.vibrazioni,
                    icona: Icons.vibration_rounded,
                    valore: _impostazioni['vibrazioni'] as bool,
                    onChanged: (v) => _aggiornaImpostazione('vibrazioni', v),
                  ),
                  _buildSwitch(
                    etichetta: 'Mostra Danni',
                    icona: Icons.text_fields_rounded,
                    valore: _impostazioni['mostraDanni'] as bool,
                    onChanged: (v) => _aggiornaImpostazione('mostraDanni', v),
                  ),
                  _buildSwitch(
                    etichetta: 'Mostra FPS',
                    icona: Icons.speed_rounded,
                    valore: _impostazioni['mostraFPS'] as bool,
                    onChanged: (v) => _aggiornaImpostazione('mostraFPS', v),
                  ),

                  const SizedBox(height: 12),

                  // === CONTROLLI ===
                  _buildSezione('Controlli'),
                  _buildOpzione(
                    etichetta: 'Posizione Joystick',
                    icona: Icons.gamepad_rounded,
                    valore: _impostazioni['joystickLato'] == 'sinistro'
                        ? 'Sinistra'
                        : 'Destra',
                    onTap: () {
                      final nuovoLato = _impostazioni['joystickLato'] == 'sinistro'
                          ? 'destro'
                          : 'sinistro';
                      _aggiornaImpostazione('joystickLato', nuovoLato);
                    },
                  ),

                  const SizedBox(height: 12),

                  // === GRAFICA ===
                  _buildSezione('Grafica'),
                  _buildOpzione(
                    etichetta: GameStrings.grafica,
                    icona: Icons.display_settings_rounded,
                    valore: _impostazioni['qualitaGrafica'] as String,
                    onTap: () {
                      final qualita = ['bassa', 'media', 'alta'];
                      final corrente = qualita.indexOf(
                        _impostazioni['qualitaGrafica'] as String,
                      );
                      final prossima = (corrente + 1) % qualita.length;
                      _aggiornaImpostazione('qualitaGrafica', qualita[prossima]);
                    },
                  ),

                  const SizedBox(height: 24),

                  // === ZONA PERICOLO ===
                  _buildSezione('Zona Pericolosa', colore: GameColors.healthRed),
                  _buildPulsantePericolo(
                    etichetta: GameStrings.cancellaProgressi,
                    icona: Icons.delete_forever_rounded,
                    onTap: _confermaCancellazione,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header della schermata
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.backgroundMedium,
        border: Border(
          bottom: BorderSide(
            color: GameColors.primaryPurple.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onChiudi,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: GameColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            GameStrings.impostazioni.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Sezione titolo
  Widget _buildSezione(String titolo, {Color colore = GameColors.primaryPurple}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        titolo.toUpperCase(),
        style: TextStyle(
          fontFamily: 'GameFont',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colore,
          letterSpacing: 2,
        ),
      ),
    );
  }

  /// Slider per valori numerici
  Widget _buildSlider({
    required String etichetta,
    required IconData icona,
    required double valore,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icona, color: GameColors.textSecondary, size: 18),
              const SizedBox(width: 10),
              Text(
                etichetta,
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 14,
                  color: GameColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(valore * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 12,
                  color: GameColors.textSecondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: GameColors.primaryPurple,
              inactiveTrackColor: GameColors.backgroundDark,
              thumbColor: GameColors.primaryPurple,
              overlayColor: GameColors.primaryPurple.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: valore,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Switch per valori booleani
  Widget _buildSwitch({
    required String etichetta,
    required IconData icona,
    required bool valore,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icona, color: GameColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Text(
            etichetta,
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 14,
              color: GameColors.textPrimary,
            ),
          ),
          const Spacer(),
          Switch(
            value: valore,
            onChanged: onChanged,
            activeColor: GameColors.primaryPurple,
            inactiveTrackColor: GameColors.backgroundDark,
          ),
        ],
      ),
    );
  }

  /// Opzione cliccabile
  Widget _buildOpzione({
    required String etichetta,
    required IconData icona,
    required String valore,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GameColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GameColors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icona, color: GameColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(
              etichetta,
              style: const TextStyle(
                fontFamily: 'GameFont',
                fontSize: 14,
                color: GameColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              valore,
              style: const TextStyle(
                fontFamily: 'GameFont',
                fontSize: 13,
                color: GameColors.accentCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: GameColors.textDimmed,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Pulsante zona pericolosa
  Widget _buildPulsantePericolo({
    required String etichetta,
    required IconData icona,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GameColors.healthRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GameColors.healthRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icona, color: GameColors.healthRed, size: 18),
            const SizedBox(width: 10),
            Text(
              etichetta,
              style: const TextStyle(
                fontFamily: 'GameFont',
                fontSize: 14,
                color: GameColors.healthRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aggiorna un'impostazione e salva
  void _aggiornaImpostazione(String chiave, dynamic valore) {
    setState(() {
      _impostazioni[chiave] = valore;
    });
    SaveService.instance.salvaImpostazioni(_impostazioni);
    dev.log('[SETTINGS] $chiave = $valore');
  }

  /// Mostra dialogo di conferma cancellazione
  void _confermaCancellazione() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.backgroundMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: GameColors.healthRed),
        ),
        title: const Text(
          'Conferma Cancellazione',
          style: TextStyle(
            fontFamily: 'GameFont',
            color: GameColors.healthRed,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Sei sicuro di voler cancellare tutti i progressi? Questa azione è irreversibile.',
          style: TextStyle(
            fontFamily: 'GameFont',
            color: GameColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annulla',
              style: TextStyle(fontFamily: 'GameFont', color: GameColors.textDimmed),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SaveService.instance.cancellaTutto();
              dev.log('[SETTINGS] Tutti i progressi cancellati!');
            },
            child: const Text(
              'CANCELLA TUTTO',
              style: TextStyle(fontFamily: 'GameFont', color: GameColors.healthRed, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
