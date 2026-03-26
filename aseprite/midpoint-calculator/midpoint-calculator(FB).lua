function init(plugin)
    plugin:newCommand{
        id="midpoint-calculator",
        title="Midpoint Calculator",
        group="file_scripts",
        onclick=function()
            if not app.activeSprite then
                app.alert("Please open a sprite first!")
                return
            end

            local dlg = Dialog("Midpoint Calculator")
            dlg:color{ id="result", label="Midpoint", color=Color(0, 0, 0) }
            dlg:button{ id="calculate", text="Calculate", onclick=function()
                local colorA = app.fgColor
                local colorB = app.bgColor
                local midR = (colorA.red + colorB.red) / 2
                local midG = (colorA.green + colorB.green) / 2
                local midB = (colorA.blue + colorB.blue) / 2
                local midpoint = Color(midR, midG, midB)
                dlg:modify{ id="result", color=midpoint }
                local palette = app.activeSprite.palettes[1]
                local newIndex = #palette
                palette:resize(newIndex + 1)
                palette:setColor(newIndex, midpoint)
            end }

            dlg:show{ wait=false }
            local b = dlg.bounds
            dlg.bounds = Rectangle(8, 305, b.width, b.height)
        end
    }
end