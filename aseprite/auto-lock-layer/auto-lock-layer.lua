local previousLayer= nil

-- is there a file open? If not end script
local function onSiteChange()
    local sprite = app.sprite
    if not sprite then return end

-- Stores current layer
    local currentLayer = app.layer

--Safety Check for deleted layers
    if previousLayer and previousLayer ~= currentLayer then
        local stillValid = false
        for _, layer in ipairs(sprite.layers) do
            if layer == previousLayer then
                stillValid = true
                break
            end
    end
    if stillValid then
        previousLayer.isEditable = false
        app.refresh()
    end
end

if app.layer then
    previousLayer = app.layer
end
end

app.events:on('sitechange', onSiteChange)
app.alert("Auto-lock active! Layers will lock when you leave them.")