/// Schermata di selezione Gate di Dark Leveling Infinity
/// Permette di scegliere il rango del Gate prima di entrare nel dungeon
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/player_data.dart';

/// Schermata per selezionare il Gate/Dungeon
class GateSelectScreen extends StatefulWidget {
  final PlayerData playerData;
  final Function(GateRank) onSelezionaGate;
  final VoidCallback onIndietro;

  const GateSelectScreen({
    super.key,
    required this.playerData,
    required this.onSelezionaGate,
    required this.onIndietro,
  });

  @override
  State<GateSelectScreen> createState() => _GateSelectScreenState();
}

class _GateSelectScreenState extends State<GateSelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _portalController;
  GateRank? _gateSelezionato;

  @override
  void initState() {
    super.initState();
    _portalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _portalController.dispose();
    super.dispose();
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

            // Info player
            _buildInfoPlayer(),

            const SizedBox(height: 8),

            // Lista dei gate
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: GateRank.values.length,
                itemBuilder: (context, index) {
                  final gate = GateRank.values[index];
                  final sbloccato = widget.playerData.livello >= gate.livelloConsigliato;

                  return _buildGateCard(gate, sbloccato, index)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        duration: 400.ms,
                      )
                      .slideX(begin: -0.05);
                },
              ),
            ),

            // Pulsante Entra (se un gate è selezionato)
            if (_gateSelezionato != null)
              _buildPulsanteEntra(),
          ],
        ),
      ),
    );
  }

  /// Header della schermata
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            onTap: widget.onIndietro,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: GameColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'SELEZIONA GATE',
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// Info player compatte
  Widget _buildInfoPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(widget.playerData.rango.coloreHex).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Rango badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(widget.playerData.rango.coloreHex).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(widget.playerData.rango.coloreHex)),
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
          ),
          const SizedBox(width: 12),
          Text(
            'Lv. ${widget.playerData.livello}',
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.playerData.gatesCompletati} Gate completati',
            style: const TextStyle(
              fontFamily: 'GameFont',
              fontSize: 11,
              color: GameColors.textDimmed,
            ),
          ),
        ],
      ),
    );
  }

  /// Card di un singolo gate
  Widget _buildGateCard(GateRank gate, bool sbloccato, int index) {
    final selezionato = _gateSelezionato == gate;
    final colore = Color(gate.coloreHex);

    // Calcola la difficoltà relativa al player
    final diffLivello = widget.playerData.livello - gate.livelloConsigliato;
    String difficoltaLabel;
    Color difficoltaColore;

    if (!sbloccato) {
      difficoltaLabel = 'BLOCCATO';
      difficoltaColore = GameColors.textDimmed;
    } else if (diffLivello < -20) {
      difficoltaLabel = 'IMPOSSIBILE';
      difficoltaColore = GameColors.healthRed;
    } else if (diffLivello < -5) {
      difficoltaLabel = 'MOLTO DIFFICILE';
      difficoltaColore = const Color(0xFFFF5722);
    } else if (diffLivello < 5) {
      difficoltaLabel = 'IMPEGNATIVO';
      difficoltaColore = GameColors.staminaYellow;
    } else if (diffLivello < 20) {
      difficoltaLabel = 'NORMALE';
      difficoltaColore = GameColors.expGreen;
    } else {
      difficoltaLabel = 'FACILE';
      difficoltaColore = GameColors.textDimmed;
    }

    return GestureDetector(
      onTap: sbloccato
          ? () {
              setState(() {
                _gateSelezionato = gate;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selezionato
              ? colore.withValues(alpha: 0.15)
              : sbloccato
                  ? GameColors.surfaceDark
                  : GameColors.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selezionato
                ? colore
                : sbloccato
                    ? colore.withValues(alpha: 0.3)
                    : GameColors.borderDefault.withValues(alpha: 0.2),
            width: selezionato ? 2 : 1,
          ),
          boxShadow: selezionato
              ? [
                  BoxShadow(
                    color: colore.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Portale animato
            AnimatedBuilder(
              animation: _portalController,
              builder: (context, child) {
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colore.withValues(alpha: sbloccato ? 0.6 : 0.15),
                        colore.withValues(alpha: sbloccato ? 0.2 : 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: colore.withValues(alpha: sbloccato ? 0.8 : 0.2),
                      width: 2,
                    ),
                    boxShadow: sbloccato
                        ? [
                            BoxShadow(
                              color: colore.withValues(
                                alpha: 0.2 + sin(_portalController.value * pi * 2) * 0.15,
                              ),
                              blurRadius: 8 + sin(_portalController.value * pi * 2) * 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: sbloccato
                        ? Icon(Icons.vpn_lock_rounded, color: colore, size: 20)
                        : Icon(Icons.lock_rounded, color: GameColors.textDimmed.withValues(alpha: 0.3), size: 20),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Info gate
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        gate.nome,
                        style: TextStyle(
                          fontFamily: 'GameFont',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sbloccato ? colore : GameColors.textDimmed,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: difficoltaColore.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          difficoltaLabel,
                          style: TextStyle(
                            fontFamily: 'GameFont',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: difficoltaColore,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Lv. consigliato: ${gate.livelloConsigliato}',
                        style: TextStyle(
                          fontFamily: 'GameFont',
                          fontSize: 10,
                          color: sbloccato ? GameColors.textSecondary : GameColors.textDimmed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${gate.numStanze} stanze',
                        style: TextStyle(
                          fontFamily: 'GameFont',
                          fontSize: 10,
                          color: sbloccato ? GameColors.textSecondary : GameColors.textDimmed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Freccia se sbloccato
            if (sbloccato)
              Icon(
                selezionato ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: selezionato ? colore : GameColors.textDimmed,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  /// Pulsante per entrare nel gate selezionato
  Widget _buildPulsanteEntra() {
    final colore = Color(_gateSelezionato!.coloreHex);

    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => widget.onSelezionaGate(_gateSelezionato!),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colore, colore.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colore.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'ENTRA NEL ${_gateSelezionato!.nome.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}
