lvim.log.level = "debug"

local Log = require "lvim.core.log"
Log:init()

local Settings = require('custom.config.lspsaga-settings')
Log:debug("lspsaga-settings test: Settings class created")
local a = Settings:new("lspsaga")
Log:debug("lspsaga-settings test: save clangd settings")
a:save_settings({ cpp_client = 'clangd', default = true })
Log:debug("lspsaga-settings test: get_settings")
vim.print(a:get_settings())
Log:debug("lspsaga-settings test: save ccls settings")
a:save_settings({ cpp_client = 'ccls' })
Log:debug("lspsaga-settings test: get_settings")
vim.print(a:get_settings())
