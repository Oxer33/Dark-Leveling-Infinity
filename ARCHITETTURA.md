# 🏗️ ARCHITETTURA - Dark Leveling Infinity

## Panoramica
Dark Leveling Infinity è un roguelite RPG per smartphone ispirato all'anime "Solo Leveling".
Sviluppato con **Flutter + Flame Engine** per compatibilità cross-platform (Android/iOS).

---

## 📁 Struttura del Progetto

```
dark_leveling_infinity/
├── lib/
│   ├── main.dart                    # Entry point dell'applicazione
│   ├── app.dart                     # Widget principale, navigazione stati
│   │
│   ├── core/                        # Modulo Core - Costanti e Servizi
│   │   ├── constants/
│   │   │   ├── game_constants.dart  # Costanti numeriche, enum (Ranks, Gates, Rarità)
│   │   │   ├── colors.dart          # Palette colori tema scuro
│   │   │   └── strings.dart         # Stringhe UI localizzate (italiano)
│   │   ├── utils/
│   │   │   └── sprite_generator.dart # Generazione procedurale sprite pixel art
│   │   └── services/
│   │       └── save_service.dart     # Salvataggio/caricamento via SharedPreferences
│   │
│   ├── game/                         # Modulo Game Engine (Flame)
│   │   ├── dark_leveling_game.dart   # Game loop principale, gestione stati
│   │   ├── components/
│   │   │   ├── player/
│   │   │   │   └── player_component.dart  # Player: movimento, stats, combat
│   │   │   ├── enemies/
│   │   │   │   └── enemy_component.dart   # Nemici: 20 tipi AI diversi
│   │   │   ├── shadows/
│   │   │   │   └── shadow_army.dart       # Esercito ombre: estrazione, evocazione
│   │   │   ├── world/
│   │   │   │   └── dungeon_generator.dart # Generazione procedurale dungeon (BSP)
│   │   │   ├── combat/
│   │   │   │   └── combat_system.dart     # Sistema combattimento, abilità, combo
│   │   │   ├── loot/
│   │   │   │   └── inventory_system.dart  # Inventario, equipaggiamento, crafting
│   │   │   └── effects/                   # [DA IMPLEMENTARE] Effetti particellari
│   │   └── systems/
│   │       ├── quest_system.dart          # Quest giornaliere e principali
│   │       └── leveling_system.dart       # Skill tree e assegnazione punti stat
│   │
│   ├── ui/                           # Modulo UI (Flutter Widgets)
│   │   ├── screens/
│   │   │   └── main_menu_screen.dart # Menu principale animato
│   │   ├── widgets/
│   │   │   └── hud_overlay.dart      # HUD in-game (HP, MP, joystick, pulsanti)
│   │   └── overlays/
│   │       ├── pause_overlay.dart    # Overlay pausa
│   │       ├── game_over_overlay.dart # Overlay game over con statistiche
│   │       └── level_up_overlay.dart  # Overlay level up con assegnazione stat
│   │
│   └── data/                          # Modulo Dati
│       ├── models/
│       │   ├── player_data.dart       # Modello dati player (serializzabile)
│       │   ├── enemy_data.dart        # Modello dati nemici e boss
│       │   ├── item_data.dart         # Modello dati oggetti e crafting
│       │   └── quest_data.dart        # Modello dati quest e obiettivi
│       ├── repositories/             # [DA IMPLEMENTARE] Repository pattern
│       └── enemies/
│           ├── enemy_definitions.dart # Database 100 nemici unici
│           └── boss_definitions.dart  # Database 30 boss unici con fasi
│
├── assets/
│   ├── images/                       # Sprite generati proceduralmente
│   ├── audio/                        # [DA IMPLEMENTARE] Audio
│   └── fonts/
│       ├── Rajdhani-Bold.ttf
│       ├── Rajdhani-Medium.ttf
│       └── Rajdhani-Regular.ttf
│
├── android/                          # Configurazione Android
├── ios/                              # Configurazione iOS
├── ARCHITETTURA.md                   # Questo file
└── TODO.md                           # Lista attività
```

---

## 🎮 Architettura del Game Engine

### Pattern: Component-Based Architecture (Flame Engine)
- **DarkLevelingGame** → FlameGame principale con game loop
- **PlayerComponent** → SpriteComponent per il giocatore
- **EnemyComponent** → SpriteComponent per i nemici (20 tipi AI)
- **CombatSystem** → Sistema di combattimento separato
- **DungeonGenerator** → Generazione procedurale BSP

