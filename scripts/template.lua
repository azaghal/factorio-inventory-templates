-- Copyright (c) 2023 Branko Majic
-- Provided under MIT license. See LICENSE for details.


local utils = require("scripts.utils")


local template = {}


--- Converts inventory configuration into list of (blueprint entity) constant combinators.
--
-- Each slot of inventory configuration is represented by a single constant combinator in the resulting list. Filtered
-- item is set through the first filter slot of the combinator
--
-- @param inventory LuaInventory Inventory for which to generate the list of blueprint entities.
--
-- @return {BlueprintEntity} List of blueprint entities (constant combinators) representing the configuration.
--
function template.inventory_configuration_to_constant_combinators(inventory)

    -- Set-up a list of empty combinators that will represent the configuration.
    local combinators = {}

    for i = 1, #inventory == 0 and 1 or #inventory do

        -- Calculate combinator position in the blueprint. Lay them out in rows, each row with up to 10 slots.
        local x = (i - 1) % 10 + 1
        local y = math.ceil(i/10)

        table.insert(
            combinators,
            {
                entity_number = i,
                name = "constant-combinator",
                position = {x = x, y = y},
                control_behavior = {filters = {}}
            }
        )
    end

    -- Fetch information about inventory limits (bars).
    local bar =
        inventory.supports_bar() and inventory.get_bar() or
        #inventory + 1

    local bar_filter = {
        index = 2,
        count = 0,
        signal = {
            name = "signal-red",
            type = "virtual"
        }
    }

    -- Populate combinators with inventory slot filters.
    for slot_index = 1, #inventory do

        local combinator = combinators[slot_index]
        local item_name = inventory.get_filter(slot_index)

        if item_name then

            -- Minimum quantities are kept in the first slot of the first row.
            local filter = {
                index = 1,
                count = 0,
                signal = {
                    name = item_name,
                    type = "item"
                }
            }
            table.insert(combinator.control_behavior.filters, filter)

        end

        if slot_index >= bar then
            table.insert(combinator.control_behavior.filters, bar_filter)
        end

    end

    return combinators
end


return template
