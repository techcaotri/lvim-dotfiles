local M = {}

lvim.log.level = "debug"

local Log = require "lvim.core.log"
Log:init()

function tableToJsonStr(inputTable)
  -- get simple json string
  return "{" .. table.concat(inputTable, ",") .. "}"
end

function M:new(path)
  Log:debug("new json file, path: " .. path)
  assert(path, "path should be passed to JsonFile")

  local o = {
    path = path,
  }

  setmetatable(o, self)
  self.__index = self

  o:create_settings_file_if_doesnt_exists()

  return o
end

function M:write(value)
  local encoded_json = vim.json.encode(value)
  Log:debug("json-file write() function called with value: " .. encoded_json)
  local file = io.open(self.path, "w")

  if not file then
    error(string.format("settings.json not found at %s", self.path))
  end

  Log:debug("write json value: " .. encoded_json)
  file:write(encoded_json)
  file:close()

  self.settings_obj = value
end

function M:read()
  if self.settings_obj then
    local encoded_json = vim.json.encode(self.settings_obj)
    Log:debug("json-file:read return cached settings_obj: " .. encoded_json)
    return self.settings_obj
  end

  local file = io.open(self.path, "r")

  if not file then
    error(string.format("settings.json not found at %s", M.path))
  end

  local json_data = file:read("*all")
  Log:debug("json-file read() return json_data: " .. json_data)

  local json = vim.json.decode(json_data)
  file:close()

  self.settings_obj = json

  return json
end

function M:create_settings_file_if_doesnt_exists()
  if self:settings_file_exists() == 0 then
    Log:debug("settings file doesn't exist, creating it: " .. self.path)
    self:create_settings_file()
  end
end

function M:create_settings_file()
  local filePath = self.path
  -- If prent directory doesn't exist, the create it
  local parentDir = filePath:match("(.+)/[^/]*$")
  os.execute("mkdir -p " .. parentDir)

  -- Try opening the file again
  file = io.open(filePath, "w")

  if file then
    -- File opened successfully, do something with it
    -- For example, write some content
    file:write("{}")
    file:close()
  else
    -- Failed to create or open the file
    vim.notify("Cannot save settings: " .. filePath .. ", err: " .. err, vim.log.levels.ERROR)
  end
end

function M:settings_file_exists()
  return vim.fn.filereadable(self.path)
end

return M
