local M = {}

function M.possession_save()
  local basename = vim.fs.basename(vim.fn.getcwd())
  vim.ui.select({ basename, "tmp", "Enter new name..." }, { prompt = "Save session as: " },
    function(selected, _)
      if selected then
        local new_name = selected
        if selected == "Enter new name..." then
          vim.ui.input({ prompt = "Enter new name: " }, function(text)
            new_name = text
            if new_name == "" then
              return
            end
            require("possession").save(new_name)
          end)
        else
          require("possession").save(new_name)
        end
      end
    end)
end

return M
