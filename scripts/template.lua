-- Copyright (c) 2023, 2024 Branko Majic
-- Provided under MIT license. See LICENSE for details.


local utils = require("scripts.utils")


local template = {}


--- Checks if passed-in list of blueprint entities constitutes a valid inventory template that can be imported.
--
-- @param inventory LuaInventory Inventory to check the template against.
-- @param blueprint_entities {BlueprintEntity} List of blueprint entities to check.
--
-- @return bool true if passed-in entities constitute valid personal logistics template, false otherwise.
--
function template.is_valid_template(inventory, blueprint_entities)

    -- At least one entity must be present in the blueprint.
    if table_size(blueprint_entities) == 0 then
        return false
    end

    -- Inventory must have at least as many slots as passed-in template.
    if #inventory < table_size(blueprint_entities) then
        return false
    end

    for _, entity in pairs(blueprint_entities) do

        -- Only constant combinators are allowed in the blueprint.
        if entity.name ~= "constant-combinator" then
            return false
        end

        -- Extract list of filters on constant combinator.
        local filters = entity.control_behavior and entity.control_behavior.filters and entity.control_behavior.filters or {}

        -- Maximum two filters can be set.
        if table_size(filters) > 2 then
            return false
        end

        -- Make sure that only two first filters are present, and that they have the correct content type.
        for _, filter in pairs(filters) do
            if filter.index > 2 then
                return false
            elseif filter.index == 1 and filter.signal.type ~= "item" then
                return false
            elseif filter.index == 2 and (filter.signal.type ~= "virtual" or filter.signal.name ~= "signal-red") then
                return false
            end
        end

    end

    return true
end


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
                control_behavior = {sections = {sections = {{filters = {}, index = 1}}}}
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
        name = "signal-red",
        type = "virtual",
        -- Irrelevant for our purposes, but required by game engine.
        comparator = "=",
        quality = "normal"
    }

    -- Populate combinators with inventory slot filters.
    for slot_index = 1, #inventory do

        local combinator = combinators[slot_index]
        local item = inventory.get_filter(slot_index)

        if item then

            -- Minimum quantities are kept in the first slot of the first row.
            local filter = {
                index = 1,
                count = 0,
                name = item.name,
                type = "item",
                -- Irrelevant for our purposes, but required by game engine.
                comparator = "=",
                quality = "normal"
            }
            table.insert(combinator.control_behavior.sections.sections[1].filters, filter)

        end

        if slot_index >= bar then
            table.insert(combinator.control_behavior.sections.sections[1].filters, bar_filter)
        end

    end

    return combinators
end


--- Converts list of (blueprint entity) constant combinators into inventory configuration.
--
-- Function assumes that the passed-in list of constant combinators has been validated already (see
-- template.is_valid_template).
--
-- @param combinators {BlueprintEntity} List of constant combinators representing inventory configuration.
--
-- @return { filters = { uint = string }, limit = uint|nil } Filters map slot index to item name, limit can be nil of no limit is set.
--
function template.constant_combinators_to_inventory_configuration(combinators)

    local filters = {}

    -- Use as initial value to represent that no inventory limit is set.
    local limit = 4294967296

    -- Sort the passed-in combinators by coordinates. This should help get a somewhat sane ordering even if player has
    -- been messing with the constant combinator layout. Slots are read from top to bottom and from left to right.
    local sort_by_coordinate = function(elem1, elem2)
        if elem1.position.y < elem2.position.y then
            return true
        elseif elem1.position.y == elem2.position.y and elem1.position.x < elem2.position.x then
            return true
        end

        return false
    end
    table.sort(combinators, sort_by_coordinate)

    for slot_index, combinator in pairs(combinators) do

        if combinator.control_behavior.sections and combinator.control_behavior.sections.sections[1].filters then

            local combinator_filters = combinator.control_behavior.sections.sections[1].filters

            local item_name =
                combinator_filters[1] and combinator_filters[1].index == 1 and combinator_filters[1].name or
                combinator_filters[2] and combinator_filters[2].index == 1 and combinator_filters[2].name

            local limit_candidate =
                combinator_filters[1] and combinator_filters[1].index == 2 and slot_index or
                combinator_filters[2] and combinator_filters[2].index == 2 and slot_index or
                4294967296

            filters[slot_index] = item_name
            limit = limit_candidate < limit and limit_candidate or limit

        end

    end

    limit = limit ~= 4294967296 and limit or nil

    return {
        filters = filters,
        limit = limit,
    }

end


return template
