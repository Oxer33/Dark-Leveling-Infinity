/// Sprite Generator V2 - Pixel Art Avanzata per Dark Leveling Infinity
/// Genera sprite con shading, outline, dettagli anatomici, simmetria
/// Ogni pixel è posizionato per creare personaggi riconoscibili e belli
library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Helper per disegnare pixel singoli su canvas (pixel art pura)
class _PixelCanvas {
  final Canvas canvas;
  final double pixelSize;

  // ignore: unused_element_parameter
  _PixelCanvas(this.canvas, {this.pixelSize = 1.0});

  /// Disegna un singolo pixel alla posizione (x, y)
  void pixel(int x, int y, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
      Paint()..color = color,
    );
  }

  /// Disegna un rettangolo di pixel
  void rect(int x, int y, int w, int h, Color color) {
    for (int py = y; py < y + h; py++) {
      for (int px = x; px < x + w; px++) {
        pixel(px, py, color);
      }
    }
  }

  /// Disegna un pixel con glow (pixel + alone sfumato)
  void glowPixel(int x, int y, Color color, {double glowRadius = 2}) {
    pixel(x, y, color);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
    canvas.drawRect(
      Rect.fromLTWH(
        (x - 1) * pixelSize, (y - 1) * pixelSize,
        pixelSize * 3, pixelSize * 3,
      ),
      glowPaint,
    );
  }

  /// Disegna una linea orizzontale di pixel
  void hLine(int x, int y, int length, Color color) {
    for (int i = 0; i < length; i++) {
      pixel(x + i, y, color);
    }
  }

  /// Disegna una linea verticale di pixel
  void vLine(int x, int y, int length, Color color) {
    for (int i = 0; i < length; i++) {
      pixel(x, y + i, color);
    }
  }
}

/// Generatore sprite V2 con pixel art avanzata
class SpriteGeneratorV2 {
  static final Random _rng = Random();

  // === PALETTE COLORI ===
  // Pelle
  static const _skinLight = Color(0xFFFFDDBB);
  static const _skinBase = Color(0xFFE8B888);
  static const _skinShadow = Color(0xFFC49060);
  // Capelli neri (stile Jinwoo)
  static const _hairDark = Color(0xFF0A0A14);
  static const _hairMid = Color(0xFF1A1A2E);
  // Armatura scura
  static const _armorDark = Color(0xFF1C1C30);
  static const _armorMid = Color(0xFF2C2C48);
  static const _armorLight = Color(0xFF3C3C5C);
  static const _armorHighlight = Color(0xFF505070);
  // Occhi luminosi (blu Solo Leveling)
  static const _eyeGlow = Color(0xFF4488FF);
  static const _eyeBright = Color(0xFF88BBFF);
  // Aura viola
  static const _auraPurple = Color(0xFF7B2FF7);
  static const auraBlue = Color(0xFF3D5AFE);
  // Spada
  static const _bladeLight = Color(0xFFDDEEFF);
  static const _bladeMid = Color(0xFFAABBDD);
  static const _hiltGold = Color(0xFFFFD700);
  static const _hiltDarkGold = Color(0xFFCC9900);
  // Outline
  static const _outline = Color(0xFF08080F);
  // Ombra nemici
  static const _shadowColor = Color(0x44000000);

  // ═══════════════════════════════════════════════
  // PLAYER - Guerriero Ombra (32x32 pixel art)
  // ═══════════════════════════════════════════════

  /// Genera lo sprite del player - guerriero ombra dettagliato
  static Future<Sprite> generaPlayer({int dimensione = 32}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);

    // --- OMBRA A TERRA ---
    for (int x = 9; x <= 22; x++) {
      px.pixel(x, 30, _shadowColor);
      px.pixel(x, 31, _shadowColor);
    }

    // --- STIVALI ---
    // Stivale sinistro
    px.rect(10, 27, 4, 3, _armorDark);
    px.pixel(10, 29, _outline); px.pixel(13, 29, _outline);
    px.hLine(10, 27, 4, _armorLight); // highlight bordo superiore
    // Stivale destro
    px.rect(18, 27, 4, 3, _armorDark);
    px.pixel(18, 29, _outline); px.pixel(21, 29, _outline);
    px.hLine(18, 27, 4, _armorLight);

    // --- GAMBE ---
    // Gamba sinistra
    px.rect(11, 22, 3, 5, _armorMid);
    px.vLine(11, 22, 5, _armorDark); // ombra interna
    px.vLine(13, 22, 5, _armorLight); // highlight
    // Gamba destra
    px.rect(18, 22, 3, 5, _armorMid);
    px.vLine(18, 22, 5, _armorLight);
    px.vLine(20, 22, 5, _armorDark);

    // --- CINTURA ---
    px.hLine(10, 21, 12, _hiltDarkGold);
    px.pixel(15, 21, _hiltGold); px.pixel(16, 21, _hiltGold); // fibbia