### Flusso di Stato del Gioco
```
menu → caricamento → giocando ↔ pausa
                       ↕
                   levelUp / gameOver
                       ↕
                   inventario / shadowArmy / market
```

### Sistema AI Nemici (20 tipi)
1. **Melee** - Insegue e attacca da vicino
2. **Ranged** - Mantiene distanza, attacca da lontano
3. **HitAndRun** - Colpisce e fugge
4. **Teleporter** - Si teletrasporta vicino al player
5. **Summoner** - Evoca altri nemici
6. **Tank** - Alta difesa, lento
7. **Healer** - Cura i compagni
8. **Kamikaze** - Si avvicina ed esplode
9. **Stealth** - Si rende invisibile
10. **Flyer** - Attacca dall'alto
11. **AreaMage** - Magie ad area
12. **Splitter** - Si divide in copie
13. **Trapper** - Crea trappole
14. **Poisoner** - Avvelena
15. **Freezer** - Congela
16. **Burner** - Brucia
17. **Vampiric** - Assorbe vita
18. **Reflector** - Riflette danni
19. **Shielder** - Crea scudi
20. **Berserker** - Si potenzia quando ferito

---

## 🔧 Stack Tecnologico

| Tecnologia | Versione | Ruolo |
|---|---|---|
| Flutter | 3.x | Framework UI cross-platform |
| Flame | 1.36+ | Game engine 2D |
| Dart | 3.11+ | Linguaggio di programmazione |
| SharedPreferences | 2.5+ | Persistenza dati |
| flutter_animate | 4.5+ | Animazioni UI |
| in_app_purchase | 3.2+ | Acquisti in-app |

---

## 📊 Sistemi Implementati

### ✅ Completati (v2.0)
- [x] Core Game Engine con Flame
- [x] Player Component con stats, movimento, combattimento
- [x] 100 nemici unici con 20 tipi di AI diversa
- [x] 30 boss unici con fasi multiple
- [x] Generazione procedurale dungeon (BSP)
- [x] **Chunk-based infinite world** con 10 biomi diversi
- [x] Combat System con combo, abilità, elementi
- [x] Shadow Army System (estrazione, evocazione, progressione)
- [x] **ShadowComponent visivo** - ombre che combattono nel mondo
- [x] Inventario e Loot System
- [x] Quest System (giornaliere + principali)
- [x] Skill Tree (32+ abilità in 4 categorie)
- [x] Sistema di salvataggio persistente
- [x] UI: Menu principale, HUD, Overlay (pausa, game over, level up)
- [x] **UI Responsive** per tutti i dispositivi (5 device types)
- [x] Sprite generator procedurale
- [x] **Animazioni sprite** (7 per player, 4 per nemici)
- [x] **Effetti particellari avanzati** (15+ tipi di effetti)
- [x] **Damage numbers fluttuanti** e health bar nemici
- [x] **Screen shake** e camera effects
- [x] Sistema ranking Hunter (E→Monarch)
- [x] **Tutorial interattivo** (15 step contestuali)
- [x] **Sistema bilanciamento** (difficoltà adattiva, 5 livelli)
- [x] **IAP reale** con Google Play Billing / StoreKit
- [x] **Achievements** (38 trofei in 5 categorie)
- [x] **Daily login rewards** (30 giorni con bonus settimanali)
- [x] Schermata impostazioni completa
- [x] Market/IAP completo con 3 tab
- [x] **Icona app** generata proceduralmente

### 🔄 Da Completare
- [ ] Sistema audio completo (musica + SFX)
- [ ] Schermata inventario dettagliata con drag&drop
- [ ] Schermata Shadow Army con formazione visiva
- [ ] Schermata skill tree con grafo visuale
- [ ] Leaderboard online
- [ ] Multiplayer (co-op gates)
- [ ] Seasonal events
- [ ] Clan/Guild system

---

## 🎨 Design Principles
- **Tema scuro** con accenti viola/blu (stile Solo Leveling)
- **Messaggi di sistema** in stile [SISTEMA] per immersione
- **UI minimale** durante il gameplay per massimizzare l'area di gioco
- **Touch controls** ottimizzati per mobile (joystick + pulsanti)
- **Sprite procedurali** per ridurre dimensione APK
