-- =====================================================
-- TooltipIDs — SAFE & FUTURE-PROOF (WoW 12.0+ / Midnight)
-- =====================================================

local COLOR_R, COLOR_G, COLOR_B = 1, 0.82, 0

-- -----------------------------------------------------
-- SAFE ADD LINE
-- -----------------------------------------------------
local function AddLine(tooltip, text)
    if not tooltip or tooltip:IsForbidden() then return end
    if type(text) ~= "string" then return end

    tooltip:AddLine(text, COLOR_R, COLOR_G, COLOR_B)
    tooltip:Show()
end

-- -----------------------------------------------------
-- SAFE WRAPPER (evita que un error en una tooltip rompa todo)
-- -----------------------------------------------------
local function SafePostCall(callback)
    return function(tooltip, data)
        local success, err = pcall(callback, tooltip, data)
        if not success then
            -- Puedes descomentar la línea de abajo solo para debug
            -- print("|cffff0000TooltipIDs error:|r", tostring(err))
        end
    end
end

-- -----------------------------------------------------
-- ITEMS
-- -----------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(
    Enum.TooltipDataType.Item,
    SafePostCall(function(tooltip, data)
        if data and data.id then
            AddLine(tooltip, ("Item ID: %d"):format(data.id))
        end
        if data and data.itemLevel then
            AddLine(tooltip, ("Item Level: %d"):format(data.itemLevel))
        end
    end)
)

-- -----------------------------------------------------
-- SPELLS
-- -----------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(
    Enum.TooltipDataType.Spell,
    SafePostCall(function(tooltip, data)
        if data and data.id then
            AddLine(tooltip, ("Spell ID: %d"):format(data.id))
        end
    end)
)

-- -----------------------------------------------------
-- UNITS (NPC / PLAYER) — VERSIÓN ULTRA SEGURA
-- -----------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(
    Enum.TooltipDataType.Unit,
    SafePostCall(function(tooltip, data)
        if not data or not data.guid then return end

        -- Protección crítica contra GUID secreto
        local guid = data.guid
        if type(guid) ~= "string" then return end

        local success, unitType, _, _, _, _, id = pcall(strsplit, "-", guid)
        if not success then return end   -- GUID secreto → salimos sin error

        if (unitType == "Creature" or unitType == "Vehicle") and id then
            AddLine(tooltip, ("NPC ID: %s"):format(id))
        elseif unitType == "Player" and guid then
            AddLine(tooltip, ("Player GUID: %s"):format(guid))
        end
    end)
)

-- -----------------------------------------------------
-- AURAS — MODERN
-- -----------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(
    Enum.TooltipDataType.Aura,
    SafePostCall(function(tooltip, data)
        if not data then return end
        if data.spellID then
            AddLine(tooltip, ("Aura Spell ID: %d"):format(data.spellID))
        end
        if data.sourceUnit then
            AddLine(tooltip, ("Source: %s"):format(tostring(data.sourceUnit)))
        end
    end)
)

-- -----------------------------------------------------
-- AURAS — LEGACY FALLBACK
-- -----------------------------------------------------
hooksecurefunc(GameTooltip, "SetUnitAura", function(tooltip, unit, index, filter)
    if not unit or not index then return end
    local success, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
    if success and aura and aura.spellId then
        AddLine(tooltip, ("Aura Spell ID: %d"):format(aura.spellId))
    end
end)