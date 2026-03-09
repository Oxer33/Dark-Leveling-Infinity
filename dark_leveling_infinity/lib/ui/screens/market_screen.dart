/// Schermata Market di Dark Leveling Infinity
/// Gestisce gli acquisti in-app: gemme, pass, pacchetti
library;

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/game_constants.dart';

/// Dati di un prodotto nel market
class MarketProduct {
  final String id;
  final String nome;
  final String descrizione;
  final String prezzo;
  final IconData icona;
  final Color colore;
  final String? badge; // "MIGLIORE", "POPOLARE", etc.
  final List<String> contenuto;

  const MarketProduct({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.icona,
    required this.colore,
    this.badge,
    this.contenuto = const [],
  });
}

/// Schermata del negozio con acquisti in-app
class MarketScreen extends StatefulWidget {
  final VoidCallback onChiudi;
  final int gemmeAttuali;
  final int oroAttuale;

  const MarketScreen({
    super.key,
    required this.onChiudi,
    this.gemmeAttuali = 0,
    this.oroAttuale = 0,
  });

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Prodotti del market
  static const List<MarketProduct> _prodottiGemme = [
    MarketProduct(
      id: MarketConstants.gemsPack1,
      nome: '100 Gemme',
      descrizione: 'Pacchetto base di gemme',
      prezzo: '€0,99',
      icona: Icons.diamond,
      colore: GameColors.accentCyan,
      contenuto: ['100 Gemme'],
    ),
    MarketProduct(
      id: MarketConstants.gemsPack2,
      nome: '500 Gemme',
      descrizione: 'Pacchetto medio di gemme',
      prezzo: '€4,99',
      icona: Icons.diamond,
      colore: GameColors.accentCyan,
      badge: 'POPOLARE',
      contenuto: ['500 Gemme', '+50 Bonus'],
    ),
    MarketProduct(
      id: MarketConstants.gemsPack3,
      nome: '1.200 Gemme',
      descrizione: 'Pacchetto grande di gemme',
      prezzo: '€9,99',
      icona: Icons.diamond,
      colore: GameColors.accentGold,
      badge: 'MIGLIORE',
      contenuto: ['1.200 Gemme', '+200 Bonus'],
    ),
    MarketProduct(
      id: MarketConstants.gemsPack4,
      nome: '5.000 Gemme',
      descrizione: 'Pacchetto mega di gemme',
      prezzo: '€29,99',
      icona: Icons.diamond,
      colore: GameColors.accentGold,
      contenuto: ['5.000 Gemme', '+1.000 Bonus'],
    ),
  ];

  static const List<MarketProduct> _prodottiSpeciali = [
    MarketProduct(
      id: MarketConstants.starterPack,
      nome: 'Pacchetto Cacciatore',
      descrizione: 'Il kit perfetto per iniziare la tua avventura!',
      prezzo: '€2,99',
      icona: Icons.backpack_rounded,
      colore: GameColors.primaryPurple,
      badge: 'OFFERTA',
      contenuto: [
        '300 Gemme',
        '5.000 Oro',
        'Spada d\'Acciaio',
        'Armatura di Cuoio',
        '10 Pozioni HP',
      ],
    ),
    MarketProduct(
      id: MarketConstants.monthlyPass,
      nome: 'Pass Cacciatore Mensile',
      descrizione: 'Ricompense giornaliere per 30 giorni!',
      prezzo: '€4,99/mese',
      icona: Icons.card_membership_rounded,
      colore: GameColors.accentGold,
      contenuto: [
        '50 Gemme/giorno',
        '+30% EXP',
        '+20% Oro',
        'Skin esclusiva',
      ],
    ),
    MarketProduct(
      id: MarketConstants.premiumBattlePass,
      nome: 'Battle Pass Premium',
      descrizione: 'Sblocca ricompense esclusive durante la stagione!',
      prezzo: '€9,99',
      icona: Icons.military_tech_rounded,
      colore: GameColors.healthRed,
      badge: 'STAGIONALE',
      contenuto: [
        '50 livelli di ricompense',
        'Armi leggendarie esclusive',
        'Skins uniche',
        '2.000 Gemme totali',
        'Ombre rare',
      ],
    ),
  ];

