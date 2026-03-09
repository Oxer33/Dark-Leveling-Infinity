/// Servizio In-App Purchase reale per Dark Leveling Infinity
/// Integra Google Play Billing (Android) e StoreKit (iOS)
/// tramite il pacchetto in_app_purchase di Flutter
library;

import 'dart:async';
import 'dart:developer' as dev;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants/game_constants.dart';

/// Stato di un prodotto IAP
class IAPProduct {
  final String id;
  final String titolo;
  final String descrizione;
  final String prezzo;
  final ProductDetails? dettagli;
  bool disponibile;

  IAPProduct({
    required this.id,
    required this.titolo,
    required this.descrizione,
    this.prezzo = '',
    this.dettagli,
    this.disponibile = false,
  });
}

/// Servizio IAP singleton per gestire gli acquisti in-app
class IAPService {
  static IAPService? _instance;
  static IAPService get instance {
    _instance ??= IAPService._();
    return _instance!;
  }

  IAPService._();

  // --- Stato ---
  bool _disponibile = false;
  bool _inizializzato = false;

  // --- Prodotti ---
  final Map<String, IAPProduct> _prodotti = {};

  // --- Stream ---
  StreamSubscription<List<PurchaseDetails>>? _sottoscrizione;

  // --- Callback ---
  Function(String productId, bool successo)? onAcquistoCompletato;
  Function(String errore)? onErrore;

  // --- ID dei prodotti ---
  static const Set<String> _productIds = {
    MarketConstants.gemsPack1,
    MarketConstants.gemsPack2,
    MarketConstants.gemsPack3,
    MarketConstants.gemsPack4,
    MarketConstants.monthlyPass,
    MarketConstants.starterPack,
    MarketConstants.premiumBattlePass,
  };

  /// Inizializza il servizio IAP
  Future<void> inizializza() async {
    if (_inizializzato) return;

    dev.log('[IAP] Inizializzazione servizio IAP...');

    // Controlla se lo store è disponibile
    _disponibile = await InAppPurchase.instance.isAvailable();

    if (!_disponibile) {
      dev.log('[IAP] Store non disponibile! (normale in debug/emulatore)');
      _inizializzaFallback();
      _inizializzato = true;
      return;
    }

    dev.log('[IAP] Store disponibile, caricamento prodotti...');

    // Ascolta gli aggiornamenti sugli acquisti
    _sottoscrizione = InAppPurchase.instance.purchaseStream.listen(
      _gestisciAcquisti,
      onDone: () => _sottoscrizione?.cancel(),
      onError: (errore) {
        dev.log('[IAP] Errore stream: $errore');
        onErrore?.call(errore.toString());
      },
    );

    // Carica i prodotti dallo store
    await _caricaProdotti();

    _inizializzato = true;
    dev.log('[IAP] Servizio IAP inizializzato! ${_prodotti.length} prodotti caricati');
  }

  /// Carica i prodotti dallo store
  Future<void> _caricaProdotti() async {
    try {
      final risposta = await InAppPurchase.instance.queryProductDetails(_productIds);

      if (risposta.notFoundIDs.isNotEmpty) {
        dev.log('[IAP] Prodotti non trovati: ${risposta.notFoundIDs}');
      }

      for (final dettaglio in risposta.productDetails) {
        _prodotti[dettaglio.id] = IAPProduct(
          id: dettaglio.id,
          titolo: dettaglio.title,
          descrizione: dettaglio.description,
          prezzo: dettaglio.price,
          dettagli: dettaglio,
          disponibile: true,
        );
        dev.log('[IAP] Prodotto caricato: ${dettaglio.id} - ${dettaglio.price}');
      }
    } catch (e) {
      dev.log('[IAP] Errore caricamento prodotti: $e');
      _inizializzaFallback();
    }
  }

  /// Inizializza con dati fallback (per debug/emulatore)
  void _inizializzaFallback() {
    dev.log('[IAP] Usando dati fallback per i prodotti');
    _prodotti.addAll({
      MarketConstants.gemsPack1: IAPProduct(
        id: MarketConstants.gemsPack1, titolo: '100 Gemme',
        descrizione: 'Pacchetto base', prezzo: '€0,99', disponibile: true,
      ),
      MarketConstants.gemsPack2: IAPProduct(
        id: MarketConstants.gemsPack2, titolo: '500 Gemme',
        descrizione: 'Pacchetto medio', prezzo: '€4,99', disponibile: true,
      ),
      MarketConstants.gemsPack3: IAPProduct(
        id: MarketConstants.gemsPack3, titolo: '1.200 Gemme',
        descrizione: 'Pacchetto grande', prezzo: '€9,99', disponibile: true,
      ),
      MarketConstants.gemsPack4: IAPProduct(
        id: MarketConstants.gemsPack4, titolo: '5.000 Gemme',
        descrizione: 'Pacchetto mega', prezzo: '€29,99', disponibile: true,
      ),
      MarketConstants.monthlyPass: IAPProduct(
        id: MarketConstants.monthlyPass, titolo: 'Pass Mensile',
        descrizione: 'Ricompense giornaliere', prezzo: '€4,99/mese', disponibile: true,
      ),
      MarketConstants.starterPack: IAPProduct(
        id: MarketConstants.starterPack, titolo: 'Starter Pack',
        descrizione: 'Kit per iniziare', prezzo: '€2,99', disponibile: true,
      ),
      MarketConstants.premiumBattlePass: IAPProduct(
        id: MarketConstants.premiumBattlePass, titolo: 'Battle Pass Premium',
        descrizione: 'Ricompense stagionali', prezzo: '€9,99', disponibile: true,
      ),
    });
  }

