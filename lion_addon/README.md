# Lion Addon — Minecraft Bedrock Edition

A custom **Lion** entity for Minecraft Bedrock Edition v1.26+.

## Features

- 🦁 **Hostile Lion mob** — attacks players and passive animals on sight
- 🌍 **Natural spawning** — packs of 2–4 in Savanna biomes
- 🎨 **Hand-authored model** — blocky Minecraft-aesthetic with mane, articulated legs, claws, and a tapered tail
- 🥩 **Loot drops** — leather and raw beef
- 🥚 **Spawn egg** — available in Creative inventory

## Stats

| Property | Value |
|---|---|
| Health | 30 HP |
| Attack damage | 6 |
| Movement speed | 0.35 (sprints at 1.4×) |
| Spawns | Savanna biome, daytime, groups of 2–4 |
| Drops | 0–2 leather, 1 raw beef |

## Installation

1. Download **`lion_addon.mcaddon`** from [Releases](../../releases)
2. Double-click the file — Minecraft opens and imports it automatically
3. Create or edit a world
4. Go to **Behavior Packs** → activate **Lion Addon - Behaviors**
5. Go to **Resource Packs** → activate **Lion Addon - Resources**
6. Enter the world!

## Testing in-game

```
# Summon a lion manually
/summon lion_pack:lion

# Or find wild lions naturally in Savanna biomes
```

## Building from source

Requires Windows with PowerShell.

```powershell
cd lion_addon
.\build.ps1
# Outputs: lion_addon.mcaddon
```

The build script generates the texture (128×64 PNG) using .NET `System.Drawing`, then zips both packs into the `.mcaddon` file.

## Project Structure

```
lion_addon/
├── build.ps1               # Build script (generates texture + packages addon)
├── lion_BP/                # Behavior Pack
│   ├── manifest.json
│   ├── entities/lion.json  # AI, health, attack, loot
│   ├── spawn_rules/        # Savanna biome spawning
│   └── loot_tables/        # Leather + beef drops
└── lion_RP/                # Resource Pack
    ├── manifest.json
    ├── entity/             # Client entity wiring
    ├── models/entity/      # Hand-authored geometry
    ├── animations/         # Walk, idle, attack animations
    ├── animation_controllers/
    ├── render_controllers/
    └── textures/entity/    # Generated 128×64 texture
```

## Compatibility

- Minecraft Bedrock Edition **1.26+**
- Windows 10/11 PC

## Credits

Built with [Antigravity](https://antigravity.dev) AI coding assistant.
