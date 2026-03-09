/// Dark Leveling Infinity - Entry Point
/// Roguelite RPG ispirato a Solo Leveling
/// Sviluppato con Flutter + Flame Engine
library;

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Entry point dell'applicazione
void main() {
  dev.log('[MAIN] Avvio Dark Leveling Infinity...');

  // Assicura che i binding Flutter siano inizializzati
  WidgetsFlutterBinding.ensureInitialized();

  // Imposta lo stile della barra di stato
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  dev.log('[MAIN] Avvio app...');
  runApp(const DarkLevelingApp());
}
