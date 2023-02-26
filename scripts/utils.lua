-- Copyright (c) 2023 Branko Majic
-- Provided under MIT license. See LICENSE for details.


local utils = {}


--- Retrieves entity corresponding to currently opened GUI.
--
-- @param LuaPlayer Player to check the opened GUI for.
--
-- @return LuaEntity|nil Entity for which the current GUI is opened for, or nil in case of unsupported entity.
--
function utils.get_opened_gui_entity(player)

    if player.opened_gui_type == defines.gui_type.controller then
        entity = player.character
    elseif player.opened_gui_type == defines.gui_type.entity and
        (player.opened.type == "spider-vehicle" or player.opened.type == "car"
         or player.opened.type == "cargo-wagon" or player.opened.type == "container") then
        entity = player.opened
    else
        entity = nil
    end

    return entity
end


--- Retrieves main inventory for the passed-in entity.
--
-- Main inventory is player's inventory, car/spidertron trunk etc.
--
-- @param entity LuaEntity Entity for which to fetch the main inventory.
--
-- @return LuaInventory|nil Main inventory for the passed-in entity or nil if unsupported.
--
function utils.get_entity_inventory(entity)

    local inventory_type =
        entity.type == "character" and defines.inventory.character_main or
        entity.type == "spider-vehicle" and defines.inventory.spider_trunk or
        entity.type == "car" and defines.inventory.car_trunk or
        entity.type == "cargo-wagon" and defines.inventory.item_main or
        entity.type == "container" and defines.inventory.item_main or
        nil

    local inventory = inventory_type and entity.get_inventory(inventory_type) or nil

    return inventory

end


return utils
