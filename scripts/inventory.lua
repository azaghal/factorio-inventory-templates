-- Copyright (c) 2023, 2024 Branko Majic
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

    local combinators = template.inventory_configuration_to_constant_combinators(inventory)

    -- Set the blueprint content and change default icons.
    blueprint.set_blueprint_entities(combinators)
    blueprint.preview_icons = {
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

    -- Keep track of item stacks that do not match-up with underlying filter.
    local filter_incompatible_item_stacks = {}

    -- Set-up the filters.
    for slot_index = 1, #inventory_ do

        local filter_item_name = inventory_configuration.filters[slot_index]
        local slot_stack = inventory_[slot_index]

        inventory_.set_filter(slot_index, filter_item_name)

        if slot_stack.valid_for_read and filter_item_name and slot_stack.name ~= filter_item_name then
            table.insert(filter_incompatible_item_stacks, slot_stack)
        end
    end

    -- Set the limit if supported and part of inventory configuration.
    if inventory_.supports_bar() and inventory_configuration.limit then
        inventory_.set_bar(inventory_configuration.limit)
    elseif inventory_.supports_bar() then
        inventory_.set_bar()
    end

    -- Move non-matching item stacks out of the way.
    for _, item_stack in pairs(filter_incompatible_item_stacks) do

        -- Try to locate a compatible empty slot first.
        local empty_slot_item_stack = inventory_.find_empty_stack(item_stack.name)

        -- Move the item stack into empty slot.
        if empty_slot_item_stack then
            empty_slot_item_stack.swap_stack(item_stack)

        -- Otherwise just spill the items out of the container.
        elseif inventory_.entity_owner then
            local entity = inventory_.entity_owner
            entity.surface.spill_item_stack(entity.position, item_stack, false, nil, false)
            item_stack.clear()
        end

    end

end


--- Clears all inventory filters.
--
-- @param inventory_ LuaInventory Inventory for which to clear the filters.
--
function inventory.clear(inventory_)

    for slot_index = 1, #inventory_ do
        inventory_.set_filter(slot_index, nil)
    end
end


return inventory
