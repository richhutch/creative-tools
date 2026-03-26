local function rgbToLab(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    if r > 0.04045 then r = ((r + 0.055) / 1.055) ^ 2.4 else r = r / 12.92 end
    if g > 0.04045 then g = ((g + 0.055) / 1.055) ^ 2.4 else g = g / 12.92 end
    if b > 0.04045 then b = ((b + 0.055) / 1.055) ^ 2.4 else b = b / 12.92 end
    local x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
    local y = (r * 0.2126 + g * 0.7152 + b * 0.0722) / 1.00000
    local z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883
    if x > 0.008856 then x = x ^ (1/3) else x = (7.787 * x) + (16/116) end
    if y > 0.008856 then y = y ^ (1/3) else y = (7.787 * y) + (16/116) end
    if z > 0.008856 then z = z ^ (1/3) else z = (7.787 * z) + (16/116) end
    return (116 * y) - 16, 500 * (x - y), 200 * (y - z)
end

local function deltaE(r1, g1, b1, r2, g2, b2)
    local l1, a1, b1 = rgbToLab(r1, g1, b1)
    local l2, a2, b2 = rgbToLab(r2, g2, b2)
    return math.sqrt((l1-l2)^2 + (a1-a2)^2 + (b1-b2)^2)
end

function init(plugin)
    plugin:newCommand{
        id="sim-color-calculator",
        title="Similarity Calculator",
        group="file_scripts",
        onclick=function()
            if not app.activeSprite then
                app.alert("Please open a sprite first!")
                return
            end
            local sprite = app.activeSprite
            local uniqueColors = {}
            local colorSet = {}
            for _, cel in ipairs(sprite.cels) do
                local img = cel.image
                for pixel in img:pixels() do
                    local c = pixel()
                    local r = app.pixelColor.rgbaR(c)
                    local g = app.pixelColor.rgbaG(c)
                    local b = app.pixelColor.rgbaB(c)
                    local a = app.pixelColor.rgbaA(c)
                    if a > 0 then
                        local key = r..","..g..","..b
                        if not colorSet[key] then
                            colorSet[key] = true
                            table.insert(uniqueColors, {r=r, g=g, b=b})
                        end
                    end
                end
            end
            local threshold = 15
            local similarPairs = {}
            for i = 1, #uniqueColors do
                for j = i + 1, #uniqueColors do
                    local c1 = uniqueColors[i]
                    local c2 = uniqueColors[j]
                    local de = deltaE(c1.r, c1.g, c1.b, c2.r, c2.g, c2.b)
                    if de < threshold then
                        table.insert(similarPairs, {c1=c1, c2=c2, de=de})
                    end
                end
            end
            local dlg = Dialog("Similarity Calculator")
            dlg:label{ text="Color Count: " .. #uniqueColors }
            dlg:label{ text="Similar Pairs: " .. #similarPairs }
            dlg:separator{}
            for _, pair in ipairs(similarPairs) do
                local c1 = pair.c1
                local c2 = pair.c2
                dlg:label{ text=string.format("(%d,%d,%d) <-> (%d,%d,%d) dE=%.1f", c1.r, c1.g, c1.b, c2.r, c2.g, c2.b, pair.de) }
            end
            dlg:show()
        end
    }
end