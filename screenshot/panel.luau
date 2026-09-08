local column = ui.column
local row = ui.row

local function render()
  local function select_way(way)
    return function() 
      noctalia.state.set("last_selection_way", way)
      render()
    end
  end

  local function select_opener(opener)
    return function() 
      noctalia.state.set("last_opener", opener)
      render()
    end
  end

  local function execute()
    panel.close()
    noctalia.state.set("execute", true)
  end

  local last_way = noctalia.state.get("last_selection_way")
  local last_opener = noctalia.state.get("last_opener")

  local icon_size = 18

  local selection_bt_list = {
      ui.button({ glyph = "screenshot", glyphSize = icon_size, variant = "ghost", selected = last_way == "rectangle", onClick = select_way("rectangle")}),
      ui.button({ glyph = "border-none", glyphSize = icon_size, variant = "ghost", selected = last_way == "windows", onClick = select_way("windows")}),
      ui.button({ glyph = "border-corners", glyphSize = icon_size, variant = "ghost", selected = last_way == "fullscreen", onClick = select_way("fullscreen")}),
    }

  local opener_bt_list = {
    ui.button({ glyph = "image", glyphSize = icon_size, variant = "ghost", selected = last_opener == "show", onClick = select_opener("show")}),
    ui.button({ glyph = "clipboard-copy", glyphSize = icon_size, variant = "ghost", selected = last_opener == "clipboard", onClick = select_opener("clipboard")}),
    ui.button({ text = "󰆓", fontSize = icon_size, variant = "ghost", selected = last_opener == "save", onClick = select_opener("save")}),
    ui.button({ text = "󰳻", fontSize = icon_size, variant = "ghost", selected = last_opener == "save_as", onClick = select_opener("save_as")}),
    ui.button({ glyph = "photo-edit", glyphSize = icon_size, variant = "ghost", selected = last_opener == "edit", onClick = select_opener("edit")}),
  }

  local capture_bt = ui.button({ text = "Capture", fontSize = 10, variant = "outline", onClick = execute})
  -- local capture_bt = column({ justify = "center", fill = "surface_variant" }, { ui.label({ text = "Capture", fontSize = 12 }) })

  local selection_title = ui.label({ text = "Way:", fontSize = 11 })
  local opener_title = ui.label({ text = "Opner:" , fontSize = 11})

  panel.render(column({ gap = 0, align = "stretch", justify = "center", flexGrow = 1 }, {
    selection_title,
    ui.separator({ thickness = 0, spacing = 2 }),
    row({ gap = 4, align = "center", justify = "start" }, selection_bt_list),
    ui.spacer(),
    ui.separator({ thickness = 2, spacing = 4 }),
    opener_title,
    ui.separator({ thickness = 0, spacing = 2 }),
    row({ gap = 4, align = "center", justify = "start" }, opener_bt_list),
    ui.separator({ thickness = 0, spacing = 4 }),
    ui.spacer(),
    row({ align = "center", justify = "end" }, { capture_bt }),
  }))
end

render()

-- screenshot("windows")
