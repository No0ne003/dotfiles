local colors = {
  bg = "#1E2032",
  fg = "#BBCAFD",
  yellow = "#E9AD5B",
  cyan = "#41DDCA",
  sapphire = "#05D1EC",
  green = "#90D05A",
  orange = "#FF9856",
  purple = "#C198FD",
  magenta = "#FCA6E0",
  blue = "#5DA5FF",
  red = "#FF5F8C",
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Config
local config = {
  options = {
    component_separators = "",
    section_separators = "",
    theme = {
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left({
  function()
    local mode_names = {
      n = "NORMAL",
      i = "INSERT",
      v = "VISUAL",
      V = "V-LINE",
      c = "COMMAND",
      no = "OPERATOR",
      s = "SELECT",
      S = "S-LINE",
      ic = "ITALIC",
      R = "REPLACE",
      Rv = "V-REPLACE",
      cv = "COMMAND",
      ce = "NORMAL",
      r = "PROMPT",
      rm = "MORE",
      t = "TERMINAL",
    }
    return mode_names[vim.fn.mode()] or ""
  end,
  color = function()
    local mode_color = {
      n = colors.purple,
      i = colors.green,
      v = colors.blue,
      V = colors.blue,
      c = colors.magenta,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      ic = colors.yellow,
      R = colors.purple,
      Rv = colors.purple,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      t = colors.red,
    }
    return { fg = colors.bg, bg = mode_color[vim.fn.mode()], gui = "bold" }
  end,
  padding = { left = 1, right = 1 },
})

ins_left({ "location" })
ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })
ins_left({
  "branch",
  icon = "",
  color = { fg = colors.green, gui = "bold" },
})

ins_left({
  "diff",
  symbols = { added = " ", modified = "󰤌 ", removed = " " },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
})

ins_right({
  "filesize",
  cond = conditions.buffer_not_empty,
})

ins_right({
  "filename",
  cond = conditions.buffer_not_empty,
  color = { fg = colors.magenta, gui = "bold" },
})

ins_right({
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " " },
  diagnostics_color = {
    color_error = { fg = colors.red },
    color_warn = { fg = colors.orange },
    color_info = { fg = colors.cyan },
  },
})

ins_right({
  function()
    local msg = "No Active Lsp"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = " LSP:",
  color = { fg = colors.purple, gui = "bold" },
})

require("lualine").setup(config)