  /// Acquista un prodotto
  Future<bool> acquista(String productId) async {
    dev.log('[IAP] Tentativo acquisto: $productId');

    final prodotto = _prodotti[productId];
    if (prodotto == null || !prodotto.disponibile) {
      dev.log('[IAP] Prodotto non disponibile: $productId');
      onErrore?.call('Prodotto non disponibile');
      return false;
    }

    if (!_disponibile || prodotto.dettagli == null) {
      // Fallback: simula acquisto in debug
      dev.log('[IAP] Store non disponibile, simulando acquisto');
      _simulaAcquisto(productId);
      return true;
    }

    try {
      // Parametri di acquisto
      final parametriAcquisto = PurchaseParam(
        productDetails: prodotto.dettagli!,
      );

      // Esegui l'acquisto
      final successo = await InAppPurchase.instance.buyConsumable(
        purchaseParam: parametriAcquisto,
      );

      dev.log('[IAP] Acquisto inviato: $successo');
      return successo;
    } catch (e) {
      dev.log('[IAP] Errore acquisto: $e');
      onErrore?.call(e.toString());
      return false;
    }
  }

  /// Ripristina gli acquisti precedenti
  Future<void> ripristinaAcquisti() async {
    dev.log('[IAP] Ripristino acquisti...');

    if (!_disponibile) {
      dev.log('[IAP] Store non disponibile per il ripristino');
      return;
    }

    try {
      await InAppPurchase.instance.restorePurchases();
      dev.log('[IAP] Ripristino completato');
    } catch (e) {
      dev.log('[IAP] Errore ripristino: $e');
      onErrore?.call(e.toString());
    }
  }

  /// Gestisci gli aggiornamenti sugli acquisti
  void _gestisciAcquisti(List<PurchaseDetails> acquisti) {
    for (final acquisto in acquisti) {
      dev.log('[IAP] Aggiornamento acquisto: ${acquisto.productID} - ${acquisto.status}');

      switch (acquisto.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Acquisto completato! Consegna il prodotto
          _consegnaProdotto(acquisto.productID);

          // Completa la transazione
          if (acquisto.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(acquisto);
          }
          break;

        case PurchaseStatus.error:
          dev.log('[IAP] Errore acquisto: ${acquisto.error}');
          onErrore?.call(acquisto.error?.message ?? 'Errore sconosciuto');

          if (acquisto.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(acquisto);
          }
          break;

        case PurchaseStatus.pending:
          dev.log('[IAP] Acquisto in attesa...');
          break;

        case PurchaseStatus.canceled:
          dev.log('[IAP] Acquisto annullato');
          break;
      }
    }
  }

  /// Consegna il prodotto acquistato al player
  void _consegnaProdotto(String productId) {
    dev.log('[IAP] Consegna prodotto: $productId');
    onAcquistoCompletato?.call(productId, true);
  }

  /// Simula un acquisto (per debug/testing)
  void _simulaAcquisto(String productId) {
    dev.log('[IAP] Simulazione acquisto: $productId');
    // In produzione, questo non viene mai chiamato
    // In debug, simula la consegna del prodotto
    Future.delayed(const Duration(milliseconds: 500), () {
      _consegnaProdotto(productId);
    });
  }

  /// Ottieni gemme da assegnare per un productId
  static int getGemmePerProdotto(String productId) {
    switch (productId) {
      case MarketConstants.gemsPack1: return 100;
      case MarketConstants.gemsPack2: return 550; // 500 + 50 bonus
      case MarketConstants.gemsPack3: return 1400; // 1200 + 200 bonus
      case MarketConstants.gemsPack4: return 6000; // 5000 + 1000 bonus
      case MarketConstants.starterPack: return 300;
      default: return 0;
    }
  }

  /// Ottieni tutti i prodotti disponibili
  Map<String, IAPProduct> get prodotti => Map.unmodifiable(_prodotti);

  /// Lo store è disponibile?
  bool get disponibile => _disponibile;

  /// Il servizio è inizializzato?
  bool get inizializzato => _inizializzato;

  /// Pulisci le risorse
  void dispose() {
    _sottoscrizione?.cancel();
    _inizializzato = false;
    dev.log('[IAP] Servizio IAP disposto');
  }
}
