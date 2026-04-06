-- BetterBags - Warbound Gear
-- Registers BetterBags categories for all Warbound Until Equipped gear.
-- Uses C_Item.IsBoundToAccountUntilEquip for reliable detection — no tooltip scanning.
-- Supercedes built-in armor-type categories for warbound items only;
-- soulbound and other gear continues to use BetterBags' built-in categories.

local addonName = ...

local CATEGORY_SINGLE    = "Warbound Gear"
local CATEGORY_ARMOR     = "Warbound Armor"
local CATEGORY_WEAPON    = "Warbound Weapon"
local CATEGORY_ACCESSORY = "Warbound Accessory"

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

local function isWarboundUntilEquipped(bagid, slotid)
    if not C_Item.IsBoundToAccountUntilEquip then return false end
    local itemLocation = ItemLocation:CreateFromBagAndSlot(bagid, slotid)
    if not itemLocation:IsValid() then return false end
    return C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

local function getWarboundCategory(equipLoc, classID)
    if BetterBags_WarboundGearDB.grouped then
        return CATEGORY_SINGLE
    end
    if ACCESSORY_SLOTS[equipLoc] then return CATEGORY_ACCESSORY end
    if ARMOR_SLOTS[equipLoc]     then return CATEGORY_ARMOR end
    if classID == 2              then return CATEGORY_WEAPON end
end

local function setupSettings()
    local category = Settings.RegisterVerticalLayoutCategory("BetterBags - Warbound Gear")

    local function GetGrouped()
        return BetterBags_WarboundGearDB.grouped
    end
    local function SetGrouped(_, value)
        BetterBags_WarboundGearDB.grouped = value
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "BBWG_grouped",
        nil,
        Settings.VarType.Boolean,
        "Group All Warbound Gear",
        true,
        GetGrouped,
        SetGrouped
    )

    Settings.CreateCheckBox(
        category,
        setting,
        "Group all warbound gear under a single 'Warbound Gear' category.\n"
        .. "Uncheck to split into Warbound Armor, Warbound Weapon, and Warbound Accessory."
    )

    Settings.RegisterAddOnCategory(category)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- Initialize saved variables.
    BetterBags_WarboundGearDB = BetterBags_WarboundGearDB or { grouped = true }

    setupSettings()

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

    categories:RegisterCategoryFunction(addonName, function(itemData)
        if not itemData or not itemData.itemInfo then return end

        local bagid  = itemData.bagid
        local slotid = itemData.slotid
        if not bagid or not slotid then return end

        if not isWarboundUntilEquipped(bagid, slotid) then return end

        local equipLoc = itemData.itemInfo.itemEquipLoc
        if not equipLoc or equipLoc == "" then return end

        return getWarboundCategory(equipLoc, itemData.itemInfo.classID)
    end)
end)
