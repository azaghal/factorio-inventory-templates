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


--- Import inventory configuration.
--
-- @param inventory_ LuaInventory Inventory for which to import the configuration.
-- @param inventory_configuration { filters = { uint = string }, limit = uint|nil } Filters to apply to slots and eventual inventory limit to set.
--
function inventory.import(inventory_, inventory_configuration)

    -- Set-up the filters.
    for slot_index = 1, #inventory_ do
        inventory_.set_filter(slot_index, inventory_configuration.filters[slot_index])
    end

    -- Set the limit if supported and part of inventory configuration.
    if inventory_.supports_bar() and inventory_configuration.limit then
        inventory_.set_bar(inventory_configuration.limit)
    elseif inventory_.supports_bar() then
        inventory_.set_bar()
    end

end


return inventory
