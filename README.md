# SmartTravel

![SmartTravel cover](SmartTravel-Cover.svg)

**One key. Everywhere.** Intelligent, class-aware travel for **World of Warcraft: Wrath of the Lich King 3.3.5a**.

SmartTravel maintains a single account-wide macro that picks an appropriate travel option for your character, learned mounts, location, and modifiers.

## Features

- Smart ground and flying mount selection, with configurable mount overrides
- Special handling for Druid travel forms and Shaman Ghost Wolf
- Configurable Hearthstone modifier (**Alt** by default)
- Immediate Hearthstone casting when selected, **including automatic fallback**, even while mounted
- Ground-mounted regular mount switching: first press dismounts, second press summons the selected mount
- Airborne safeguards against unwanted dismounts

## Installation

1. Extract the `SmartTravel` addon folder into `World of Warcraft/Interface/AddOns/`.
2. Log in and open `/macro`.
3. Find the account-wide macro maintained by SmartTravel (single-space name and `?` icon).
4. Drag it onto an action bar. **Do not manually edit its body**.

Type **`/st`** to open options, configure your Hearthstone modifier, and select optional mount overrides.

WoW restricts secure macro updates while in combat. Hearthstone still follows its normal cooldown and casting restrictions.

## Other addons by SuttonX

- [SetupSwap](https://github.com/SuttonX/SetupSwap)
- [ConsolePortLK-Enhanced](https://github.com/SuttonX/ConsolePortLK-Enhanced)
- [FormFreedom](https://github.com/SuttonX/FormFreedom)
- [QuestieAutoTomTom](https://github.com/SuttonX/QuestieAutoTomTom)
- [Classfix](https://github.com/SuttonX/Classfix)

## Feedback

Include your class, zone, known mounts, and generated macro when reporting travel-selection issues.
