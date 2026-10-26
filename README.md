# SmartTravel

**One button. Everywhere.** A lightweight, class-aware travel macro for **World of Warcraft: Wrath of the Lich King 3.3.5a**.

![SmartTravel cover](SmartTravel-Cover.jpg)

SmartTravel automatically creates and maintains a **single account-wide travel macro** that adapts to your character, known mounts, travel abilities, and current situation. Place that macro on an action bar and use it as your travel button.

## Features

- **Smart mount selection:** chooses from your learned mounts and considers mount speed and where you can fly.
- **Ground mount modifier:** select a ground mount when you want one instead of the normal travel choice.
- **Hearthstone:** use the configurable modifier (Alt by default), or let Hearthstone serve as the fallback when no suitable travel option is available.
- **Direct Hearthstone casting:** when Hearthstone is the selected action—including a fallback—it casts immediately rather than requiring a separate dismount press.
- **Safe mount switching:** when already riding a regular mount on the ground, the first press dismounts and the next press summons the selected mount. Airborne safety checks remain in place.
- **Class-aware:** includes Druid travel forms and Shaman Ghost Wolf handling, with their own combat and travel considerations.
- **Shared macro:** one account-wide macro instead of maintaining different travel macros for each character.
- **Configuration:** choose modifier behavior and mount overrides from the in-game options panel.

## Download

[**Download SmartTravel.zip**](https://github.com/SuttonX/SmartTravel/releases/latest/download/SmartTravel.zip) · [Latest release](https://github.com/SuttonX/SmartTravel/releases/latest)

## Installation

1. Extract the release ZIP into `World of Warcraft/Interface/AddOns/`.
2. Ensure the folder is named `SmartTravel`.
3. Log in and open `/macro`. SmartTravel creates a managed account-wide macro, named with a single space and the `?` icon.
4. Drag that macro to your action bar. **Do not edit its body**; SmartTravel updates it automatically.

The addon is designed for the **3.3.5a client** and does not require modern retail APIs.

## Configuration

Type `/st` to open SmartTravel's options. You can also find its settings under **Interface → AddOns**.

| Command | Action |
| --- | --- |
| `/st` | Open settings |
| `/st refresh` | Refresh the managed travel macro |
| `/st setup` | Refresh the managed travel macro |

The default Hearthstone modifier is **Alt**; the options panel allows changing it or disabling the modifier. Mount overrides are also configured there. Your modifier key is used **together with the SmartTravel macro button**, not as a separate keybind created by the addon.

## Behavior notes

- SmartTravel only uses travel options your character has learned or owns.
- The addon updates the macro out of combat; WoW's secure macro restrictions prevent rewriting it during combat.
- Flight and airborne protection can override a travel request when dismounting would be unsafe.
- Hearthstone still obeys normal game restrictions, including its cooldown and casting rules.
- Macro content is kept within the **255-character limit** of WoW 3.3.5a.

## Compatibility

- **Game:** World of Warcraft: Wrath of the Lich King 3.3.5a
- **Classes:** All, with additional logic for Druids and Shamans
- **UI:** Uses a native macro and works with standard action bars or compatible bar replacements

## Other addons by SuttonX

- [SetupSwap](https://github.com/SuttonX/SetupSwap) — switch addon/UI profiles
- [ConsolePortLK-Enhanced](https://github.com/SuttonX/ConsolePortLK-Enhanced) — improved controller UI for WotLK
- [FormFreedom](https://github.com/SuttonX/FormFreedom) — automatic shapeshift cancellation when needed
- [QuestieAutoTomTom](https://github.com/SuttonX/QuestieAutoTomTom) — Questie objective navigation
- [Classfix](https://github.com/SuttonX/Classfix) — customizable class colors

## Credits

Created by **SuttonX**. Mount speed tier metadata is adapted from **GoGoMount** by Tiker (Rulix).

## Feedback

Report bugs with your class, current zone, mounted/form state, available travel abilities, and the contents of the managed macro.
