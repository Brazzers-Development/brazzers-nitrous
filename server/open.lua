-- Hooks

local hookId = exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    metadata.nitrous = metadata.nitrous or 'Filled'
    return metadata
end, {
    itemFilter = {
        nitrous = true
    }
})

-- Events

RegisterServerEvent("brazzers-nitrous:client:setNitrousBottle", function(index, slot)
    if not slot then
        local slot = exports.ox_inventory:GetSlotIdWithItem(source, 'nitrous')
        local item = exports.ox_inventory:GetSlot(source, slot)
    
        item.metadata.nitrous = index
        exports.ox_inventory:SetMetadata(source, item.slot, item.metadata)
        return
    end

    slot.metadata.nitrous = index
    exports.ox_inventory:SetMetadata(source, slot.slot, slot.metadata)
end)