-- Copyright (c) 2023 Branko Majic
-- Provided under MIT license. See LICENSE for details.


local gui = require("scripts.gui")
local utils = require("scripts.utils")
local inventory = require("scripts.inventory")
local template = require("scripts.template")


local main = {}


--- Initialises global mod data.
--
function main.initialise_data()
    global.player_data = global.player_data or {}

    for index, player in pairs(game.players) do
        main.initialise_player_data(player)
    end
end


--- Initialiases global mod data for a specific player.
--
-- @param player LuaPlayer Player for which to initialise the data.
--
function main.initialise_player_data(player)
    global.player_data[player.index] = global.player_data[player.index] or {}

    gui.initialise(player)
end


--- Updates global mod data.
--
-- @param old_version string Old version of mod.
-- @param new_version string New version of mod.
--
function main.update_data(old_version, new_version)

    -- Ensure the GUI definition is up-to-date for all players.
    if new_version ~= old_version then
        for index, player in pairs(game.players) do
            gui.destroy_player_data(player)
            gui.initialise(player)
        end
    end

end


--- Destroys all mod data for a specific player.
--
-- @param player LuaPlayer Player for which to destroy the data.
--
function main.destroy_player_data(player)
    gui.destroy_player_data(player)

    global.player_data[player.index] = nil
end


--- Updates visibility of buttons for a given player based on held cursor stack.
--
-- @param player LuaPlayer Player for which to update button visibility.
--
function main.update_button_visibility(player)

    -- Assume the GUI should be kept hidden.
    local gui_mode = "hidden"

    -- Retrieve list of blueprint entities.
    local blueprint_entities = player.get_blueprint_entities() or {}

    -- Fetch main inventory corresponding to entity that has its GUI currently open.
    local entity = utils.get_opened_gui_entity(player)
    local inventory = entity and utils.get_entity_inventory(entity) or nil

    -- Check if player is holding a blank blueprint.
    if utils.is_player_holding_blank_editable_blueprint(player) and inventory and inventory.supports_filters() then
        gui_mode = "export"

    -- Check if player is holding a valid blueprint template.
    elseif inventory and inventory.supports_filters() and template.is_valid_template(inventory, blueprint_entities) then

        gui_mode = "import"

    -- Check if player is holding a blank deconstruction planner.
    elseif utils.is_blank_deconstruction_planner(player.cursor_stack) then

        gui_mode = "modify"

    end

    gui.set_mode(player, gui_mode)

end


--- Exports inventory template for requesting player's opened entity into a held (empty) blueprint.
--
-- @param player LuaPlayer Player that has requested the export.
--
function main.export(player)

    local entity = utils.get_opened_gui_entity(player)
    local entity_inventory = utils.get_entity_inventory(entity)

    inventory.export_into_blueprint(entity_inventory, player.cursor_stack)

    -- Player should be holding a valid blueprint template at this point. Make sure correct buttons are visible.
    main.update_button_visibility(player)

end


--- Imports inventory template from a held blueprint.
--
-- @param player LuaPlayer Player that has requested the import.
--
function main.import(player)

    local blueprint_entities = player.get_blueprint_entities()
    local inventory_configuration = template.constant_combinators_to_inventory_configuration(blueprint_entities)
    local entity = utils.get_opened_gui_entity(player)
    local entity_inventory = utils.get_entity_inventory(entity)

    inventory.import(entity_inventory, inventory_configuration)

end


--- Clears all inventory filters.
--
-- @param player LuaPlayer Player that has requested the clearing.
--
function main.clear(player)

    local entity = utils.get_opened_gui_entity(player)
    local entity_inventory = utils.get_entity_inventory(entity)

    inventory.clear(entity_inventory)

end


--- Registers GUI handlers for the module.
--
function main.register_gui_handlers()
    gui.register_handler("it_export_button", main.export)
    gui.register_handler("it_import_button", main.import)
    gui.register_handler("it_clear_button", main.clear)
end


return main
