local ALL_STATUSES = {}
local current_statuses = {}

local function switch(status)
  local status_info = ALL_STATUSES[status]
  if current_statuses[status_info.class] ~= status then
    current_statuses[status_info.class] = status
    noctalia.runAsync(status_info.switch_to)
  end
end

for key, switch_to in pairs(noctalia.getConfig("status_map")) do
  local status, status_class, active_on_init = table.unpack(string.split(key, ";"))
  if status_class == nil then
    noctalia.log("[plugin(switcher)]: Invalid status class")
    continue
  end

  ALL_STATUSES[status] = {
    class = status_class,
    switch_to = switch_to,
  }

  if active_on_init then
    switch(status)
  end
end

local function find_status_for_class(class)
  local result = {}
  for status, info in pairs(ALL_STATUSES) do
    if info.class == class then
      result[#result + 1] = status
    end
  end
  return result
end

local function toggle(class)
  local statuses = find_status_for_class(class)
  if #statuses ~= 2 then
    noctalia.notify("Not support for class (" .. class .. ")")
    return
  end

  local current_status = current_statuses[class]
  if current_status == nil then
    noctalia.notify("current status is not actived")
    return
  end

  for _, status in ipairs(statuses) do
    if status ~= current_status then
      switch(status)
    end
  end
end

function onIpc(event, payload)
  if event == "toggle" then
    toggle(payload)
  elseif event == "switch" then
    switch(payload)
  end
end