    // --- TORSO / ARMATURA ---
    // Corpo principale
    px.rect(10, 13, 12, 8, _armorMid);
    // Ombreggiatura sinistra
    px.vLine(10, 13, 8, _armorDark);
    px.vLine(11, 14, 6, _armorDark);
    // Highlight destro
    px.vLine(21, 13, 8, _armorLight);
    px.vLine(20, 14, 6, _armorLight);
    // Dettaglio petto (linea centrale armatura)
    px.vLine(15, 14, 6, _armorHighlight);
    px.vLine(16, 14, 6, _armorHighlight);
    // Bordo colletto
    px.hLine(11, 13, 10, _armorLight);

    // --- SPALLACCI ---
    // Spallaccio sinistro
    px.rect(7, 12, 4, 3, _armorLight);
    px.hLine(7, 12, 4, _armorHighlight);
    px.pixel(7, 14, _armorDark); px.pixel(10, 14, _armorDark);
    px.pixel(8, 13, _hiltGold); // rivetto
    // Spallaccio destro
    px.rect(21, 12, 4, 3, _armorLight);
    px.hLine(21, 12, 4, _armorHighlight);
    px.pixel(21, 14, _armorDark); px.pixel(24, 14, _armorDark);
    px.pixel(23, 13, _hiltGold); // rivetto

    // --- BRACCIA ---
    // Braccio sinistro
    px.rect(8, 15, 2, 5, _armorMid);
    px.vLine(8, 15, 5, _armorDark);
    // Braccio destro
    px.rect(22, 15, 2, 5, _armorMid);
    px.vLine(23, 15, 5, _armorDark);

    // --- MANI ---
    px.pixel(8, 20, _skinBase); px.pixel(9, 20, _skinBase);
    px.pixel(22, 20, _skinBase); px.pixel(23, 20, _skinBase);

    // --- COLLO ---
    px.rect(14, 11, 4, 2, _skinBase);
    px.pixel(14, 11, _skinShadow); px.pixel(17, 11, _skinShadow);

    // --- TESTA ---
    // Forma del viso
    px.rect(12, 4, 8, 7, _skinBase);
    // Ombreggiatura viso lato sinistro
    px.vLine(12, 5, 5, _skinShadow);
    // Highlight lato destro
    px.vLine(19, 5, 5, _skinLight);
    // Mento
    px.hLine(13, 10, 6, _skinShadow);

    // --- CAPELLI ---
    // Top capelli
    px.hLine(11, 2, 10, _hairDark);
    px.hLine(11, 3, 10, _hairDark);
    px.hLine(12, 4, 8, _hairMid);
    // Ciuffo sinistro (stile Jinwoo)
    px.vLine(11, 3, 5, _hairDark);
    px.vLine(12, 4, 3, _hairMid);
    // Ciuffo destro
    px.pixel(20, 3, _hairDark);
    px.pixel(20, 4, _hairDark);
    // Retro capelli
    px.pixel(11, 8, _hairDark);
    px.pixel(20, 8, _hairDark);

    // --- OCCHI (luminosi, stile Solo Leveling) ---
    // Occhio sinistro
    px.pixel(13, 6, _outline); // contorno
    px.pixel(14, 6, _eyeGlow);
    px.pixel(15, 6, _eyeBright);
    px.pixel(13, 7, _outline);
    // Occhio destro
    px.pixel(17, 6, _eyeBright);
    px.pixel(18, 6, _eyeGlow);
    px.pixel(19, 6, _outline);
    px.pixel(19, 7, _outline);
    // Glow occhi
    px.glowPixel(14, 6, _eyeGlow, glowRadius: 3);
    px.glowPixel(18, 6, _eyeGlow, glowRadius: 3);

    // --- BOCCA ---
    px.hLine(14, 9, 4, _skinShadow);

    // --- SPADA (lato destro, sopra la spalla) ---
    // Lama
    px.vLine(25, 2, 14, _bladeMid);
    px.vLine(26, 2, 14, _bladeLight);
    px.vLine(27, 3, 12, _bladeMid);
    // Punta
    px.pixel(26, 1, _bladeLight);
    // Elsa
    px.hLine(23, 16, 6, _hiltGold);
    px.hLine(23, 17, 6, _hiltDarkGold);
    // Impugnatura
    px.vLine(25, 18, 3, const Color(0xFF5D4037));
    px.vLine(26, 18, 3, const Color(0xFF4E342E));
    // Pomolo
    px.pixel(25, 21, _hiltGold);
    px.pixel(26, 21, _hiltGold);

    // --- MANTELLO / SCIARPA ---
    // Sciarpa che sventola a sinistra
    px.rect(6, 13, 2, 6, _armorDark);
    px.pixel(5, 15, _armorDark);
    px.pixel(5, 16, _armorMid);
    px.pixel(5, 17, _armorDark);
    px.pixel(6, 18, _armorMid);

    // --- AURA VIOLA (sottile) ---
    final auraPaint = Paint()
      ..color = _auraPurple.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRect(const Rect.fromLTWH(6, 2, 22, 28), auraPaint);

