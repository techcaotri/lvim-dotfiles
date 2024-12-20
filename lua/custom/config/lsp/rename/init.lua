local lsp = vim.lsp
local utils = require('custom.config.lsp.rename.utils')
local rename_handler = require('custom.config.lsp.rename.handler')
local Text = require('nui.text')

local default_border = 'single'
_G.CosmicUI_user_opts = {
  notify_title = 'CosmicUI',
  border_style = default_border,
  rename = {
    border = {
      highlight = 'FloatBorder',
      style = nil,
      title = 'Rename',
      title_align = 'left',
      title_hl = 'FloatBorder',
    },
    prompt = '> ',
    prompt_hl = 'Comment',
  },
}

local function rename(popup_opts, opts)
  local Input = require('nui.input')
  local event = require('nui.utils.autocmd').event
  local curr_name = vim.fn.expand('<cword>')

  local user_border = _G.CosmicUI_user_opts.rename.border
  local width = 25
  if #curr_name + #_G.CosmicUI_user_opts.rename.prompt >= width then
    -- consider prompt and one free space, otherwise the textbox scrolls
    -- and shows an -- seemingly -- empty textbox
    width = #curr_name + #_G.CosmicUI_user_opts.rename.prompt + 1
  end

  popup_opts = utils.merge({
    position = {
      row = 1,
      col = 0,
    },
    size = {
      width = width,
      height = 2,
    },
    relative = 'cursor',
    border = {
      highlight = user_border.highlight,
      style = user_border.style or _G.CosmicUI_user_opts.border_style,
      text = {
        top = Text(user_border.title, user_border.title_hl),
        top_align = user_border.title_align,
      },
    },
  }, popup_opts or {})

  opts = utils.merge({
    prompt = Text(_G.CosmicUI_user_opts.rename.prompt, _G.CosmicUI_user_opts.rename.prompt_hl),
    default_value = curr_name,
    on_submit = function(new_name)
      if not (new_name and #new_name > 0) or new_name == curr_name then
        return
      end
      local params = lsp.util.make_position_params()
      params.newName = new_name
      lsp.buf_request(0, 'textDocument/rename', params, rename_handler)
    end,
  }, opts or {})

  local input = Input(popup_opts, opts)

  -- mount/open the component
  input:mount()

  utils.default_mappings(input)

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

return rename
