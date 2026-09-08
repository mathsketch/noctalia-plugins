local indicators = {}
local indicator_size = noctalia.getConfig("size")

local init = function ()
  for key, glyph in pairs(noctalia.getConfig("indicators")) do
    local name, seq = table.unpack(string.split(key, ";"))
    if not name or not seq then
      noctalia.log("invalid format of indicator name for workspace")
      return
    end
    seq = tonumber(seq)

    local pos = seq > #indicators + 1 and #indicators + 1 or seq
    table.insert(indicators, pos, { name = name, glyph = glyph })
  end
end

init()

local hovered_indicator_name = ""

local function render(workspaces)
  local ui_tree = {}
  for _, indicator in ipairs(indicators) do
    local active = workspaces[indicator.name]
    if active ~= nil then
      local hovered = hovered_indicator_name == indicator.name
      table.insert(ui_tree, ui.column({
        align = "center",
        onHover = function(on, key)
          hovered_indicator_name = on == "true" and indicator.name or ""
          render(workspaces)
        end,
        onClick = function()
          noctalia.runAsync(`hyprctl dispatch 'hl.dsp.workspace.toggle_special("{indicator.name}")'`)
        end,
      }, { ui.glyph({ 
        name = indicator.glyph, 
        size = indicator_size,
        color = hovered and "hover" or (active and "secondary" or "on_surface"),
      })}))

      -- use button to show
      -- table.insert(ui_tree, ui.button({ 
      --   glyph = indicator.glyph, 
      --   glyphSize = 16,
      --   variant = "secondary",
      --   contentAlign = "center",
      --   onClick = indicator_callback(indicator.name) 
      -- }))
    end
  end

  local container = barWidget.isVertical() and ui.column or ui.row

  barWidget.render(container({ gap = 6, fill = "#00000000" }, ui_tree))
end

render(noctalia.state.get("workspaces"))
noctalia.state.watch("workspaces", function(workspaces)
  render(workspaces)
end)
