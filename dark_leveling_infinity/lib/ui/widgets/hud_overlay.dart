/// HUD Overlay per il gioco Dark Leveling Infinity
/// Mostra HP, MP, EXP, minimap, combo counter, pulsanti abilità e joystick
library;

import 'package:flutter/material.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/player_data.dart';
import '../../game/dark_leveling_game.dart';

/// HUD sovrapposto al gioco con tutti i controlli
class HudOverlay extends StatefulWidget {
  final DarkLevelingGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> with TickerProviderStateMixin {
  // Joystick
  Offset _joystickPosition = Offset.zero;
  bool _joystickActive = false;

  // Messaggi di sistema
  final List<String> _messaggiSistema = [];
  static const int _maxMessaggi = 5;

  @override
  void initState() {
    super.initState();

    // Ascolta i messaggi di sistema dal gioco
    widget.game.onSystemMessage = (messaggio) {
      setState(() {
        _messaggiSistema.insert(0, messaggio);
        if (_messaggiSistema.length > _maxMessaggi) {
          _messaggiSistema.removeLast();
        }
      });

      // Rimuovi il messaggio dopo 5 secondi
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _messaggiSistema.remove(messaggio);
          });
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final playerData = widget.game.playerData;
    final player = widget.game.playerComponent;

    return Stack(
      children: [
        // === BARRA HP/MP/EXP in alto ===
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: _buildBarreSuperori(playerData, player),
          ),
        ),

        // === COMBO COUNTER ===
        if (player.comboCorrente > 0)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: 16,
            child: _buildComboCounter(player.comboCorrente),
          ),

        // === MESSAGGI DI SISTEMA ===
        Positioned(
          top: MediaQuery.of(context).size.height * 0.12,
          left: 16,
          right: MediaQuery.of(context).size.width * 0.3,
          child: _buildMessaggiSistema(),
        ),

        // === JOYSTICK (sinistra) ===
        Positioned(
          bottom: 40,
          left: 24,
          child: _buildJoystick(),
        ),

        // === PULSANTI AZIONE (destra) ===
        Positioned(
          bottom: 40,
          right: 24,
          child: _buildPulsantiAzione(),
        ),

        // === PULSANTI ABILITÀ (centro-destra) ===
        Positioned(
          bottom: 140,
          right: 16,
          child: _buildPulsantiAbilita(),
        ),

