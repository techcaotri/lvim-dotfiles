-- Dashboard configurations

local query = require('possession.query')

local lazy_entry = { "l", "  Lazy", ":Lazy<CR>" }
table.insert(lvim.builtin.alpha.dashboard.section.buttons.entries, lazy_entry)

local new_entries =
    (function()
      local sessions = query.as_list()
      if (sessions == nil) then
        local group = {}
        local path = vim.fn.stdpath("data") .. "/possession"
        local files = vim.split(vim.fn.glob(path .. "/*.json"), "\n")
        for i, file in pairs(files) do
          local basename = vim.fs.basename(file):gsub("%.json", "")
          local button = { tostring(i), "  " .. basename,
            "<cmd>PossessionLoad " .. basename .. "<cr>" }
          table.insert(group, button)
        end
        return group
      else
        query.sort_by(sessions, "mtime", true)
        local group = {}
        for i, session in pairs(sessions) do
          local button = { tostring(i), "  " .. session.name,
            "<cmd>PossessionLoad " .. session.name .. "<cr>" }
          table.insert(group, button)
        end
        return group
      end
    end)()

for _, entry in ipairs(new_entries) do
  table.insert(lvim.builtin.alpha.dashboard.section.buttons.entries, entry)
end