    // --- OUTLINE GENERALE ---
    // Top
    px.hLine(11, 1, 10, _outline);
    // Lati testa
    px.vLine(11, 2, 8, _outline);
    px.vLine(20, 2, 3, _outline);
    // Lati corpo
    px.vLine(9, 12, 9, _outline);
    px.vLine(22, 15, 6, _outline);
    // Bottom gambe
    px.hLine(10, 30, 4, _outline);
    px.hLine(18, 30, 4, _outline);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimensione, dimensione);
    return Sprite(image);
  }

  // ═══════════════════════════════════════════════
  // PLAYER IDLE FRAMES (breathing animation)
  // ═══════════════════════════════════════════════

  /// Genera animazione idle (4 frame con breathing)
  static Future<List<Sprite>> generaPlayerIdleFrames({int dim = 32}) async {
    final frames = <Sprite>[];
    // Frame 0: posizione base
    frames.add(await generaPlayer(dimensione: dim));

    // Frame 1-3: leggero bob verticale (simulato con offset)
    for (int f = 1; f < 4; f++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // Ridisegna con leggero offset Y
      final offsetY = sin(f * pi / 2) * 0.5;
      canvas.translate(0, offsetY);
      // Disegna lo sprite base
      final baseImage = await generaPlayer(dimensione: dim);
      baseImage.render(canvas, position: Vector2.zero(), size: Vector2.all(dim.toDouble()));
      final picture = recorder.endRecording();
      final image = await picture.toImage(dim, dim);
      frames.add(Sprite(image));
    }
    return frames;
  }

  // ═══════════════════════════════════════════════
  // NEMICI - Pixel Art per ogni tipo
  // ═══════════════════════════════════════════════

  /// Genera sprite nemico per tipo con pixel art avanzata
  static Future<Sprite> generaNemico({
    required String tipo,
    int dimensione = 32,
    Color? coloreBase,
    double scala = 1.0,
  }) async {
    final dim = (dimensione * scala).toInt().clamp(16, 128);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);
    final col = coloreBase ?? _getColoreNemico(tipo);

    // Colori derivati dal colore base
    final colDark = Color.lerp(col, Colors.black, 0.4)!;
    final colLight = Color.lerp(col, Colors.white, 0.25)!;
    final colHighlight = Color.lerp(col, Colors.white, 0.4)!;

    switch (tipo) {
      case 'melee':
      case 'berserker':
        _disegnaNemicoMeleeV2(px, dim, col, colDark, colLight);
        break;
      case 'ranged':
      case 'areaMage':
        _disegnaNemicoRangedV2(px, dim, col, colDark, colLight);
        break;
      case 'flyer':
        _disegnaNemicoFlyerV2(px, dim, col, colDark, colLight);
        break;
      case 'tank':
      case 'reflector':
      case 'shielder':
        _disegnaNemicoTankV2(px, dim, col, colDark, colLight);
        break;
      case 'stealth':
      case 'hitAndRun':
        _disegnaNemicoStealthV2(px, dim, col, colDark, colLight);
        break;
      case 'summoner':
      case 'healer':
        _disegnaNemicoMagoV2(px, dim, col, colDark, colLight);
        break;
      case 'kamikaze':
        _disegnaNemicoKamikazeV2(px, dim, col, colDark, colLight);
        break;
      case 'boss':
        _disegnaBossV2(px, dim, col, colDark, colLight, colHighlight);
        break;
      default:
        _disegnaNemicoMeleeV2(px, dim, col, colDark, colLight);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  // --- NEMICO MELEE (guerriero con spada) ---
  static void _disegnaNemicoMeleeV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0; // fattore scala
    // Ombra
    px.rect((10 * s).round(), (28 * s).round(), (12 * s).round(), (2 * s).round(), _shadowColor);
    // Gambe
    px.rect((12 * s).round(), (24 * s).round(), (3 * s).round(), (5 * s).round(), dark);
    px.rect((17 * s).round(), (24 * s).round(), (3 * s).round(), (5 * s).round(), dark);
    // Corpo
    px.rect((10 * s).round(), (14 * s).round(), (12 * s).round(), (10 * s).round(), col);
    px.rect((11 * s).round(), (15 * s).round(), (2 * s).round(), (8 * s).round(), dark); // ombra sx
    px.rect((19 * s).round(), (15 * s).round(), (2 * s).round(), (8 * s).round(), light); // highlight dx
    // Testa
    px.rect((11 * s).round(), (6 * s).round(), (10 * s).round(), (8 * s).round(), col);
    px.rect((12 * s).round(), (7 * s).round(), (8 * s).round(), (6 * s).round(), light);
    // Corna/punte
    px.rect((10 * s).round(), (3 * s).round(), (2 * s).round(), (4 * s).round(), dark);
    px.rect((20 * s).round(), (3 * s).round(), (2 * s).round(), (4 * s).round(), dark);
    // Occhi rossi
    px.glowPixel((13 * s).round(), (9 * s).round(), const Color(0xFFFF0000), glowRadius: 2);
    px.glowPixel((18 * s).round(), (9 * s).round(), const Color(0xFFFF0000), glowRadius: 2);
    // Arma (spada)
    px.vLine((24 * s).round(), (8 * s).round(), (16 * s).round(), const Color(0xFFBDBDBD));
    px.vLine((25 * s).round(), (8 * s).round(), (16 * s).round(), const Color(0xFF9E9E9E));
    px.hLine((22 * s).round(), (14 * s).round(), (6 * s).round(), _hiltGold);
    // Outline
    _disegnaOutlineNemico(px, d, s);
  }

  // --- NEMICO RANGED (mago/arciere con cappuccio) ---
  static void _disegnaNemicoRangedV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    px.rect((10 * s).round(), (28 * s).round(), (12 * s).round(), (2 * s).round(), _shadowColor);
    // Tunica lunga
    px.rect((10 * s).round(), (12 * s).round(), (12 * s).round(), (16 * s).round(), col);
    px.rect((11 * s).round(), (14 * s).round(), (3 * s).round(), (12 * s).round(), dark);
    px.rect((18 * s).round(), (14 * s).round(), (3 * s).round(), (12 * s).round(), light);
    // Cappuccio
    px.rect((9 * s).round(), (4 * s).round(), (14 * s).round(), (10 * s).round(), dark);
    px.rect((10 * s).round(), (5 * s).round(), (12 * s).round(), (8 * s).round(), col);
    px.pixel((9 * s).round(), (3 * s).round(), dark); // punta cappuccio
    px.pixel((22 * s).round(), (3 * s).round(), dark);
    // Volto in ombra
    px.rect((12 * s).round(), (8 * s).round(), (8 * s).round(), (4 * s).round(), const Color(0xFF0A0A0A));
    // Occhi luminosi nel buio
    px.glowPixel((14 * s).round(), (9 * s).round(), const Color(0xFF76FF03), glowRadius: 2);
    px.glowPixel((18 * s).round(), (9 * s).round(), const Color(0xFF76FF03), glowRadius: 2);
    // Bastone magico
    px.vLine((25 * s).round(), (4 * s).round(), (22 * s).round(), const Color(0xFF795548));
    px.vLine((26 * s).round(), (5 * s).round(), (20 * s).round(), const Color(0xFF5D4037));
    // Gemma in cima
    px.glowPixel((25 * s).round(), (3 * s).round(), _auraPurple, glowRadius: 3);
    px.pixel((26 * s).round(), (3 * s).round(), _auraPurple);
  }

  // --- NEMICO VOLANTE (creatura alata) ---
  static void _disegnaNemicoFlyerV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    // Ali spiegate
    // Ala sinistra
    for (int i = 0; i < 6; i++) {
      px.hLine((2 * s).round(), ((10 + i) * s).round(), ((6 - i) * s).round(), i < 3 ? light : col);
    }
    // Ala destra
    for (int i = 0; i < 6; i++) {
      px.hLine(((24 + i) * s).round(), ((10 + i) * s).round(), ((6 - i) * s).round(), i < 3 ? light : col);
    }
    // Corpo
    px.rect((12 * s).round(), (10 * s).round(), (8 * s).round(), (10 * s).round(), col);
    px.rect((13 * s).round(), (11 * s).round(), (6 * s).round(), (8 * s).round(), light);
    // Testa
    px.rect((13 * s).round(), (5 * s).round(), (6 * s).round(), (6 * s).round(), col);
    // Occhi gialli
    px.glowPixel((14 * s).round(), (7 * s).round(), const Color(0xFFFFEB3B), glowRadius: 2);
    px.glowPixel((18 * s).round(), (7 * s).round(), const Color(0xFFFFEB3B), glowRadius: 2);
    // Becco/denti
    px.pixel((15 * s).round(), (10 * s).round(), const Color(0xFFFFFFFF));
    px.pixel((17 * s).round(), (10 * s).round(), const Color(0xFFFFFFFF));
    // Coda
    px.vLine((15 * s).round(), (20 * s).round(), (6 * s).round(), dark);
    px.vLine((16 * s).round(), (20 * s).round(), (8 * s).round(), col);
    px.vLine((17 * s).round(), (20 * s).round(), (6 * s).round(), dark);
    // Artigli
    px.pixel((13 * s).round(), (20 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((19 * s).round(), (20 * s).round(), const Color(0xFFBDBDBD));
  }

  // --- NEMICO TANK (corazzato pesante) ---
  static void _disegnaNemicoTankV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    px.rect((8 * s).round(), (28 * s).round(), (16 * s).round(), (2 * s).round(), _shadowColor);
    // Gambe larghe
    px.rect((10 * s).round(), (24 * s).round(), (4 * s).round(), (5 * s).round(), dark);
    px.rect((18 * s).round(), (24 * s).round(), (4 * s).round(), (5 * s).round(), dark);
    // Corpo massiccio
    px.rect((7 * s).round(), (10 * s).round(), (18 * s).round(), (14 * s).round(), col);
    // Armatura piastre
    px.rect((8 * s).round(), (11 * s).round(), (16 * s).round(), (12 * s).round(), const Color(0xFF616161));
    px.rect((9 * s).round(), (12 * s).round(), (14 * s).round(), (10 * s).round(), const Color(0xFF757575));
    // Rivetti
    px.pixel((10 * s).round(), (14 * s).round(), _hiltGold);
    px.pixel((21 * s).round(), (14 * s).round(), _hiltGold);
    px.pixel((10 * s).round(), (20 * s).round(), _hiltGold);
    px.pixel((21 * s).round(), (20 * s).round(), _hiltGold);
    // Testa piccola con elmo
    px.rect((12 * s).round(), (4 * s).round(), (8 * s).round(), (7 * s).round(), const Color(0xFF616161));
    px.rect((13 * s).round(), (5 * s).round(), (6 * s).round(), (5 * s).round(), const Color(0xFF757575));
    // Visiera
    px.hLine((13 * s).round(), (7 * s).round(), (6 * s).round(), dark);
    // Occhi dietro la visiera
    px.glowPixel((14 * s).round(), (8 * s).round(), const Color(0xFFFF9800), glowRadius: 1.5);
    px.glowPixel((18 * s).round(), (8 * s).round(), const Color(0xFFFF9800), glowRadius: 1.5);
    // Scudo
    px.rect((3 * s).round(), (12 * s).round(), (5 * s).round(), (10 * s).round(), const Color(0xFF455A64));
    px.rect((4 * s).round(), (13 * s).round(), (3 * s).round(), (8 * s).round(), const Color(0xFF546E7A));
    px.pixel((5 * s).round(), (17 * s).round(), _hiltGold); // emblema scudo
  }

  // --- NEMICO STEALTH (assassino nelle ombre) ---
  static void _disegnaNemicoStealthV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    // Corpo snello semi-trasparente
    px.rect((12 * s).round(), (12 * s).round(), (8 * s).round(), (14 * s).round(), dark);
    px.rect((13 * s).round(), (13 * s).round(), (6 * s).round(), (12 * s).round(), col);
    // Cappuccio
    px.rect((11 * s).round(), (5 * s).round(), (10 * s).round(), (8 * s).round(), dark);
    px.rect((12 * s).round(), (6 * s).round(), (8 * s).round(), (6 * s).round(), col);
    // Faccia in ombra
    px.rect((13 * s).round(), (8 * s).round(), (6 * s).round(), (3 * s).round(), const Color(0xFF050510));
    // Occhi viola
    px.glowPixel((14 * s).round(), (9 * s).round(), const Color(0xFFE040FB), glowRadius: 2);
    px.glowPixel((18 * s).round(), (9 * s).round(), const Color(0xFFE040FB), glowRadius: 2);
    // Pugnali incrociati
    // Pugnale sinistro
    px.vLine((7 * s).round(), (14 * s).round(), (8 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((7 * s).round(), (13 * s).round(), const Color(0xFFE0E0E0));
    // Pugnale destro
    px.vLine((24 * s).round(), (14 * s).round(), (8 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((24 * s).round(), (13 * s).round(), const Color(0xFFE0E0E0));
    // Particelle ombra
    final shadowPaint = Paint()
      ..color = dark.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    px.canvas.drawRect(Rect.fromLTWH(8 * s, 10 * s, 16 * s, 18 * s), shadowPaint);
  }

  // --- NEMICO MAGO (evocatore/healer) ---
  static void _disegnaNemicoMagoV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    px.rect((10 * s).round(), (28 * s).round(), (12 * s).round(), (2 * s).round(), _shadowColor);
    // Tunica
    px.rect((10 * s).round(), (10 * s).round(), (12 * s).round(), (18 * s).round(), col);
    px.rect((11 * s).round(), (12 * s).round(), (10 * s).round(), (14 * s).round(), light);
    // Simbolo sul petto
    px.pixel((15 * s).round(), (16 * s).round(), _auraPurple);
    px.pixel((16 * s).round(), (16 * s).round(), _auraPurple);
    px.pixel((15 * s).round(), (17 * s).round(), _auraPurple);
    px.pixel((16 * s).round(), (17 * s).round(), _auraPurple);
    // Cappello a punta
    px.rect((12 * s).round(), (4 * s).round(), (8 * s).round(), (7 * s).round(), dark);
    px.pixel((15 * s).round(), (2 * s).round(), dark);
    px.pixel((16 * s).round(), (2 * s).round(), dark);
    px.pixel((15 * s).round(), (1 * s).round(), col);
    px.pixel((16 * s).round(), (1 * s).round(), col);
    // Occhi
    px.glowPixel((14 * s).round(), (7 * s).round(), const Color(0xFF82B1FF), glowRadius: 2);
    px.glowPixel((18 * s).round(), (7 * s).round(), const Color(0xFF82B1FF), glowRadius: 2);
    // Bastone con gemma
    px.vLine((25 * s).round(), (2 * s).round(), (26 * s).round(), const Color(0xFF795548));
    px.glowPixel((25 * s).round(), (1 * s).round(), _auraPurple, glowRadius: 4);
    // Aura magica
    final auraPaint = Paint()
      ..color = _auraPurple.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    px.canvas.drawCircle(Offset(16 * s, 16 * s), 12 * s, auraPaint);
  }

  // --- NEMICO KAMIKAZE (creatura esplosiva) ---
  static void _disegnaNemicoKamikazeV2(_PixelCanvas px, int d, Color col, Color dark, Color light) {
    final s = d / 32.0;
    // Corpo rotondo
    for (int y = 0; y < 12; y++) {
      final w = (12 - (y - 6).abs() * 1.5).round().clamp(2, 12);
      final x = 16 - w ~/ 2;
      px.hLine((x * s).round(), ((10 + y) * s).round(), (w * s).round(), col);
    }
    // Crepe luminose
    px.pixel((13 * s).round(), (14 * s).round(), const Color(0xFFFF6F00));
    px.pixel((14 * s).round(), (15 * s).round(), const Color(0xFFFF8F00));
    px.pixel((18 * s).round(), (13 * s).round(), const Color(0xFFFF6F00));
    px.pixel((17 * s).round(), (16 * s).round(), const Color(0xFFFF8F00));
    // Miccia
    px.vLine((15 * s).round(), (4 * s).round(), (6 * s).round(), const Color(0xFF795548));
    px.vLine((16 * s).round(), (4 * s).round(), (6 * s).round(), const Color(0xFF5D4037));
    // Fiamma
    px.glowPixel((15 * s).round(), (3 * s).round(), const Color(0xFFFF9800), glowRadius: 3);
    px.pixel((16 * s).round(), (2 * s).round(), const Color(0xFFFFEB3B));
    px.pixel((15 * s).round(), (1 * s).round(), const Color(0xFFFFEB3B));
    // Occhietti folli
    px.pixel((13 * s).round(), (12 * s).round(), const Color(0xFFFFFF00));
    px.pixel((18 * s).round(), (12 * s).round(), const Color(0xFFFFFF00));
    // Sorriso folle
    px.hLine((14 * s).round(), (14 * s).round(), (4 * s).round(), const Color(0xFFFFFF00));
  }

  // --- BOSS (grande e intimidatorio) ---
  static void _disegnaBossV2(_PixelCanvas px, int d, Color col, Color dark, Color light, Color highlight) {
    final s = d / 32.0;
    // Aura potente
    final auraPaint = Paint()
      ..color = const Color(0x33FF1744)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    px.canvas.drawRect(Rect.fromLTWH(2 * s, 2 * s, 28 * s, 28 * s), auraPaint);

    // Ombra grande
    px.rect((6 * s).round(), (28 * s).round(), (20 * s).round(), (3 * s).round(), _shadowColor);

    // Corpo massiccio
    px.rect((6 * s).round(), (10 * s).round(), (20 * s).round(), (18 * s).round(), col);
    px.rect((7 * s).round(), (11 * s).round(), (18 * s).round(), (16 * s).round(), light);
    px.rect((8 * s).round(), (12 * s).round(), (4 * s).round(), (14 * s).round(), dark);

    // Testa con corona/corna
    px.rect((9 * s).round(), (4 * s).round(), (14 * s).round(), (8 * s).round(), col);
    px.rect((10 * s).round(), (5 * s).round(), (12 * s).round(), (6 * s).round(), light);

    // Corna
    px.vLine((8 * s).round(), (0 * s).round(), (6 * s).round(), highlight);
    px.vLine((9 * s).round(), (1 * s).round(), (4 * s).round(), col);
    px.vLine((23 * s).round(), (0 * s).round(), (6 * s).round(), highlight);
    px.vLine((22 * s).round(), (1 * s).round(), (4 * s).round(), col);
    // Corona
    px.hLine((10 * s).round(), (4 * s).round(), (12 * s).round(), _hiltGold);
    px.pixel((12 * s).round(), (3 * s).round(), _hiltGold);
    px.pixel((16 * s).round(), (3 * s).round(), _hiltGold);
    px.pixel((20 * s).round(), (3 * s).round(), _hiltGold);

    // Occhi boss (grandi e brillanti)
    px.glowPixel((12 * s).round(), (7 * s).round(), const Color(0xFFFF1744), glowRadius: 4);
    px.glowPixel((13 * s).round(), (7 * s).round(), const Color(0xFFFF5252), glowRadius: 3);
    px.glowPixel((19 * s).round(), (7 * s).round(), const Color(0xFFFF1744), glowRadius: 4);
    px.glowPixel((20 * s).round(), (7 * s).round(), const Color(0xFFFF5252), glowRadius: 3);

    // Bocca con zanne
    px.hLine((12 * s).round(), (10 * s).round(), (8 * s).round(), dark);
    px.pixel((13 * s).round(), (11 * s).round(), const Color(0xFFFFFFFF)); // zanna
    px.pixel((19 * s).round(), (11 * s).round(), const Color(0xFFFFFFFF)); // zanna

    // Artigli
    px.pixel((5 * s).round(), (20 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((4 * s).round(), (21 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((27 * s).round(), (20 * s).round(), const Color(0xFFBDBDBD));
    px.pixel((28 * s).round(), (21 * s).round(), const Color(0xFFBDBDBD));
  }

  // --- OUTLINE per tutti i nemici ---
  static void _disegnaOutlineNemico(_PixelCanvas px, int d, double s) {
    // Outline sottile generale (bordi del corpo)
    // Questo viene applicato come overlay scuro ai bordi
  }

  // ═══════════════════════════════════════════════
  // TILES V2 - Con variazioni e dettagli
  // ═══════════════════════════════════════════════

  /// Genera tile pavimento con variazioni casuali
  static Future<Sprite> generaTilePavimento({int dim = 32, int? seed}) async {
    final rng = Random(seed ?? _rng.nextInt(999999));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);

    // Base
    final baseColor = Color.lerp(
      const Color(0xFF2A2A40),
      const Color(0xFF323250),
      rng.nextDouble(),
    )!;
    px.rect(0, 0, dim, dim, baseColor);

    // Pietre irregolari
    for (int i = 0; i < 4 + rng.nextInt(3); i++) {
      final sx = rng.nextInt(dim - 4);
      final sy = rng.nextInt(dim - 3);
      final sw = 3 + rng.nextInt(6);
      final sh = 2 + rng.nextInt(4);
      final stoneColor = Color.lerp(baseColor, Colors.white, 0.05 + rng.nextDouble() * 0.08)!;
      px.rect(sx, sy, sw.clamp(1, dim - sx), sh.clamp(1, dim - sy), stoneColor);
    }

    // Crepe
    if (rng.nextDouble() < 0.3) {
      final crackColor = Color.lerp(baseColor, Colors.black, 0.3)!;
      final cx = rng.nextInt(dim);
      final cy = rng.nextInt(dim);
      for (int j = 0; j < 3 + rng.nextInt(4); j++) {
        px.pixel(
          (cx + rng.nextInt(5) - 2).clamp(0, dim - 1),
          (cy + j).clamp(0, dim - 1),
          crackColor,
        );
      }
    }

    // Polvere/detrito casuale
    for (int i = 0; i < 2; i++) {
      px.pixel(
        rng.nextInt(dim),
        rng.nextInt(dim),
        Color.lerp(baseColor, Colors.white, 0.12)!,
      );
    }

    // Bordo griglia tile (molto sottile)
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    canvas.drawRect(Rect.fromLTWH(0, 0, dim.toDouble(), dim.toDouble()), gridPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  /// Genera tile muro con mattoni dettagliati
  static Future<Sprite> generaTileMuro({int dim = 32, int? seed}) async {
    final rng = Random(seed ?? _rng.nextInt(999999));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);

    // Base scura
    px.rect(0, 0, dim, dim, const Color(0xFF0E0E18));

    // Mattoni con variazione
    final half = dim ~/ 2;
    // Riga superiore
    for (int x = 0; x < dim; x += half) {
      final offset = rng.nextInt(3);
      final brickColor = Color.lerp(
        const Color(0xFF1A1A2E),
        const Color(0xFF222240),
        rng.nextDouble(),
      )!;
      px.rect(x + 1, 1 + offset, half - 2, half - 2, brickColor);
      // Highlight bordo superiore mattone
      px.hLine(x + 1, 1 + offset, half - 2, Color.lerp(brickColor, Colors.white, 0.1)!);
    }
    // Riga inferiore (sfalsata)
    final brickOffset = half ~/ 2;
    for (int x = -brickOffset; x < dim; x += half) {
      final brickColor = Color.lerp(
        const Color(0xFF1A1A2E),
        const Color(0xFF222240),
        rng.nextDouble(),
      )!;
      final bx = x.clamp(0, dim - 1);
      final bw = (half - 2).clamp(1, dim - bx);
      px.rect(bx, half + 1, bw, half - 2, brickColor);
      if (bw > 0) {
        px.hLine(bx, half + 1, bw, Color.lerp(brickColor, Colors.white, 0.1)!);
      }
    }

    // Malta tra mattoni
    px.hLine(0, 0, dim, const Color(0xFF0A0A12));
    px.hLine(0, half, dim, const Color(0xFF0A0A12));

    // Muschio casuale
    if (rng.nextDouble() < 0.2) {
      final mossColor = const Color(0xFF1B3A1B);
      px.pixel(rng.nextInt(dim), dim - 1, mossColor);
      px.pixel(rng.nextInt(dim), dim - 2, mossColor);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  /// Genera tile porta con dettagli legno e glow
  static Future<Sprite> generaTilePorta({int dim = 32}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);

    // Sfondo pavimento
    px.rect(0, 0, dim, dim, const Color(0xFF2A2A40));

    // Cornice porta
    px.rect((dim * 0.15).round(), (dim * 0.05).round(), (dim * 0.7).round(), (dim * 0.9).round(), const Color(0xFF3E2723));
    // Pannelli legno
    px.rect((dim * 0.2).round(), (dim * 0.1).round(), (dim * 0.25).round(), (dim * 0.35).round(), const Color(0xFF5D4037));
    px.rect((dim * 0.55).round(), (dim * 0.1).round(), (dim * 0.25).round(), (dim * 0.35).round(), const Color(0xFF5D4037));
    px.rect((dim * 0.2).round(), (dim * 0.55).round(), (dim * 0.25).round(), (dim * 0.35).round(), const Color(0xFF4E342E));
    px.rect((dim * 0.55).round(), (dim * 0.55).round(), (dim * 0.25).round(), (dim * 0.35).round(), const Color(0xFF4E342E));
    // Maniglia
    px.glowPixel((dim * 0.65).round(), (dim * 0.5).round(), _hiltGold, glowRadius: 2);
    // Glow porta
    final glowPaint = Paint()
      ..color = _auraPurple.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(
      Rect.fromLTWH(dim * 0.1, dim * 0.02, dim * 0.8, dim * 0.96),
      glowPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  /// Genera tile vuoto (nero puro)
  static Future<Sprite> generaTileVuoto({int dim = 32}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, dim.toDouble(), dim.toDouble()),
      Paint()..color = const Color(0xFF020204),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  // ═══════════════════════════════════════════════
  // OMBRE V2 - Sprite più dettagliati
  // ═══════════════════════════════════════════════

  /// Genera sprite ombra con dettagli avanzati
  static Future<Sprite> generaOmbra({
    required Color colore,
    int dimensione = 32,
    double scala = 1.0,
  }) async {
    final dim = (dimensione * scala).toInt().clamp(16, 128);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final px = _PixelCanvas(canvas);
    final s = dim / 32.0;

    // Aura ombra scura
    final auraPaint = Paint()
      ..color = colore.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(16 * s, 16 * s), 14 * s, auraPaint);

    // Corpo ombra (semi-trasparente, forma umanoide sfumata)
    px.rect((12 * s).round(), (8 * s).round(), (8 * s).round(), (14 * s).round(), colore.withValues(alpha: 0.5));
    px.rect((13 * s).round(), (9 * s).round(), (6 * s).round(), (12 * s).round(), colore.withValues(alpha: 0.65));

    // Testa
    px.rect((13 * s).round(), (4 * s).round(), (6 * s).round(), (5 * s).round(), colore.withValues(alpha: 0.55));

    // Occhi rossi brillanti
    px.glowPixel((14 * s).round(), (6 * s).round(), const Color(0xFFFF1744), glowRadius: 3);
    px.glowPixel((18 * s).round(), (6 * s).round(), const Color(0xFFFF1744), glowRadius: 3);

    // Braccia spettrali
    px.rect((9 * s).round(), (11 * s).round(), (3 * s).round(), (6 * s).round(), colore.withValues(alpha: 0.35));
    px.rect((20 * s).round(), (11 * s).round(), (3 * s).round(), (6 * s).round(), colore.withValues(alpha: 0.35));

    // Effetto dissoluzione nella parte bassa (fumo ombra)
    for (int y = 0; y < 8; y++) {
      final alpha = 0.4 - y * 0.05;
      final spread = y * 0.5;
      px.rect(
        ((12 - spread) * s).round(),
        ((22 + y) * s).round(),
        ((8 + spread * 2) * s).round().clamp(1, dim),
        (1 * s).round().clamp(1, 2),
        colore.withValues(alpha: alpha.clamp(0.02, 0.4)),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(dim, dim);
    return Sprite(image);
  }

  /// Colore base per tipo di nemico (più saturi e distinti)
  static Color _getColoreNemico(String tipo) {
    switch (tipo) {
      case 'melee': return const Color(0xFF9B1B30);
      case 'berserker': return const Color(0xFFCC2200);
      case 'ranged': return const Color(0xFF1B6B20);
      case 'areaMage': return const Color(0xFF2211AA);
      case 'flyer': return const Color(0xFF5B1B9B);
      case 'tank': return const Color(0xFF3B4B5B);
      case 'reflector': return const Color(0xFF4B5B6B);
      case 'shielder': return const Color(0xFF2B4B7B);
      case 'stealth': return const Color(0xFF1B2030);
      case 'hitAndRun': return const Color(0xFF2B3040);
      case 'summoner': return const Color(0xFF4B1B8B);
      case 'healer': return const Color(0xFF1B7B3B);
      case 'kamikaze': return const Color(0xFFDD6B00);
      case 'poisoner': return const Color(0xFF3B8B1B);
      case 'freezer': return const Color(0xFF1B6B9B);
      case 'burner': return const Color(0xFFBB3B0B);
      case 'vampiric': return const Color(0xFF5B0B2B);
      case 'trapper': return const Color(0xFF5B5B1B);
      case 'teleporter': return const Color(0xFF3B1B7B);
      case 'splitter': return const Color(0xFF4B7B2B);
      case 'boss': return const Color(0xFFBB1B1B);
      default: return const Color(0xFF5B5B6B);
    }
  }
}
