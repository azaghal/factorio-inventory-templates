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


--- Checks if item stack is a blank deconstruction planner.
--
-- @param item_stack LuaItemStack Item stack to check.
--
-- @return bool true if passed-in item stack is blank deconstruction planner, false otherwise.
--
function utils.is_blank_deconstruction_planner(item_stack)
    if item_stack.valid_for_read and
        item_stack.is_deconstruction_item and
        table_size(item_stack.entity_filters) == 0 and
        table_size(item_stack.tile_filters) == 0 then

        return true
    end

    return false
end


--- Checks if the players is holding a blank editable blueprint.
--
-- @param player LuaPlayer Player for which to perform the check.
--
-- @return bool true if player is holding a blank blueprint, false otherwise.

function utils.is_player_holding_blank_editable_blueprint(player)

    local blueprint_entities = player.get_blueprint_entities() or {}

    return table_size(blueprint_entities) == 0 and player.is_cursor_blueprint() and player.cursor_stack.valid_for_read
end


return utils
