local DEFAULT_DIR = noctalia.expandPath(noctalia.getConfig("save_path"))
local _SELECTIONS_WAYS = {
  "rectangle",
  "fullscreen",
  "windows",
}
local OPENERS = {
  clipboard = {
    cmd = "wl-copy",
    stdin = true,
  },
  show = {
    cmd = "swayimg -",
    stdin = true,
  },
  edit = {
    cmd = "swappy -f -",
    stdin = true,
  },
  save_as = {
    cmd = `zenity --file-selection --filename="{DEFAULT_DIR}" --save --file-filter="image| *.png *.jpg *.jpeg"`,
    stdin = false,
  },
  save = nil,
}

local DELAY = 0.2

noctalia.state.set("last_selection_way", "rectangle")
noctalia.state.set("last_opener", "show")
noctalia.state.set("execute", false)

local SLURP_CMD = "slurp -b '#282828aa' -c '#f2e5bcbb' -B '#28282899' -F 'FiraCode Nerd Font' -w 4 -d"

local function checkCMD(cmd, func)
  if noctalia.commandExists(cmd) then
    return func
  else
    return function() 
      noctalia.notifyError("Can't capture screen", "command (" .. cmd .. ") is not found")
    end
  end
end

local slurp = checkCMD("slurp", function(next)
    noctalia.runAsync({"slurp", "-b", "#282828aa", "-c", "#f2e5bcbb", "-B", "#28282899", "-F", "FiraCode, Nerd, Font", "-w", "4", "-d"}, next, 9999999)
end)

local slurp_with_preselection = checkCMD("slurp", function(preselection, next)
  noctalia.runAsync(`echo "{preselection}" | {SLURP_CMD}`, next, 9999999)
end)

-- capture screen to stdout
local capture_and_open = checkCMD("grim", function(geom, opener)
  local grim_cmd = "grim"
  if geom then
    grim_cmd = `{grim_cmd} -g "{geom}"`
  end

  if opener == nil then
    noctalia.runAsync(`GRIM_DEFAULT_DIR={DEFAULT_DIR} {grim_cmd}`)
    return
  end

  if opener.stdin then
    noctalia.runAsync(`{grim_cmd} - | {opener.cmd}`)
  else
    noctalia.runAsync(opener.cmd, function(result)
      if result.exitCode == 0 then
        noctalia.runAsync(`{grim_cmd} {result.stdout}`)
      else
        noctalia.notify("Cancelled Saving")
      end
    end)
  end
end)

-- on hyprland
local get_window_regions = function(next)
  if noctalia.getenv("XDG_CURRENT_DESKTOP") ~= "Hyprland" then
    noctalia.notifyError("Fetch window's geomtries only be supported on Hyprland")
    return
  end

  noctalia.runAsync({ "hyprctl", "activewindow", "-j" }, function(result)  
    if result.exitCode == 0 then
      local active_window, err = noctalia.json.decode(result.stdout)
      if err then
        noctalia.notifyError("Failed to parse activewindow")
      end

      local active_workspace = active_window.workspace.id
      noctalia.runAsync({ "hyprctl",  "clients", "-j" }, function(result)
        if result.exitCode == 0 then
          local clients, err = noctalia.json.decode(result.stdout)
          if err then
            noctalia.notifyError("Failed to parse clients")
          end

          local geom_infoes = {}
          for _, client in ipairs(clients) do
            if client.workspace.id == active_workspace and client.mapped and not client.hidden then
              table.insert(geom_infoes, `{client.at[1]},{client.at[2]} {client.size[1]}x{client.size[2]} {client.class}}`)
            end
          end

          next(table.concat(geom_infoes, "\n"))
        end
      end)
    end
  end)
end

local function get_geometry(selection_way: string, next)
  if selection_way == "fullscreen" then
    next()
  elseif selection_way == "rectangle" then
    slurp(next)
  elseif selection_way == "windows" then
    get_window_regions(function(preselections)
      slurp_with_preselection(preselections, next)
    end)
  end
end

--- pass seconds
local wait = function(time, next)
  noctalia.runAsync("sleep " .. time, next)
end

local function screenshot()
  local selection_way = noctalia.state.get("last_selection_way")
  local opener = OPENERS[noctalia.state.get("last_opener")]
  wait(DELAY, function() 
    get_geometry(selection_way, function(result)  
      if result == nil or result.exitCode == 0 then
        local geom = result and result.stdout or nil
        capture_and_open(geom, opener)
      else
        noctalia.notify(result.stderr)
      end
    end)
  end)
end

noctalia.state.watch("execute", function(execute)
  if execute then
    screenshot()
    noctalia.state.set("execute", false)
  end
end)

function onIpc(event, payload)
  if event == "capture" then
    screenshot()
  end
end
