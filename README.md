# BetterBags - Warbound Gear

A [BetterBags](https://github.com/Cidan/BetterBags) plugin that automatically categorizes all **Warbound Until Equipped** gear into dedicated categories, superceding BetterBags' built-in armor-type categories for those items.

Soulbound and non-warbound gear is unaffected and continues to use BetterBags' built-in categories normally.

## Categories Added

| Category | Slots |
|---|---|
| **Warbound Armor** | Head, Shoulder, Chest, Waist, Legs, Feet, Wrist, Hand, Cloak |
| **Warbound Weapon** | All weapon types |
| **Warbound Accessory** | Ring, Neck, Trinket |

## Detection

Items are detected dynamically via tooltip — no item ID lists to maintain. Any item with a "Warbound Until Equipped" tooltip line will be categorized automatically, including items from future patches.

## Installation

1. Download and extract to your `Interface/AddOns/` folder.
2. The folder must be named `BetterBags_WarboundGear`.
3. Ensure [BetterBags](https://github.com/Cidan/BetterBags) is installed.

## Requirements

- [BetterBags](https://github.com/Cidan/BetterBags)
- World of Warcraft (Retail)
