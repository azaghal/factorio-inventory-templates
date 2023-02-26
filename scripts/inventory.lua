-- Copyright (c) 2023 Branko Majic
-- Provided under MIT license. See LICENSE for details.


local template = require("scripts.template")
local utils = require("scripts.utils")


local inventory = {}


--- Exports inventory template into passed-in blueprint.
--
-- @param inventory LuaInventory Inventory to export the template for.
-- @param blueprint LuaItemStack Empty blueprint to export the blueprints into.
--
function inventory.export_into_blueprint(inventory, blueprint)

    local inventory = utils.get_entity_inventory(entity)
    local combinators = template.inventory_configuration_to_constant_combinators(inventory)

    -- Set the blueprint content and change default icons.
    blueprint.set_blueprint_entities(combinators)
    blueprint.blueprint_icons = {
        { index = 1, signal = {type = "virtual", name = "signal-I"}},
        { index = 2, signal = {type = "virtual", name = "signal-T"}},
    }

end


return inventory