        // === PULSANTE PAUSA (in alto a destra) ===
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(child: _buildPulsantePausa()),
        ),

        // === INFO GATE (in alto al centro) ===
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: SafeArea(child: _buildInfoGate()),
        ),
      ],
    );
  }

  /// Barre HP, MP, EXP nella parte superiore
  Widget _buildBarreSuperori(PlayerData data, dynamic player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga livello e rango
          Row(
            children: [
              // Rango badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(data.rango.coloreHex).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(data.rango.coloreHex),
                    width: 1,
                  ),
                ),
                child: Text(
                  data.rango.nome,
                  style: TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(data.rango.coloreHex),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${GameStrings.livello} ${data.livello}',
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GameColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Oro e Gemme
              _buildValuta(Icons.monetization_on, '${data.oro}', GameColors.accentGold),
              const SizedBox(width: 12),
              _buildValuta(Icons.diamond, '${data.gemme}', GameColors.accentCyan),
            ],
          ),
          const SizedBox(height: 4),

          // Barra HP
          _buildBarra(
            etichetta: GameStrings.salute,
            valore: player.saluteAttuale,
            massimo: data.stats.saluteMax,
            colore: GameColors.healthRed,
            coloreSfondo: GameColors.healthRedDark,
          ),
          const SizedBox(height: 2),

          // Barra MP
          _buildBarra(
            etichetta: GameStrings.mana,
            valore: player.manaAttuale,
            massimo: data.stats.manaMax,
            colore: GameColors.manaBlue,
            coloreSfondo: GameColors.manaBlueDark,
          ),
          const SizedBox(height: 2),

          // Barra EXP
          _buildBarra(
            etichetta: GameStrings.esperienza,
            valore: data.esperienza,
            massimo: data.espPerProssimoLivello,
            colore: GameColors.expGreen,
            coloreSfondo: GameColors.expGreenDark,
            altezza: 6,
          ),
        ],
      ),
    );
  }

  /// Barra di progresso generica
  Widget _buildBarra({
    required String etichetta,
    required double valore,
    required double massimo,
    required Color colore,
    required Color coloreSfondo,
    double altezza = 10,
  }) {
    final percentuale = (valore / massimo).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            etichetta,
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colore,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: altezza,
            decoration: BoxDecoration(
              color: coloreSfondo,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                // Barra riempimento
                FractionallySizedBox(
                  widthFactor: percentuale,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colore, colore.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: colore.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 60,
          child: Text(
            '${valore.toInt()}/${massimo.toInt()}',
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 8,
              color: GameColors.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Indicatore valuta (oro/gemme)
  Widget _buildValuta(IconData icona, String valore, Color colore) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icona, size: 14, color: colore),
        const SizedBox(width: 2),
        Text(
          valore,
          style: TextStyle(
            fontFamily: 'GameFont',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colore,
          ),
        ),
      ],
    );
  }

  /// Counter delle combo
  Widget _buildComboCounter(int combo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameColors.primaryPurple.withValues(alpha: 0.8),
            GameColors.shadowBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: GameColors.primaryPurple.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$combo',
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Text(
            'COMBO',
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: GameColors.accentGold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.05, 1.05),
      duration: 300.ms,
    );
  }

  /// Messaggi di sistema (stile Solo Leveling)
  Widget _buildMessaggiSistema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _messaggiSistema.map((msg) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: GameColors.backgroundDark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: GameColors.primaryPurple.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            '${GameStrings.sistemaMsg} $msg',
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 10,
              color: GameColors.neonPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
      }).toList(),
    );
  }

  /// Joystick virtuale per il movimento
  Widget _buildJoystick() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _joystickActive = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          // Limita il joystick al raggio massimo
          final offset = details.localPosition - const Offset(60, 60);
          final distanza = offset.distance;
          final maxRaggio = 40.0;

          if (distanza > maxRaggio) {
            _joystickPosition = Offset(
              offset.dx / distanza * maxRaggio,
              offset.dy / distanza * maxRaggio,
            );
          } else {
            _joystickPosition = offset;
          }

          // Invia il movimento al gioco
          widget.game.muoviPlayer(
            Vector2(_joystickPosition.dx / maxRaggio, _joystickPosition.dy / maxRaggio),
          );
        });
      },
      onPanEnd: (_) {
        setState(() {
          _joystickActive = false;
          _joystickPosition = Offset.zero;
          widget.game.muoviPlayer(Vector2.zero());
        });
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GameColors.backgroundDark.withValues(alpha: 0.5),
          border: Border.all(
            color: GameColors.borderDefault.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: _joystickPosition,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _joystickActive
                        ? GameColors.primaryPurple
                        : GameColors.surfaceLight,
                    _joystickActive
                        ? GameColors.primaryPurple.withValues(alpha: 0.5)
                        : GameColors.surfaceDark,
                  ],
                ),
                boxShadow: _joystickActive
                    ? [
                        BoxShadow(
                          color: GameColors.primaryPurple.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pulsanti di azione (attacco, schivata, evocazione)
  Widget _buildPulsantiAzione() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsante evoca ombre (sopra)
        _buildPulsanteCircolare(
          icona: Icons.groups_rounded,
          colore: GameColors.shadowBlue,
          dimensione: 44,
          onTap: () => widget.game.evocaOmbre(),
          etichetta: 'Ombre',
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsante schivata (sinistra)
            _buildPulsanteCircolare(
              icona: Icons.keyboard_double_arrow_right,
              colore: GameColors.accentCyan,
              dimensione: 48,
              onTap: () => widget.game.schiva(
                widget.game.playerComponent.direzioneVettore,
              ),
              etichetta: 'Schiva',
            ),
            const SizedBox(width: 12),
            // Pulsante attacco (destra, più grande)
            _buildPulsanteCircolare(
              icona: Icons.flash_on_rounded,
              colore: GameColors.healthRed,
              dimensione: 64,
              onTap: () => widget.game.attaccaBase(),
              etichetta: 'Attacca',
            ),
          ],
        ),
      ],
    );
  }

  /// Pulsanti delle abilità
  Widget _buildPulsantiAbilita() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPulsanteAbilita(0, 'Q1', GameColors.primaryPurple),
        const SizedBox(width: 6),
        _buildPulsanteAbilita(1, 'Q2', GameColors.shadowBlue),
        const SizedBox(width: 6),
        _buildPulsanteAbilita(2, 'Q3', GameColors.accentCyan),
        const SizedBox(width: 6),
        _buildPulsanteAbilita(3, 'Q4', GameColors.accentGold),
      ],
    );
  }

  /// Pulsante abilità singolo
  Widget _buildPulsanteAbilita(int indice, String etichetta, Color colore) {
    return GestureDetector(
      onTap: () => widget.game.usaAbilita(indice),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colore.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colore.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            etichetta,
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colore,
            ),
          ),
        ),
      ),
    );
  }

  /// Pulsante circolare generico
  Widget _buildPulsanteCircolare({
    required IconData icona,
    required Color colore,
    required double dimensione,
    required VoidCallback onTap,
    String? etichetta,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dimensione,
            height: dimensione,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colore.withValues(alpha: 0.4),
                  colore.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(color: colore.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: colore.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Icon(icona, color: colore, size: dimensione * 0.45),
          ),
          if (etichetta != null) ...[
            const SizedBox(height: 2),
            Text(
              etichetta,
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 8,
                color: colore.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Pulsante pausa
  Widget _buildPulsantePausa() {
    return GestureDetector(
      onTap: () => widget.game.pausa(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: GameColors.backgroundDark.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: GameColors.borderDefault),
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: GameColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  /// Info del Gate corrente
  Widget _buildInfoGate() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: GameColors.backgroundDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GameColors.primaryPurple.withValues(alpha: 0.3),
          ),
        ),
        child: const Text(
          'GATE E - Piano 1',
          style: TextStyle(
            fontFamily: 'GameFont',
            fontSize: 10,
            color: GameColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

