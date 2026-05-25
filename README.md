# Minecraft Bedrock Addons

A collection of custom Minecraft Bedrock Edition addons by **rosh128-ai**.

## Addons

| Addon | Description | Status |
|---|---|---|
| [🦁 Lion Addon](./lion_addon/) | Hostile Lion mob with mane, articulated legs, and natural spawning in Savanna biomes | ✅ Released |

> More addons coming soon!

## Requirements

- Minecraft Bedrock Edition **v1.26+**
- Windows 10/11 PC

## How to Install Any Addon

1. Download the `.mcaddon` file from the addon's [Releases](../../releases) page
2. Double-click the file — Minecraft opens and imports it automatically
3. Create or edit a world → activate both the **Behavior Pack** and **Resource Pack**
4. That's it!

## How to Build from Source

Each addon has its own `build.ps1` script. Run it from PowerShell:

```powershell
cd lion_addon
.\build.ps1
# Outputs: lion_addon.mcaddon
```

## Contributing

Feel free to open issues or pull requests. All addons use the standard two-pack Bedrock structure (Behavior Pack + Resource Pack).

---

*Built with [Antigravity](https://antigravity.dev) AI assistant.*