  // Prodotti acquistabili con gemme (in-game)
  static const List<MarketProduct> _negozioGemme = [
    MarketProduct(
      id: 'shop_gold_1000',
      nome: '1.000 Oro',
      descrizione: 'Scambia gemme per oro',
      prezzo: '10 Gemme',
      icona: Icons.monetization_on,
      colore: GameColors.accentGold,
    ),
    MarketProduct(
      id: 'shop_gold_10000',
      nome: '10.000 Oro',
      descrizione: 'Pacchetto oro grande',
      prezzo: '90 Gemme',
      icona: Icons.monetization_on,
      colore: GameColors.accentGold,
      badge: '-10%',
    ),
    MarketProduct(
      id: 'shop_hp_potions',
      nome: '50 Pozioni HP Grande',
      descrizione: 'Scorta di pozioni di vita',
      prezzo: '30 Gemme',
      icona: Icons.favorite_rounded,
      colore: GameColors.healthRed,
    ),
    MarketProduct(
      id: 'shop_shadow_slot',
      nome: '+10 Slot Ombre',
      descrizione: 'Espandi il tuo esercito di ombre',
      prezzo: '50 Gemme',
      icona: Icons.groups_rounded,
      colore: GameColors.shadowBlue,
    ),
    MarketProduct(
      id: 'shop_inventory_slot',
      nome: '+20 Slot Inventario',
      descrizione: 'Più spazio per gli oggetti',
      prezzo: '25 Gemme',
      icona: Icons.inventory_2_rounded,
      colore: GameColors.neonPurple,
    ),
    MarketProduct(
      id: 'shop_exp_boost',
      nome: 'Boost EXP x2 (1h)',
      descrizione: 'Raddoppia l\'esperienza per 1 ora',
      prezzo: '20 Gemme',
      icona: Icons.trending_up_rounded,
      colore: GameColors.expGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            // Tab bar
            _buildTabBar(),
            // Contenuto
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListaProdotti(_prodottiGemme, isRealMoney: true),
                  _buildListaProdotti(_prodottiSpeciali, isRealMoney: true),
                  _buildListaProdotti(_negozioGemme, isRealMoney: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header con saldo
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
          const Text(
            'MARKET',
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GameColors.textPrimary,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          // Saldo gemme
          _buildSaldo(Icons.diamond, '${widget.gemmeAttuali}', GameColors.accentCyan),
          const SizedBox(width: 12),
          // Saldo oro
          _buildSaldo(Icons.monetization_on, '${widget.oroAttuale}', GameColors.accentGold),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Indicatore saldo
  Widget _buildSaldo(IconData icona, String valore, Color colore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colore.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colore.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, size: 16, color: colore),
          const SizedBox(width: 4),
          Text(
            valore,
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colore,
            ),
          ),
        ],
      ),
    );
  }

  /// Tab bar
  Widget _buildTabBar() {
    return Container(
      color: GameColors.backgroundMedium,
      child: TabBar(
        controller: _tabController,
        indicatorColor: GameColors.primaryPurple,
        labelColor: GameColors.primaryPurple,
        unselectedLabelColor: GameColors.textDimmed,
        labelStyle: const TextStyle(
          fontFamily: 'GameFont',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        tabs: const [
          Tab(text: 'GEMME'),
          Tab(text: 'SPECIALI'),
          Tab(text: 'NEGOZIO'),
        ],
      ),
    );
  }

  /// Lista prodotti
  Widget _buildListaProdotti(List<MarketProduct> prodotti, {bool isRealMoney = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: prodotti.length,
      itemBuilder: (context, index) {
        return _buildCardProdotto(prodotti[index], isRealMoney: isRealMoney)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 300.ms)
            .slideY(begin: 0.05);
      },
    );
  }

  /// Card singolo prodotto
  Widget _buildCardProdotto(MarketProduct prodotto, {bool isRealMoney = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: prodotto.colore.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: prodotto.colore.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icona
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: prodotto.colore.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(prodotto.icona, color: prodotto.colore, size: 28),
                ),
                if (prodotto.badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: GameColors.healthRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        prodotto.badge!,
                        style: const TextStyle(
                          fontFamily: 'GameFont',
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prodotto.nome,
                  style: const TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GameColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prodotto.descrizione,
                  style: const TextStyle(
                    fontFamily: 'GameFont',
                    fontSize: 10,
                    color: GameColors.textDimmed,
                  ),
                ),
                if (prodotto.contenuto.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: prodotto.contenuto.map((c) => Text(
                      '• $c',
                      style: TextStyle(
                        fontFamily: 'GameFont',
                        fontSize: 9,
                        color: prodotto.colore.withValues(alpha: 0.7),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Pulsante acquisto
          GestureDetector(
            onTap: () => _acquista(prodotto, isRealMoney),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    prodotto.colore,
                    prodotto.colore.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: prodotto.colore.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: Text(
                prodotto.prezzo,
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gestisci l'acquisto di un prodotto
  void _acquista(MarketProduct prodotto, bool isRealMoney) {
    dev.log('[MARKET] Tentativo acquisto: ${prodotto.nome} (${prodotto.prezzo})');

    if (isRealMoney) {
      // Per acquisti con soldi reali, usa il sistema IAP
      dev.log('[MARKET] Acquisto IAP: ${prodotto.id}');
      _mostraDialogoAcquisto(prodotto);
    } else {
      // Per acquisti con gemme in-game
      dev.log('[MARKET] Acquisto con gemme: ${prodotto.id}');
      _mostraDialogoAcquisto(prodotto);
    }
  }

  /// Mostra dialogo di conferma acquisto
  void _mostraDialogoAcquisto(MarketProduct prodotto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.backgroundMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: prodotto.colore.withValues(alpha: 0.5)),
        ),
        title: Text(
          'Conferma Acquisto',
          style: TextStyle(
            fontFamily: 'GameFont',
            color: prodotto.colore,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Vuoi acquistare ${prodotto.nome} per ${prodotto.prezzo}?',
          style: const TextStyle(
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
              dev.log('[MARKET] Acquisto confermato: ${prodotto.id}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Acquisto di ${prodotto.nome} completato!',
                    style: const TextStyle(fontFamily: 'GameFont'),
                  ),
                  backgroundColor: prodotto.colore,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'ACQUISTA',
              style: TextStyle(
                fontFamily: 'GameFont',
                color: prodotto.colore,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
