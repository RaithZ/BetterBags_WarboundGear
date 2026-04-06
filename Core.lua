-- BetterBags - Warbound Gear
-- Registers BetterBags categories for all Warbound Until Equipped gear.
-- Uses BetterBags' pre-computed bindingInfo for detection — no tooltip scanning or extra API calls.
-- Supercedes built-in armor-type categories for warbound items only;
-- soulbound and other gear continues to use BetterBags' built-in categories.

local addonName = ...

local CATEGORY_SINGLE    = "Warbound Gear"
local CATEGORY_ARMOR     = "Warbound Armor"
local CATEGORY_WEAPON    = "Warbound Weapon"
local CATEGORY_ACCESSORY = "Warbound Accessory"

-- const.BINDING_SCOPE.WUE = 9 (Warbound Until Equipped, not yet bound)
-- Resolved from BetterBags constants at load time; falls back to the known value.
local BINDING_WUE = 9

local ARMOR_SLOTS = {
    INVTYPE_HEAD     = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_CHEST    = true,
    INVTYPE_ROBE     = true,
    INVTYPE_WAIST    = true,
    INVTYPE_LEGS     = true,
    INVTYPE_FEET     = true,
    INVTYPE_WRIST    = true,
    INVTYPE_HAND     = true,
    INVTYPE_CLOAK    = true,
}

local ACCESSORY_SLOTS = {
    INVTYPE_FINGER  = true,
    INVTYPE_NECK    = true,
    INVTYPE_TRINKET = true,
}

local function getWarboundCategory(equipLoc, classID)
    if BetterBags_WarboundGearDB.grouped then
        return CATEGORY_SINGLE
    end
    if ACCESSORY_SLOTS[equipLoc] then return CATEGORY_ACCESSORY end
    if ARMOR_SLOTS[equipLoc]     then return CATEGORY_ARMOR end
    if classID == 2              then return CATEGORY_WEAPON end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- Initialize saved variables.
    BetterBags_WarboundGearDB = BetterBags_WarboundGearDB or { grouped = true }

    local ok, BetterBags = pcall(function()
        return LibStub("AceAddon-3.0"):GetAddon("BetterBags")
    end)

    if not ok or not BetterBags then
        print("|cffff4444[BetterBags - Warbound Gear]|r: BetterBags not found.")
        return
    end

    local categories = BetterBags:GetModule("Categories", true)
    if not categories or not categories.RegisterCategoryFunction then
        print("|cffff4444[BetterBags - Warbound Gear]|r: Incompatible BetterBags version — Categories module not found.")
        return
    end

    -- Resolve the WUE constant from BetterBags so we're not hardcoding internals.
    local const = BetterBags:GetModule("Constants", true)
    if const and const.BINDING_SCOPE and const.BINDING_SCOPE.WUE then
        BINDING_WUE = const.BINDING_SCOPE.WUE
    end

    local context = BetterBags:GetModule("Context", true)

    -- Register settings in BetterBags' own plugin config panel.
    local config = BetterBags:GetModule("Config", true)
    if config and config.AddPluginConfig then
        config:AddPluginConfig("Warbound Gear", {
            grouped = {
                type = "toggle",
                name = "Group All Warbound Gear",
                desc = "Group all warbound gear under a single 'Warbound Gear' category. "
                    .. "Uncheck to split into Warbound Armor, Warbound Weapon, and Warbound Accessory.",
                get = function() return BetterBags_WarboundGearDB.grouped end,
                set = function(_, value)
                    BetterBags_WarboundGearDB.grouped = value
                    if context then
                        categories:ReprocessAllItems(context:New('WarboundGear'))
                    end
                end,
            }
        })
    end

    categories:RegisterCategoryFunction(addonName, function(itemData)
        if not itemData or not itemData.itemInfo then return end
        if not itemData.bindingInfo then return end
        if itemData.bindingInfo.binding ~= BINDING_WUE then return end

        local equipLoc = itemData.itemInfo.itemEquipLoc
        if not equipLoc or equipLoc == "" then return end

        return getWarboundCategory(equipLoc, itemData.itemInfo.classID)
    end)
end)
