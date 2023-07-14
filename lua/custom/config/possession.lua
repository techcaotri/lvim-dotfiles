local M = {}

function M.possession_save()
  local basename = vim.fs.basename(vim.fn.getcwd())
  vim.ui.select({ basename, "tmp", "Enter new name..." }, { prompt = "Save session as: " },
    function(selected, _)
      if selected then
        local new_name = selected
        if selected == "Enter new name..." then
          new_name = vim.fn.input("Enter new name: ")
          if new_name == "" then
            return
          end
        end
        require("possession").save(new_name)
      end
    end)
end

return M
