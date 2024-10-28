local selectedPropHash = nil  -- Selected prop hash value
local isDisplayingProps = false  -- Prop display status

-- /propcheck command: List props
RegisterCommand("propcheck", function()
    if isDisplayingProps then
        -- print("The props are already being displayed!")
        return
    end

    isDisplayingProps = true

    -- Player coordinates
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Find nearby props
    local props = {}
    for prop in EnumerateObjects() do
        local propCoords = GetEntityCoords(prop)
        local distance = #(playerCoords - propCoords)
        
        if distance < Config.SearchDistance then
            local propHash = GetEntityModel(prop)
            table.insert(props, { prop = prop, hash = propHash, coords = propCoords })
        end
    end

    -- Display prop hashes with 3D text
    Citizen.CreateThread(function()
        local displayEndTime = GetGameTimer() + Config.DisplayDuration * 1000
        while GetGameTimer() < displayEndTime do
            for _, propData in pairs(props) do
                local propCoords = propData.coords
                local propHashText = "Hash: " .. tostring(propData.hash)

                -- Display 3D text above the prop
                DrawText3D(propCoords.x, propCoords.y, propCoords.z + 1.0, propHashText)
            end
            Wait(0)
        end

        -- End display
        isDisplayingProps = false
    end)
end, false)

local selectedPropHash = nil  -- Selected prop hash value

-- /selectprop command: Select the nearest prop and copy its hash
RegisterCommand("selectprop", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestProp = nil
    local closestDistance = Config.SearchDistance  -- Only search props within the specified distance

    for prop in EnumerateObjects() do
        local propCoords = GetEntityCoords(prop)
        local distance = #(playerCoords - propCoords)
        
        if distance < closestDistance then
            closestProp = prop
            closestDistance = distance
        end
    end

    if closestProp then
        selectedPropHash = GetEntityModel(closestProp)  -- Store hash value
        -- Send hash to NUI for clipboard copying
        SendNUIMessage({
            type = "copyToClipboard",
            text = tostring(selectedPropHash)
        })
        TriggerEvent('chat:addMessage', {args = {"Selected prop hash copied to clipboard: " .. tostring(selectedPropHash)}})
    else
        TriggerEvent('chat:addMessage', {args = {"^1No prop nearby!"}})
    end
end, false)

-- Enumerate objects
function EnumerateObjects()
    return coroutine.wrap(function()
        local handle, object = FindFirstObject()
        if not IsEntityDead(object) then
            coroutine.yield(object)
        end
        
        repeat
            local success, object = FindNextObject(handle)
            if success and not IsEntityDead(object) then
                coroutine.yield(object)
            end
        until not success
        EndFindObject(handle)
    end)
end

-- Function to display 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
