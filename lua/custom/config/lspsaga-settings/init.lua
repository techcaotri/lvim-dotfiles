local config = require("custom.config.lspsaga-settings.config")
local JsonFile = require("custom.config.lspsaga-settings.json-file")

-- lvim.log.level = "debug"

local Log = require "lvim.core.log"
Log:init()

local M = {
  settings_file = nil,
}


function M:new(setting_name)
  assert(setting_name, "A unique setting name should be passed to the class")
  assert(type(setting_name), "Type of the setting name should be an string")

  local o = {
    key = setting_name,
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function M:get_settings()
  Log:debug("get_settings called")
  local gsettings = M.get_settings_file():read()
  -- Log:debug("get_settings: Get settings from file return gsettings: " .. tableToJsonStr(gsettings))
  Log:debug(gsettings)

  local local_settings = gsettings[self.key]
  if not local_settings then
    self:save_settings(vim.empty_dict())
  end

  return gsettings[self.key]
end

function M:save_settings(settings)
  local gsettings = M.get_settings_file():read()

  Log:debug("save_settings called")
  Log:debug(gsettings)
  Log:debug("save_settings(): inspect settings:")
  Log:debug(settings)
  local merged_settings = settings
  if gsettings ~= nil and gsettings[self.key] ~= nill then
    merged_settings = vim.tbl_deep_extend("force", gsettings[self.key], settings)
  end

  gsettings[self.key] = merged_settings

  M.get_settings_file():write(gsettings)
end

function M.get_settings_file()
  Log:debug("get_settings_file called")
  if not M.settings_file then
    M.settings_file = JsonFile:new(config.file_path)
  end

  return M.settings_file
end

function M.setup(user_config)
  config = vim.tbl_extend(config, user_config)
end

return M
