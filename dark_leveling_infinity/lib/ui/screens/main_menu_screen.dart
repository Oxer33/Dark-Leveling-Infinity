/// Schermata del menu principale di Dark Leveling Infinity
/// Menu con sfondo animato, logo e opzioni di gioco
library;

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/services/save_service.dart';

/// Menu principale del gioco
class MainMenuScreen extends StatefulWidget {
  final VoidCallback onNuovaPartita;
  final VoidCallback onContinua;
  final VoidCallback onImpostazioni;
  final VoidCallback onMarket;

  const MainMenuScreen({
    super.key,
    required this.onNuovaPartita,
    required this.onContinua,
    required this.onImpostazioni,
    required this.onMarket,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  bool _hasSalvataggio = false;

  @override
  void initState() {
    super.initState();

    // Controller per le particelle di sfondo
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Controller per il glow del titolo
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Controlla se esiste un salvataggio
    _hasSalvataggio = SaveService.instance.hasSalvataggio();
    dev.log('[MENU] Salvataggio presente: $_hasSalvataggio');
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDark,
      body: Stack(
        children: [
          // Sfondo con gradiente scuro
          _buildSfondo(),

          // Particelle fluttuanti
          _buildParticelle(),

          // Contenuto principale
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo / Titolo del gioco
                  _buildTitolo(),

                  const SizedBox(height: 8),

                  // Sottotitolo
                  _buildSottotitolo(),

                  const Spacer(flex: 2),

                  // Pulsanti del menu
                  _buildMenu(),

                  const Spacer(),

                  // Versione
                  _buildVersione(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sfondo con gradiente scuro e effetto nebbia
  Widget _buildSfondo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.5,
          colors: [
            Color(0xFF1A1A3E),
            Color(0xFF0A0A1A),
            Color(0xFF050510),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// Particelle fluttuanti animate
  Widget _buildParticelle() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(
            progress: _particleController.value,
          ),
        );
      },
    );
  }

  /// Titolo del gioco con effetto glow
  Widget _buildTitolo() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'DARK LEVELING\nINFINITY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
              letterSpacing: 4,
              height: 1.1,
              shadows: [
                Shadow(
                  color: GameColors.primaryPurple.withValues(
                    alpha: 0.5 + _glowController.value * 0.5,
                  ),
                  blurRadius: 20 + _glowController.value * 20,
                ),
                Shadow(
                  color: GameColors.shadowBlue.withValues(
                    alpha: 0.3 + _glowController.value * 0.3,
                  ),
                  blurRadius: 40 + _glowController.value * 30,
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 1200.ms).slideY(begin: -0.2);
  }

  /// Sottotitolo
  Widget _buildSottotitolo() {
    return Text(
      GameStrings.appSubtitle,
      style: TextStyle(
        fontFamily: 'GameFont',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: GameColors.neonPurple.withValues(alpha: 0.8),
        letterSpacing: 3,
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 800.ms);
  }

  /// Menu con pulsanti
  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          // Pulsante Nuova Partita
          _buildPulsanteMenu(
            testo: GameStrings.nuovaPartita,
            icona: Icons.play_arrow_rounded,
            colore: GameColors.primaryPurple,
            onTap: widget.onNuovaPartita,
            delay: 600,
          ),

          const SizedBox(height: 12),

          // Pulsante Continua (se c'è un salvataggio)
          if (_hasSalvataggio)
            _buildPulsanteMenu(
              testo: GameStrings.continuaPartita,
              icona: Icons.refresh_rounded,
              colore: GameColors.shadowBlue,
              onTap: widget.onContinua,
              delay: 700,
            ),

          if (_hasSalvataggio) const SizedBox(height: 12),

          // Pulsante Market
          _buildPulsanteMenu(
            testo: GameStrings.market,
            icona: Icons.store_rounded,
            colore: GameColors.accentGold,
            onTap: widget.onMarket,
            delay: 800,
          ),

          const SizedBox(height: 12),

          // Pulsante Impostazioni
          _buildPulsanteMenu(
            testo: GameStrings.impostazioni,
            icona: Icons.settings_rounded,
            colore: GameColors.textDimmed,
            onTap: widget.onImpostazioni,
            delay: 900,
          ),
        ],
      ),
    );
  }

  /// Pulsante del menu stilizzato
  Widget _buildPulsanteMenu({
    required String testo,
    required IconData icona,
    required Color colore,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: colore.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colore.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colore.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, color: colore, size: 24),
            const SizedBox(width: 12),
            Text(
              testo,
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colore,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: -0.1);
  }

  /// Versione del gioco
  Widget _buildVersione() {
    return Text(
      'v1.0.0',
      style: TextStyle(
        fontFamily: 'GameFont',
        fontSize: 12,
        color: GameColors.textDimmed.withValues(alpha: 0.5),
        letterSpacing: 2,
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }
}

/// Painter per le particelle di sfondo
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Genera particelle basate sul progresso
    for (int i = 0; i < 30; i++) {
      final seed = i * 137.5; // angolo aureo
      final x = (seed % size.width + progress * 50 * (i % 3 + 1)) % size.width;
      final y = (seed * 0.7 % size.height + progress * 30 * (i % 2 + 1)) % size.height;

      final alpha = (0.1 + 0.2 * ((i * 0.1 + progress) % 1.0));

      if (i % 3 == 0) {
        paint.color = GameColors.primaryPurple.withValues(alpha: alpha);
      } else if (i % 3 == 1) {
        paint.color = GameColors.shadowBlue.withValues(alpha: alpha);
      } else {
        paint.color = GameColors.accentCyan.withValues(alpha: alpha * 0.5);
      }

      final radius = 1.0 + (i % 4) * 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
