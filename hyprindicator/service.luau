local workspace_list = {}
noctalia.state.set("workspaces", workspace_list)

local _fetch_workspaces = function() 
  noctalia.runAsync("hyprctl workspaces -j", function(result) 
    if result.exitCode ~= 0 then
      return
    end

    local infoes, err = noctalia.json.decode(result.stdout)
    if infoes == nil then
      noctalia.log(`failed to fetch info of hyprland workspacs: {err}`)
    end

    local new_workspace_list = {}
    for _, info in ipairs(infoes) do
      if info.id < 0 then
        local workspace_name = info.name:gsub("^special:", "")
        table.insert(new_workspace_list, workspace_name)
      end
    end

    workspace_list = new_workspace_list
    noctalia.state.set("workspaces", new_workspace_list)
  end)
end

local request_workspace_info = function()
  noctalia.runAsync([[hyprctl eval "require('hyprland.noctalia').request_workspace_info()"]])
end

request_workspace_info()

function onIpc(event, payload)
  if event == "created" then
    workspace_list[payload] = false
    noctalia.state.set("workspaces", workspace_list)
  elseif event == "removed" then
    request_workspace_info()
  elseif event == "actived" then
    for name, _ in pairs(workspace_list) do
      workspace_list[name] = name == payload
    end
    noctalia.state.set("workspaces", workspace_list)
  elseif event == "response" then
    local new_workspace_list, err = noctalia.json.decode(payload)
    if new_workspace_list == nil then
      noctalia.log(`failed to fetch info of hyprland workspacs: {err}`)
    end

    workspace_list = new_workspace_list
    noctalia.state.set("workspaces", workspace_list)
  end
end
