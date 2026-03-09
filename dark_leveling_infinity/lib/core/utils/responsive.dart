/// Sistema di UI Responsive per Dark Leveling Infinity
/// Adatta dimensioni, spaziature e layout a tutti i dispositivi
/// Supporta smartphone piccoli, grandi, tablet e schermi pieghevoli
library;

import 'dart:developer' as dev;
import 'package:flutter/material.dart';

/// Tipo di dispositivo rilevato
enum DeviceType {
  smartphonePiccolo,  // < 360dp larghezza
  smartphoneMedio,    // 360-400dp
  smartphoneGrande,   // 400-600dp
  tablet,             // 600-900dp
  tabletGrande,       // > 900dp
}

/// Sistema di responsive design per tutti i dispositivi
class Responsive {
  // Dimensioni dello schermo corrente
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _devicePixelRatio = 1;
  static DeviceType _deviceType = DeviceType.smartphoneMedio;

  // Fattore di scala globale
  static double _scaleFactor = 1.0;

  /// Inizializza il sistema responsive con il contesto corrente
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _devicePixelRatio = mediaQuery.devicePixelRatio;

    // Usa la dimensione più piccola per determinare il tipo di dispositivo
    // (supporta sia portrait che landscape)
    final shortestSide = mediaQuery.size.shortestSide;

    if (shortestSide < 360) {
      _deviceType = DeviceType.smartphonePiccolo;
      _scaleFactor = 0.8;
    } else if (shortestSide < 400) {
      _deviceType = DeviceType.smartphoneMedio;
      _scaleFactor = 1.0;
    } else if (shortestSide < 600) {
      _deviceType = DeviceType.smartphoneGrande;
      _scaleFactor = 1.1;
    } else if (shortestSide < 900) {
      _deviceType = DeviceType.tablet;
      _scaleFactor = 1.3;
    } else {
      _deviceType = DeviceType.tabletGrande;
      _scaleFactor = 1.5;
    }

    dev.log('[RESPONSIVE] Schermo: ${_screenWidth.toInt()}x${_screenHeight.toInt()} '
        'DPR: $_devicePixelRatio Tipo: $_deviceType Scala: $_scaleFactor');
  }

  // ─── DIMENSIONI SCALATE ───

  /// Scala un valore in base al dispositivo (per font, icone, spaziature)
  static double scala(double valore) => valore * _scaleFactor;

  /// Scala un valore per i font
  static double font(double dimensioneBase) {
    final scaled = dimensioneBase * _scaleFactor;
    // Limita i font per leggibilità
    return scaled.clamp(dimensioneBase * 0.7, dimensioneBase * 1.8);
  }

  /// Scala un padding/margine
  static double padding(double valoreBase) {
    return valoreBase * _scaleFactor;
  }

  /// Scala una dimensione di icona
  static double icona(double dimensioneBase) {
    return dimensioneBase * _scaleFactor;
  }

  // ─── DIMENSIONI HUD ───

  /// Dimensione del joystick
  static double get joystickSize {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 100;
      case DeviceType.smartphoneMedio: return 120;
      case DeviceType.smartphoneGrande: return 130;
      case DeviceType.tablet: return 150;
      case DeviceType.tabletGrande: return 170;
    }
  }

  /// Dimensione del thumb del joystick
  static double get joystickThumbSize => joystickSize * 0.36;

  /// Dimensione pulsante attacco
  static double get attackButtonSize {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 54;
      case DeviceType.smartphoneMedio: return 64;
      case DeviceType.smartphoneGrande: return 70;
      case DeviceType.tablet: return 80;
      case DeviceType.tabletGrande: return 90;
    }
  }

  /// Dimensione pulsanti abilità
  static double get skillButtonSize {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 34;
      case DeviceType.smartphoneMedio: return 40;
      case DeviceType.smartphoneGrande: return 44;
      case DeviceType.tablet: return 52;
      case DeviceType.tabletGrande: return 60;
    }
  }

  /// Altezza barra HP/MP
  static double get healthBarHeight {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 8;
      case DeviceType.smartphoneMedio: return 10;
      case DeviceType.smartphoneGrande: return 11;
      case DeviceType.tablet: return 14;
      case DeviceType.tabletGrande: return 16;
    }
  }

  /// Margine dal bordo dello schermo
  static double get edgeMargin {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 12;
      case DeviceType.smartphoneMedio: return 16;
      case DeviceType.smartphoneGrande: return 20;
      case DeviceType.tablet: return 28;
      case DeviceType.tabletGrande: return 36;
    }
  }

  /// Margine inferiore per i controlli
  static double get bottomControlsMargin {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 20;
      case DeviceType.smartphoneMedio: return 30;
      case DeviceType.smartphoneGrande: return 35;
      case DeviceType.tablet: return 50;
      case DeviceType.tabletGrande: return 60;
    }
  }

  // ─── LAYOUT ───

  /// Numero di colonne per griglie (inventario, shop, etc.)
  static int get gridColumns {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 4;
      case DeviceType.smartphoneMedio: return 5;
      case DeviceType.smartphoneGrande: return 5;
      case DeviceType.tablet: return 7;
      case DeviceType.tabletGrande: return 8;
    }
  }

  /// Larghezza massima per i dialoghi/popup
  static double get maxDialogWidth {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 260;
      case DeviceType.smartphoneMedio: return 300;
      case DeviceType.smartphoneGrande: return 340;
      case DeviceType.tablet: return 450;
      case DeviceType.tabletGrande: return 550;
    }
  }

  // ─── ZOOM CAMERA ───

  /// Zoom della camera di gioco ottimale per il dispositivo
  static double get cameraZoom {
    switch (_deviceType) {
      case DeviceType.smartphonePiccolo: return 2.0;
      case DeviceType.smartphoneMedio: return 2.5;
      case DeviceType.smartphoneGrande: return 2.8;
      case DeviceType.tablet: return 3.0;
      case DeviceType.tabletGrande: return 3.5;
    }
  }

  // ─── GETTERS ───

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static DeviceType get deviceType => _deviceType;
  static double get scaleFactor => _scaleFactor;

  /// Controlla se il dispositivo è un tablet
  static bool get isTablet =>
      _deviceType == DeviceType.tablet || _deviceType == DeviceType.tabletGrande;

  /// Controlla se il dispositivo è uno smartphone piccolo
  static bool get isSmallPhone => _deviceType == DeviceType.smartphonePiccolo;
}
